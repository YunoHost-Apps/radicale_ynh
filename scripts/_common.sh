#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

# The venv is rebuilt every time to follow Python upgrades of the system
_radicale_install_venv() {
    ynh_setup_source --dest_dir="$install_dir/source" --full_replace

    ynh_safe_rm "$install_dir/venv"
    chown -R "$app:$app" "$install_dir"
    pushd "$install_dir"
        ynh_exec_as_app python3 -m venv "$install_dir/venv"
        ynh_hide_warnings ynh_exec_as_app "$install_dir/venv/bin/pip" install --no-cache-dir --upgrade pip setuptools wheel
        ynh_hide_warnings ynh_exec_as_app "$install_dir/venv/bin/pip" install --no-cache-dir "$install_dir/source[ldap]"
    popd

    ynh_safe_rm "$install_dir/source"
    ynh_safe_rm "$install_dir/.cache"
}

_radicale_storage_hook() {
    if [ "${git_history:-1}" -eq 1 ]; then
        echo "$install_dir/storage_hook.sh %(user)s"
    fi
}

_radicale_init_git() {
    local collections_dir="$data_dir/collections"
    [ "${git_history:-1}" -eq 1 ] || return 0

    install -o "$app" -g "$app" -m 750 "$YNH_APP_BASEDIR/conf/storage_hook.sh" "$install_dir/storage_hook.sh"

    if [ ! -d "$collections_dir/.git" ]; then
        ynh_exec_as_app git -C "$collections_dir" init --quiet --initial-branch=main
    fi
    ynh_exec_as_app git -C "$collections_dir" config user.name "Radicale"
    ynh_exec_as_app git -C "$collections_dir" config user.email "$app@$domain"
    # collection-db holds the shares and the secret links
    cat > "$collections_dir/.gitignore" << EOF
/collection-db/
.Radicale.cache
.Radicale.lock
.Radicale.tmp-*
EOF
    chown "$app:$app" "$collections_dir/.gitignore"

    ynh_exec_as_app git -C "$collections_dir" add --all
    if ! ynh_exec_as_app git -C "$collections_dir" diff --cached --quiet; then
        ynh_exec_as_app git -C "$collections_dir" commit --quiet --message="State of the collections when history was enabled"
    fi
}

_radicale_add_config() {
    storage_hook="$(_radicale_storage_hook)"
    if [ "${protect_collections:-0}" -eq 1 ]; then
        permit_delete_collection=false
    else
        permit_delete_collection=true
    fi
    ynh_config_add --template="config" --destination="$install_dir/config"
    chmod 640 "$install_dir/config"
    chown "$app:$app" "$install_dir/config"
}

_radicale_prepare_data_dir() {
    local collections_dir="$data_dir/collections"
    mkdir -p "$collections_dir"
    chown "$app:$app" "$collections_dir"
    chmod 750 "$collections_dir"
}

# Fails if another app (e.g. Nextcloud) already defines the .well-known redirections on the domain
_radicale_wellknown_available() {
    local conf
    for conf in "/etc/nginx/conf.d/$domain.d/"*.conf; do
        [ -e "$conf" ] || continue
        [ "$conf" == "/etc/nginx/conf.d/$domain.d/$app.conf" ] && continue
        if grep -Eq '^[^#]*\.well-known/(caldav|carddav)' "$conf"; then
            return 1
        fi
    done
    return 0
}

# To call after ynh_config_add_nginx: edits the generated file, not the
# template, which is reused by later upgrades
_radicale_add_wellknown() {
    local nginx_conf="/etc/nginx/conf.d/$domain.d/$app.conf"
    if ! _radicale_wellknown_available; then
        ynh_print_warn "Another app already handles /.well-known/caldav and /.well-known/carddav on $domain: clients will need the full URL https://$domain${path%/}/ instead of just the domain name."
        return 0
    fi
    ynh_replace --match="^#wellknown#" --replace="" --file="$nginx_conf"
    ynh_store_file_checksum "$nginx_conf"
    ynh_systemctl --service=nginx --action=reload
}

# DAV clients cannot use the SSO: SSOwat lets requests through and Radicale
# checks the credentials and the permission against the LDAP
_radicale_ensure_public_access() {
    ynh_app_setting_set --key=protect_against_basic_auth_spoofing --value=false
    if ! yunohost user permission info "$app.main" --output-as json --quiet | jq -e '.allowed | index("visitors")' > /dev/null; then
        ynh_permission_update --permission="main" --add="visitors"
    fi
}

