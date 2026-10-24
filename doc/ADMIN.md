### Connecting a client

Use the address **`https://__DOMAIN____PATH__`** with your YunoHost username (or email address) and password. Most clients discover the calendars and address books on their own from this address.

- **Android**: use [DAVx⁵](https://www.davx5.com/), choose "Login with URL and user name".
- **iOS / macOS**: add a CalDAV account and a CardDAV account with this address.
- **Thunderbird**: add a new calendar "On the network", then a CardDAV address book, with this address.

On first login, Radicale creates a default calendar and a default address book. More can be created from the clients or from the web interface at `https://__DOMAIN____PATH__`, which also allows importing and exporting `.ics` and `.vcf` files.

When no other app uses them on __DOMAIN__, the `/.well-known/caldav` and `/.well-known/carddav` addresses are redirected to Radicale, so that `__DOMAIN__` alone is enough in most clients.

### Who can log in

Access is granted to the users and groups allowed on the permission of the app (webadmin > Users > Manage groups and permissions). Calendar and contact clients cannot log in through the YunoHost portal, so the "visitors" group always stays on this permission: it only lets requests reach Radicale, which then checks the credentials of the user and their membership of the permission.

Each user can only see and edit their own calendars and address books.

### History of changes

When "Keep a history of every change" is enabled in the configuration panel of the app (enabled by default), every change is recorded in a git repository in `__DATA_DIR__/collections`. To see the history, or to recover a deleted event or contact:

```bash
sudo -u __APP__ git -C __DATA_DIR__/collections log --stat
sudo -u __APP__ git -C __DATA_DIR__/collections show <commit>:collection-root/<user>/<calendar>/<item>.ics
```

### Files

- Calendars and address books: `__DATA_DIR__/collections/collection-root/<user>/`
- Configuration: `__INSTALL_DIR__/config` (managed by YunoHost, manual changes are overwritten on upgrade)
- Logs: `/var/log/__APP__/__APP__.log`

Failed logins are banned by Fail2Ban after 5 attempts.
