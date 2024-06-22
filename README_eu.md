<!--
Ohart ongi: README hau automatikoki sortu da <https://github.com/YunoHost/apps/tree/master/tools/readme_generator>ri esker
EZ editatu eskuz.
-->

# Radicale YunoHost-erako

[![Integrazio maila](https://dash.yunohost.org/integration/radicale.svg)](https://dash.yunohost.org/appci/app/radicale) ![Funtzionamendu egoera](https://ci-apps.yunohost.org/ci/badges/radicale.status.svg) ![Mantentze egoera](https://ci-apps.yunohost.org/ci/badges/radicale.maintain.svg)

[![Instalatu Radicale YunoHost-ekin](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=radicale)

*[Irakurri README hau beste hizkuntzatan.](./ALL_README.md)*

> *Pakete honek Radicale YunoHost zerbitzari batean azkar eta zailtasunik gabe instalatzea ahalbidetzen dizu.*  
> *YunoHost ez baduzu, kontsultatu [gida](https://yunohost.org/install) nola instalatu ikasteko.*

## Aurreikuspena

Radicale is a small but powerful CalDAV (calendars, todo-lists) and CardDAV (contacts) server.


**Paketatutako bertsioa:** 1.1.6~ynh6
## Ezespena / informazio garrantzitsua

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

## Dokumentazioa eta baliabideak

- Aplikazioaren webgune ofiziala: <http://radicale.org>
- Administratzaileen dokumentazio ofiziala: <https://github.com/Kozea/Radicale/blob/website/pages/user_documentation.rst>
- Jatorrizko aplikazioaren kode-gordailua: <https://github.com/Kozea/Radicale>
- YunoHost Denda: <https://apps.yunohost.org/app/radicale>
- Eman errore baten berri: <https://github.com/YunoHost-Apps/radicale_ynh/issues>

## Garatzaileentzako informazioa

Bidali `pull request`a [`testing` abarrera](https://github.com/YunoHost-Apps/radicale_ynh/tree/testing).

`testing` abarra probatzeko, ondorengoa egin:

```bash
sudo yunohost app install https://github.com/YunoHost-Apps/radicale_ynh/tree/testing --debug
edo
sudo yunohost app upgrade radicale -u https://github.com/YunoHost-Apps/radicale_ynh/tree/testing --debug
```

**Informazio gehiago aplikazioaren paketatzeari buruz:** <https://yunohost.org/packaging_apps>