#=================================================
# MIGRATION FROM THE RADICALE 1.x PACKAGE
#=================================================

# Before 3.8.3~ynh1: Radicale 1.1 (Python 2, uWSGI, optional InfCloud), data in
# $install_dir/collections, configuration in /etc/$app.
# A failed upgrade removes $install_dir and the restore of the 1.x backup is
# likely to fail, so the data is first copied to $data_dir, which is kept.

_radicale_save_v1_data() {
    local backup="$data_dir/radicale1-backup"
    local temp="$data_dir/.radicale1-backup.tmp"

    if [ ! -d "$install_dir/collections" ]; then
        if [ -d "$backup/collections" ]; then
            ynh_print_info "Using the copy of the Radicale 1.x data saved by a previous upgrade attempt, in $backup"
            return 0
        fi
        ynh_print_warn "No Radicale 1.x data found in $install_dir/collections"
        return 0
    fi

    # Replace the copy of a previous attempt only once the new one is complete
    ynh_safe_rm "$temp"
    mkdir -p "$temp"
    cp -a "$install_dir/collections" "$temp/collections"
    if [ -d "/etc/$app" ]; then
        cp -a "/etc/$app" "$temp/etc"
    fi
    chown -R root:root "$temp"
    chmod -R go-rwx "$temp"
    ynh_safe_rm "$backup"
    mv "$temp" "$backup"
}

_radicale_v1_die() {
    local backup="$data_dir/radicale1-backup"
    local message="The migration of your Radicale 1.x data failed: $1"
    message+=$'\n\n'"Your data is safe: a copy of it is in $backup/collections. This copy is kept even if the app is removed (unless you explicitly purge its data), and the safety backup made by YunoHost before this upgrade contains it too (see 'yunohost backup list'; the archives are in /home/yunohost.backup/archives and can be extracted with 'tar -xf')."
    message+=$'\n\n'"YunoHost will now try to restore the previous version of the app. If it cannot, installing the app again converts the copy automatically. You can also import the data in any client: in the copy, each .ics file is a calendar and each .vcf file an address book."
    ynh_die "$message"
}

_radicale_v1_install_die() {
    local backup="$data_dir/radicale1-backup"
    local message="The conversion of the Radicale 1.x data found in $backup failed: $1"
    message+=$'\n\n'"This data was not modified. To install the app without converting it, move the folder $backup somewhere else first. You can also import it in any client: each .ics file is a calendar and each .vcf file an address book."
    ynh_die "$message"
}

# Also used on install, to recover the data left by a failed upgrade
_radicale_convert_v1_data() {
    local backup="$data_dir/radicale1-backup"
    local collections_dir="$data_dir/collections"
    local marker="$data_dir/.radicale1-migration-in-progress"
    local die="${1:-_radicale_v1_die}"

    if [ ! -d "$backup/collections" ] || [ -z "$(ls -A "$backup/collections")" ]; then
        return 0
    fi

    if [ -d "$collections_dir/collection-root" ]; then
        if [ -e "$marker" ]; then
            # Conversion of a previous failed attempt
            ynh_safe_rm "$collections_dir"
        else
            "$die" "$collections_dir already contains Radicale 3 data, refusing to overwrite it."
        fi
    else
        ynh_safe_rm "$collections_dir"
    fi
    touch "$marker"

    ynh_print_info "Converting the calendars and address books to the Radicale 3 format..."
    local users_file report="$backup/migration-report.txt"
    users_file="$(mktemp)"
    yunohost user list --output-as json --quiet | jq -r '.users | keys[]' > "$users_file"
    if ! python3 "$YNH_APP_BASEDIR/scripts/migrate_radicale1_storage.py" --users "$users_file" \
        "$backup/collections" "$collections_dir" > "$report" 2>&1; then
        cat "$report" >&2
        ynh_safe_rm "$users_file"
        "$die" "the conversion script reported an error (see the messages above)."
    fi
    ynh_safe_rm "$users_file"
    grep -v "^INFO: converted " "$report" >&2 || true
    if grep -q "^WARNING:" "$report"; then
        ynh_print_warn "Some data needed adjustments during the conversion, see the warnings above (also saved in $report)."
    fi
    chown -R "$app:$app" "$collections_dir"
    chmod 750 "$collections_dir"

    # Fail on unreadable items instead of skipping them
    ynh_print_info "Checking the converted data with Radicale 3..."
    local verify_log
    verify_log="$(mktemp)"
    chmod 644 "$verify_log"
    pushd "$data_dir"
        ynh_exec_as_app "$install_dir/venv/bin/radicale" --config "$install_dir/config" \
            --logging-level warning --no-storage-skip-broken-item --verify-storage > "$verify_log" 2>&1 \
            || { cat "$verify_log" >&2; ynh_safe_rm "$verify_log"; "$die" "Radicale 3 cannot read some of the converted data (see the messages above)."; }
    popd
    if grep -Eq "ERROR|CRITICAL" "$verify_log"; then
        cat "$verify_log" >&2
        ynh_safe_rm "$verify_log"
        "$die" "Radicale 3 found errors in the converted data (see the messages above)."
    fi
    ynh_safe_rm "$verify_log"
}

