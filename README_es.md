<!--
Este archivo README esta generado automaticamente<https://github.com/YunoHost/apps/tree/master/tools/readme_generator>
No se debe editar a mano.
-->

# Radicale para Yunohost

[![Nivel de integración](https://dash.yunohost.org/integration/radicale.svg)](https://dash.yunohost.org/appci/app/radicale) ![Estado funcional](https://ci-apps.yunohost.org/ci/badges/radicale.status.svg) ![Estado En Mantención](https://ci-apps.yunohost.org/ci/badges/radicale.maintain.svg)

[![Instalar Radicale con Yunhost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=radicale)

*[Leer este README en otros idiomas.](./ALL_README.md)*

> *Este paquete le permite instalarRadicale rapidamente y simplement en un servidor YunoHost.*  
> *Si no tiene YunoHost, visita [the guide](https://yunohost.org/install) para aprender como instalarla.*

## Descripción general

Radicale is a small but powerful CalDAV (calendars, todo-lists) and CardDAV (contacts) server.


**Versión actual:** 1.1.6~ynh6
## informaciones importantes

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

## Documentaciones y recursos

- Sitio web oficial: <http://radicale.org>
- Documentación administrador oficial: <https://github.com/Kozea/Radicale/blob/website/pages/user_documentation.rst>
- Repositorio del código fuente oficial de la aplicación : <https://github.com/Kozea/Radicale>
- Catálogo YunoHost: <https://apps.yunohost.org/app/radicale>
- Reportar un error: <https://github.com/YunoHost-Apps/radicale_ynh/issues>

## Información para desarrolladores

Por favor enviar sus correcciones a la [`branch testing`](https://github.com/YunoHost-Apps/radicale_ynh/tree/testing

Para probar la rama `testing`, sigue asÍ:

```bash
sudo yunohost app install https://github.com/YunoHost-Apps/radicale_ynh/tree/testing --debug
o
sudo yunohost app upgrade radicale -u https://github.com/YunoHost-Apps/radicale_ynh/tree/testing --debug
```

**Mas informaciones sobre el empaquetado de aplicaciones:** <https://yunohost.org/packaging_apps>
