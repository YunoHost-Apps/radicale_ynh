# Radicale pour YunoHost

[![Niveau d'intégration](https://dash.yunohost.org/integration/radicale.svg)](https://dash.yunohost.org/appci/app/radicale) ![](https://ci-apps.yunohost.org/ci/badges/radicale.status.svg) ![](https://ci-apps.yunohost.org/ci/badges/radicale.maintain.svg)  
[![Installer Radicale avec YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=radicale)

*[Read this readme in english.](./README.md)*
*[Lire ce readme en français.](./README_fr.md)*

> *Ce package vous permet d'installer Radicale rapidement et simplement sur un serveur YunoHost.
Si vous n'avez pas YunoHost, regardez [ici](https://yunohost.org/#/install) pour savoir comment l'installer et en profiter.*

## Vue d'ensemble

Radicale is a small but powerful CalDAV (calendars, todo-lists) and CardDAV (contacts) server.

* This package bring a web interface for Radicale named InfCloud.


**Version incluse :** 1.1.6~ynh5



## Avertissements / informations importantes

## Configuration

Use the file `/etc/radicale/config` to change the main configuration of radicale.
The file `/etc/radicale/logging` to change the level of logging.
And the file `/etc/radicale/rights` to edit the way the calendars will be sharing.

InfCloud has its own config file, at /var/www/radicale/infcloud/config.js

## Limitations

* The version 1.1.6 is relatively old. There's a version 2 of radicale, but this new version dos not support LDAP yet.


## Documentations et ressources

* Site officiel de l'app : http://radicale.org
* Documentation officielle de l'admin : https://github.com/Kozea/Radicale/blob/website/pages/user_documentation.rst
* Documentation YunoHost pour cette app : https://yunohost.org/app_radicale
* Signaler un bug : https://github.com/YunoHost-Apps/radicale_ynh/issues

## Informations pour les développeurs

Merci de faire vos pull request sur la [branche testing](https://github.com/YunoHost-Apps/radicale_ynh/tree/testing).

Pour essayer la branche testing, procédez comme suit.
```
sudo yunohost app install https://github.com/YunoHost-Apps/radicale_ynh/tree/testing --debug
ou
sudo yunohost app upgrade radicale -u https://github.com/YunoHost-Apps/radicale_ynh/tree/testing --debug
```

**Plus d'infos sur le packaging d'applications :** https://yunohost.org/packaging_apps