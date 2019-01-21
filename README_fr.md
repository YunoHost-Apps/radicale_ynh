# Radicale pour YunoHost

[![Niveau d'intégration](https://dash.yunohost.org/integration/radicale.svg)](https://dash.yunohost.org/appci/app/radicale)  
[![Installer Radicale avec YunoHost](https://install-app.yunohost.org/install-with-yunohost.png)](https://install-app.yunohost.org/?app=radicale)

*[Read this readme in english.](./README.md)*

> *Ce package vous permet d'installer Radicale rapidement et simplement sur un serveur YunoHost.  
Si vous n'avez pas YunoHost, merci de regarder [ici](https://yunohost.org/#/install_fr) pour savoir comment l'installer et en profiter.*

## Résumé

Radicale est un petit mais puissant serveur CalDAV (calendriers, listes de tâches) et CardDAV (contacts).

**Version embarquée:** 1.1.6
**Version embarquée de InfCloud:** 0.13.1

## Captures d'écran

## Démo

Aucune démo pour cette application.

## Configuration

Utilisez le fichier `/etc/radicale/config` pour modifier la configuration principale de radicale.
Le fichier `/etc/radicale/logging` pour changer le niveau de journalisation.
Et le fichier `/etc/radicale/rights` pour éditer la façon dont les calendriers seront partagés.

InfCloud a son propre fichier de config, à /var/www/radicale/infcloud/config.js

## Documentation

 * Official documentation: https://github.com/Kozea/Radicale/blob/website/pages/user_documentation.rst
 * Documentation YunoHost: [app_radicale_fr.md](./app_radicale_fr.md)

## Fonctionnalités spécifiques à YunoHost

* Ce package propose une interface web pour radicale nommée InfCloud.

#### Support multi-utilisateurs

Supportée, avec LDAP et SSO seulement avec radicale, pas pour InfCloud.

#### Architectures supportées.

* x86-64b - [![](https://ci-apps.yunohost.org/ci/logs/radicale%20%28Community%29.svg)](https://ci-apps.yunohost.org/ci/apps/radicale/)
* ARMv8-A - [![](https://ci-apps-arm.yunohost.org/ci/logs/radicale%20%28Community%29.svg)](https://ci-apps-arm.yunohost.org/ci/apps/radicale/)
* Jessie x86-64b - [![](https://ci-stretch.nohost.me/ci/logs/radicale%20%28Community%29.svg)](https://ci-stretch.nohost.me/ci/apps/radicale/)

## Limitations

* La version 1.1.6 est relativement ancienne. Il existe une version 2 de radicale, mais cette nouvelle version ne supporte pas encore ldap.

## Informations additionnelles

## Liens

 * Reporter un bug: https://github.com/YunoHost-Apps/radicale_ynh/issues
 * Site de Radicale: http://radicale.org/
 * Site de InfCloud: https://www.inf-it.com/open-source/clients/infcloud/
 * Site de YunoHost: https://yunohost.org/

---

Informations à l'intention des développeurs
----------------

Merci de faire vos pull request sur la [branche testing](https://github.com/YunoHost-Apps/radicale_ynh/tree/testing).

Pour tester la branche testing, merci de procéder ainsi.
```
sudo yunohost app install https://github.com/YunoHost-Apps/radicale_ynh/tree/testing --debug
ou
sudo yunohost app upgrade radicale -u https://github.com/YunoHost-Apps/radicale_ynh/tree/testing --debug
```