# Also called on install and removal: a failed upgrade from 1.x leaves them behind
_radicale_remove_v1_remains() {
    if [ -e /etc/uwsgi/apps-enabled/radicale.ini ] || [ -e /etc/uwsgi/apps-available/radicale.ini ]; then
        ynh_safe_rm /etc/uwsgi/apps-enabled/radicale.ini
        ynh_safe_rm /etc/uwsgi/apps-available/radicale.ini
        if systemctl is-active --quiet uwsgi; then
            ynh_systemctl --service=uwsgi --action=restart
        fi
    fi

    # InfCloud's pool (the phpversion setting is renamed by the helpers)
    local pool php_service
    for pool in /etc/php/*/fpm/pool.d/"$app".conf; do
        [ -e "$pool" ] || continue
        php_service="php$(basename "$(dirname "$(dirname "$(dirname "$pool")")")")-fpm"
        ynh_safe_rm "$pool"
        if systemctl is-active --quiet "$php_service"; then
            ynh_systemctl --service="$php_service" --action=reload
        fi
    done

    # Left by the maintenance mode of the 1.x restore script when it fails
    local maintenance_conf
    for maintenance_conf in /etc/nginx/conf.d/*.d/maintenance."$app".conf; do
        [ -e "$maintenance_conf" ] || continue
        ynh_safe_rm "$maintenance_conf"
        ynh_safe_rm "/var/www/html/maintenance.$app.html"
        ynh_systemctl --service=nginx --action=reload
    done

    ynh_safe_rm "/opt/yunohost/$app"
    ynh_safe_rm "/var/log/uwsgi/app/$app.log"
    # Not the configuration of a Radicale installed from Debian
    if grep -qs "dc=yunohost,dc=org" "/etc/$app/config"; then
        ynh_safe_rm "/etc/$app"
    fi
}

_radicale_migrate_from_v1() {
    local backup="$data_dir/radicale1-backup"

    # With InfCloud, the path setting pointed to $path/infcloud
    if [[ "$path" == */infcloud ]]; then
        path="${path%/infcloud}"
        path="${path:-/}"
        ynh_app_setting_set --key=path --value="$path"
        ynh_permission_url --permission="main" --url="/"
    fi

    _radicale_convert_v1_data

    # Sharing rules are not migrated: rights are owner_only
    if [ -f "$backup/etc/rights" ]; then
        local custom_rules
        custom_rules="$(grep -Ev '^\s*(#|$)' "$backup/etc/rights" \
            | grep -Fxv -e '[user-read-root-collection]' -e 'user: .+' -e 'collection: ^/' -e 'permission: r' \
                -e '[owner-read-write]' -e 'collection: ^%(login)s|^%(login)s/.*' -e 'permission: rw' || true)"
        if [ -n "$custom_rules" ]; then
            ynh_print_warn "The sharing rules added to /etc/$app/rights are not migrated: sharing can be enabled from the configuration panel of the app. The old rules are kept in $backup/etc/rights."
        fi
    fi

    _radicale_remove_v1_remains
    local entry
    for entry in "$install_dir/"* "$install_dir/".[!.]*; do
        [ -e "$entry" ] || continue
        case "$(basename "$entry")" in
            venv | config | storage_hook.sh) ;;
            *) ynh_safe_rm "$entry" ;;
        esac
    done

    # The 1.x package let every user log in
    ynh_permission_update --permission="main" --add="all_users"

    local setting
    for setting in infcloud language admin version phpversion php_version fpm_footprint fpm_usage fpm_free_footprint \
        overwrite_logging overwrite_config overwrite_infcloud overwrite_nginx overwrite_phpfpm admin_mail_html \
        final_path skipped_regex unprotected_uris protected_uris; do
        ynh_app_setting_delete --key="$setting"
    done
}

_radicale_v1_migration_done() {
    ynh_safe_rm "$data_dir/.radicale1-migration-in-progress"
}
