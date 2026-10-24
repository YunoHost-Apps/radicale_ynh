### Connecting a client

Use the address **`https://__DOMAIN____PATH__`** with your YunoHost username (or email address) and password. Most clients discover the calendars and address books on their own from this address.

- **Android**: use [DAVx⁵](https://www.davx5.com/), choose "Login with URL and user name".
- **iOS / macOS**: add a CalDAV account and a CardDAV account with this address.
- **Thunderbird**: add a new calendar "On the network", then a CardDAV address book, with this address.

On first login, Radicale creates a default calendar and a default address book. More can be created from the clients or from the web interface at `https://__DOMAIN____PATH__`, which also allows importing and exporting `.ics` and `.vcf` files.

When no other app uses them on __DOMAIN__, the `/.well-known/caldav` and `/.well-known/carddav` addresses are redirected to Radicale, so that `__DOMAIN__` alone is enough in most clients.

### Who can log in

Access is granted to the users and groups allowed on the permission of the app (webadmin > Users > Manage groups and permissions). Calendar and contact clients cannot log in through the YunoHost portal, so the "visitors" group always stays on this permission: it only lets requests reach Radicale, which then checks the credentials of the user and their membership of the permission.

Each user can only see and edit their own calendars and address books, unless sharing is enabled.

### Sharing

Sharing is disabled by default. In the configuration panel of the app, the administrator can let users share their calendars and address books with other users, through a secret link, or both. The shares are then made by the users themselves from the web interface, read-only or editable:

- **With another user**: the recipient finds the share in the incoming shares of the web interface, and it reaches their clients once they enable it and choose to show it. A birthday calendar can also be made from an address book.
- **Through a link**: anyone who has the link can access the calendar or address book without an account.

Good to know:

- A calendar or address book that is shared cannot be deleted until its shares are deleted.
- Disabling an option deletes the matching shares or links.
- Shares and links keep working after their owner is removed from the permission or from YunoHost. To cut them off, disable the matching option, which deletes all the shares or links.
- The links appear in the logs of Radicale and NGINX. A link that may have leaked must be deleted and replaced by a new one.

### History of changes

When "Keep a history of every change" is enabled in the configuration panel of the app (enabled by default), every change is recorded in a git repository in `__DATA_DIR__/collections`. To see the history, or to recover a deleted event or contact:

```bash
sudo -u __APP__ git -C __DATA_DIR__/collections log --stat
sudo -u __APP__ git -C __DATA_DIR__/collections show <commit>:collection-root/<user>/<calendar>/<item>.ics
```

### Files

- Calendars and address books: `__DATA_DIR__/collections/collection-root/<user>/`
- Shares and links: `__DATA_DIR__/collections/collection-db` (not in the history of changes)
- Configuration: `__INSTALL_DIR__/config` (managed by YunoHost, manual changes are overwritten on upgrade)
- Logs: `/var/log/__APP__/__APP__.log`

Failed logins are banned by Fail2Ban after 5 attempts.
