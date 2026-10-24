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
    cat > "$collections_dir/.gitignore" << EOF
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

_radicale_add_nginx_config() {
    local nginx_conf="/etc/nginx/conf.d/$domain.d/$app.conf"
    local wellknown=0
    if _radicale_wellknown_available; then
        wellknown=1
    else
        ynh_print_warn "Another app already handles /.well-known/caldav and /.well-known/carddav on $domain: clients will need the full URL https://$domain${path%/}/ instead of just the domain name."
    fi

    ynh_config_add_nginx

    # Edit the generated file, not the template, which is reused by later upgrades
    if [ "$wellknown" -eq 1 ]; then
        ynh_replace --match="^#wellknown#" --replace="" --file="$nginx_conf"
        ynh_store_file_checksum "$nginx_conf"
        ynh_systemctl --service=nginx --action=reload
    fi
}

# DAV clients cannot use the SSO: SSOwat lets requests through and Radicale
# checks the credentials and the permission against the LDAP
_radicale_ensure_public_access() {
    ynh_app_setting_set --key=protect_against_basic_auth_spoofing --value=false
    if ! yunohost user permission info "$app.main" --output-as json --quiet | jq -e '.allowed | index("visitors")' > /dev/null; then
        ynh_permission_update --permission="main" --add="visitors"
    fi
}
