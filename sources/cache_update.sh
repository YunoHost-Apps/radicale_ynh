#! /bin/bash
# Use this script every time you modify any file to force browsers to reload it (empty HTML5 cache).

#command -v ed &> /dev/null || { echo "Error: 'ed' not installed. Aborting." > /dev/stderr; exit 1; }
#printf ",s/#V.*/#V $(date '+%Y%m%d%H%M%S')/\nw\nq\n" | ed -s cache.manifest

sudo sed s@"^#V [0-9]\{14\}"@"#V $(date '+%Y%m%d%H%M%S')"@ -i cache.manifest
# Remplace les 14 caractères de la date par la date courante pour forcer la mise à jour de la configuration.
