## Configuration

Use the file `/etc/radicale/config` to change the main configuration of radicale.
The file `/etc/radicale/logging` to change the level of logging.
And the file `/etc/radicale/rights` to edit the way the calendars will be sharing.

InfCloud has its own config file, at /var/www/radicale/infcloud/config.js

## YunoHost specific features

* This package bring a web interface for Radicale named InfCloud.

#### Multi-users support

Supported, with LDAP and SSO only with radicale, not for InfCloud.

## Limitations

* The version 1.1.6 is relatively old. There's a version 2 of radicale, but this new version dos not support LDAP yet.
