# Radicale for YunoHost

[![Integration level](https://dash.yunohost.org/integration/radicale.svg)](https://ci-apps.yunohost.org/jenkins/job/radicale%20%28Community%29/lastBuild/consoleFull)  
[![Install Radicale with YunoHost](https://install-app.yunohost.org/install-with-yunohost.png)](https://install-app.yunohost.org/?app=radicale)

*[Lire ce readme en français.](./README_fr.md)*

> *This package allow you to install Radicale quickly and simply on a YunoHost server.  
If you don't have YunoHost, please see [here](https://yunohost.org/#/install) to know how to install and enjoy it.*

## Overview

Radicale is a small but powerful CalDAV (calendars, todo-lists) and CardDAV (contacts) server.

**Shipped version:** 1.1.6
**Shipped version of InfCloud:** 0.13.1

## Screenshots

## Configuration

Use the file `/etc/radicale/config` to change the main configuration of radicale.
The file `/etc/radicale/logging` to change the level of logging.
And the file `/etc/radicale/rights` to edit the way the calendars will be sharing.

InfCloud has its own config file, at /var/www/radicale/infcloud/config.js

## Documentation

 * Official documentation: https://github.com/Kozea/Radicale/blob/website/pages/user_documentation.rst
 * YunoHost documentation: [app_radicale.md](./app_radicale.md)

## YunoHost specific features

* This package bring a web interface for radicale named InfCloud.

#### Multi-users support

Supported, with LDAP and SSO only with radicale, not for InfCloud.

#### Supported architectures

* x86-64b - [![Build Status](https://ci-apps.yunohost.org/jenkins/job/radicale%20(Community)/badge/icon)](https://ci-apps.yunohost.org/jenkins/job/radicale%20(Community)/)
* ARMv8-A - [![Build Status](https://ci-apps.yunohost.org/jenkins/job/radicale%20(Community)%20(%7EARM%7E)/badge/icon)](https://ci-apps.yunohost.org/jenkins/job/radicale%20(Community)%20(%7EARM%7E)/)

## Limitations

* The version 1.1.6 is relatively old. There's a version 2 of radicale, but this new version dos not support ldap yet.

## Additionnal informations

## Links

 * Report a bug: https://github.com/YunoHost-Apps/radicale_ynh/issues
 * Radicale website: http://radicale.org/
 * InfCloud website: https://www.inf-it.com/open-source/clients/infcloud/
 * YunoHost website: https://yunohost.org/

---

Developers infos
----------------

Please do your pull request to the [testing branch](https://github.com/YunoHost-Apps/radicale_ynh/tree/testing).

To try the testing branch, please proceed like that.
```
sudo yunohost app install https://github.com/YunoHost-Apps/radicale_ynh/tree/testing --verbose
or
sudo yunohost app upgrade radicale -u https://github.com/YunoHost-Apps/radicale_ynh/tree/testing --verbose
```
