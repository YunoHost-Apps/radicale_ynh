## Configuration

Utilisez le fichier `/etc/radicale/config` pour modifier la configuration principale de radicale.
Le fichier `/etc/radicale/logging` pour changer le niveau de journalisation.
Et le fichier `/etc/radicale/rights` pour éditer la façon dont les calendriers seront partagés.

InfCloud a son propre fichier de config, à /var/www/radicale/infcloud/config.js

## Fonctionnalités spécifiques à YunoHost

* Ce package propose une interface web pour radicale nommée InfCloud.

#### Support multi-utilisateurs

Supportée, avec LDAP et SSO seulement avec radicale, pas pour InfCloud.

## Limitations

* La version 1.1.6 est relativement ancienne. Il existe une version 2 de radicale, mais cette nouvelle version ne supporte pas encore ldap.
