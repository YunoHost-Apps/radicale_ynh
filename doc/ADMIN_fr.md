### Connecter un client

Utilisez l'adresse **`https://__DOMAIN____PATH__`** avec votre nom d'utilisateur YunoHost (ou votre adresse e-mail) et votre mot de passe. La plupart des clients trouvent seuls les agendas et carnets d'adresses à partir de cette adresse.

- **Android** : utilisez [DAVx⁵](https://www.davx5.com/), choisissez « Connexion avec une URL et un nom d'utilisateur ».
- **iOS / macOS** : ajoutez un compte CalDAV et un compte CardDAV avec cette adresse.
- **Thunderbird** : ajoutez un nouvel agenda « Sur le réseau », puis un carnet d'adresses CardDAV, avec cette adresse.

À la première connexion, Radicale crée un agenda et un carnet d'adresses par défaut. D'autres peuvent être créés depuis les clients ou depuis l'interface web à l'adresse `https://__DOMAIN____PATH__`, qui permet aussi d'importer et d'exporter des fichiers `.ics` et `.vcf`.

Quand aucune autre application ne les utilise sur __DOMAIN__, les adresses `/.well-known/caldav` et `/.well-known/carddav` sont redirigées vers Radicale : `__DOMAIN__` seul suffit alors dans la plupart des clients.

### Qui peut se connecter

L'accès est accordé aux utilisateurs et groupes autorisés sur la permission de l'application (webadmin > Utilisateurs > Gérer les groupes et les permissions). Les clients d'agenda et de contacts ne peuvent pas se connecter via le portail YunoHost : le groupe « visitors » reste donc toujours sur cette permission. Il permet seulement aux requêtes d'atteindre Radicale, qui vérifie ensuite les identifiants de l'utilisateur et son appartenance à la permission.

Chaque utilisateur ne peut voir et modifier que ses propres agendas et carnets d'adresses.

### Historique des modifications

Quand « Conserver un historique de chaque modification » est activé dans le panneau de configuration de l'application (activé par défaut), chaque modification est enregistrée dans un dépôt git dans `__DATA_DIR__/collections`. Pour consulter l'historique, ou retrouver un événement ou un contact supprimé :

```bash
sudo -u __APP__ git -C __DATA_DIR__/collections log --stat
sudo -u __APP__ git -C __DATA_DIR__/collections show <commit>:collection-root/<utilisateur>/<agenda>/<élément>.ics
```

### Fichiers

- Agendas et carnets d'adresses : `__DATA_DIR__/collections/collection-root/<utilisateur>/`
- Configuration : `__INSTALL_DIR__/config` (gérée par YunoHost, les modifications manuelles sont écrasées lors des mises à jour)
- Journaux : `/var/log/__APP__/__APP__.log`

Les connexions échouées sont bannies par Fail2Ban après 5 tentatives.
