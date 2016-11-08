Radicale for YunoHost
==================

[Yunohost project](https://yunohost.org/#/)

Radicale est un serveur CalDAV (calendrier) et CardDAV (contact) complet.

http://radicale.org/

==================

Radicale ne dispose d'aucune interface, sa configuration doit être faite à l'aide des fichiers de configurations dans '/etc/radicale/'  
Il est moins friendly-user que [baikal](https://github.com/julienmalik/baikal_ynh), mais il permet de partager des calendriers en lecture seule et en écriture avec d'autres utilisateurs, qu'ils soient sur le même serveur ou pas.  
La configuration des partages se fait à l'aide du fichier de configuration des droits '/etc/radicale/rights'.

==================

~~En l'état, radicale ne fonctionne pas avec [Agendav](https://github.com/julienmalik/agendav_ynh)~~. (*il semble lors de mes derniers essai que Agendav fonctionne sans problème à présent*). Ce package est donc proposé avec l'interface caldav/carddav [InfCloud](https://www.inf-it.com/open-source/clients/infcloud/)

Le script installe les paquets *libjansson4* *libldap2-dev* *libmatheval1* *libpgm-5.1-0* *libpython-dev* *libsasl2-dev* *libsodium13* *libzmq3* *python-chardet-whl* *python-colorama-whl* *python-dev* *python-distlib-whl* *python-html5lib-whl* *python-pip-whl* *python-requests-whl* *python-setuptools-whl* *python-six-whl* *python-urllib3-whl* *python-virtualenv* *python3-virtualenv* *uwsgi* *uwsgi-core* *uwsgi-plugin-python* *virtualenv*.

**Mise à jour du package:**  
sudo yunohost app upgrade --verbose radicale -u https://github.com/YunoHost-Apps/radicale_ynh

**Multi-utilisateur:** Oui, avec support ldap.
