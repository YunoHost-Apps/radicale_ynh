## Configuration

Utilisez le fichier `/etc/radicale/config` pour modifier la configuration principale de radicale.
Le fichier `/etc/radicale/logging` pour changer le niveau de journalisation.
Et le fichier `/etc/radicale/rights` pour �diter la fa�on dont les calendriers seront partag�s.

InfCloud a son propre fichier de config, � /var/www/radicale/infcloud/config.js

## Fonctionnalit�s sp�cifiques � YunoHost

* Ce package propose une interface web pour radicale nomm�e InfCloud.

#### Support multi-utilisateurs

Support�e, avec LDAP et SSO seulement avec radicale, pas pour InfCloud.

## Limitations

* La version 1.1.6 est relativement ancienne. Il existe une version 2 de radicale, mais cette nouvelle version ne supporte pas encore ldap.
