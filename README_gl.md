<!--
NOTA: Este README foi creado automáticamente por <https://github.com/YunoHost/apps/tree/master/tools/readme_generator>
NON debe editarse manualmente.
-->

# Radicale para YunoHost

[![Nivel de integración](https://dash.yunohost.org/integration/radicale.svg)](https://dash.yunohost.org/appci/app/radicale) ![Estado de funcionamento](https://ci-apps.yunohost.org/ci/badges/radicale.status.svg) ![Estado de mantemento](https://ci-apps.yunohost.org/ci/badges/radicale.maintain.svg)

[![Instalar Radicale con YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=radicale)

*[Le este README en outros idiomas.](./ALL_README.md)*

> *Este paquete permíteche instalar Radicale de xeito rápido e doado nun servidor YunoHost.*  
> *Se non usas YunoHost, le a [documentación](https://yunohost.org/install) para saber como instalalo.*

## Vista xeral

Radicale is a small but powerful CalDAV (calendars, todo-lists) and CardDAV (contacts) server.


**Versión proporcionada:** 1.1.6~ynh6
## Avisos / información importante

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

## Documentación e recursos

- Web oficial da app: <http://radicale.org>
- Documentación oficial para admin: <https://github.com/Kozea/Radicale/blob/website/pages/user_documentation.rst>
- Repositorio de orixe do código: <https://github.com/Kozea/Radicale>
- Tenda YunoHost: <https://apps.yunohost.org/app/radicale>
- Informar dun problema: <https://github.com/YunoHost-Apps/radicale_ynh/issues>

## Info de desenvolvemento

Envía a túa colaboración á [rama `testing`](https://github.com/YunoHost-Apps/radicale_ynh/tree/testing).

Para probar a rama `testing`, procede deste xeito:

```bash
sudo yunohost app install https://github.com/YunoHost-Apps/radicale_ynh/tree/testing --debug
ou
sudo yunohost app upgrade radicale -u https://github.com/YunoHost-Apps/radicale_ynh/tree/testing --debug
```

**Máis info sobre o empaquetado da app:** <https://yunohost.org/packaging_apps>
