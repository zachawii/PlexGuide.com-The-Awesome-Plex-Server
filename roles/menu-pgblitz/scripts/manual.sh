#!/bin/bash
#
# [Ansible Role]
#
# GitHub:   https://github.com/Admin9705/PlexGuide.com-The-Awesome-Plex-Server
# Author:   Admin9705 & Deiteq
# URL:      https://plexguide.com
#
# PlexGuide Copyright (C) 2018 PlexGuide.com
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#
#################################################################################
echo "on" > /var/plexguide/manual.menu
menu=$(echo "on")

while [ "$menu" != "break" ]; do
  ################################################################## CORE
  downloadpath=$(cat /var/plexguide/server.hd.path)
  echo 'INFO - @Unencrypted PG Blitz Menu' > /var/plexguide/pg.log && bash /opt/plexguide/roles/log/log.sh
  RCLONE_CONF="/root/.config/rclone/rclone.conf"

  #### RECALL VARIABLES START
  tdrive=$(grep "tdrive" $RCLONE_CONF)
  gdrive=$(grep "gdrive" $RCLONE_CONF)
  tcrypt=$(grep "tcrypt" $RCLONE_CONF)
  gcrypt=$(grep "gcrypt" $RCLONE_CONF)
  #### RECALL VARIABLES END

  versioncheck="Version: Unencrypted Edition"
  final="unencrypted"

  if [ "$gdrive" != "[gdrive]" ]; then
    versioncheck="WARNING: GDrive Not Configured Properly"
    final="gdrive"
  fi

  if [ "$tdrive" != "[tdrive]" ]; then
    versioncheck="WARNING: TDrive Not Configured Properly"
    final="tdrive"
  fi

  if [ "$gcrypt" == "[gcrypt]" ]; then
      gflag="on"
      encryption="on"
  fi
  if [ "$tcrypt" == "[tcrypt]" ]; then
      tflag="on"
      encryption="on"
  fi

  if [ "$encryption" == "on" ] && [ "$tflag" == "on" ] && [ "$gflag" == "on" ]; then
      versioncheck="Version: Encrypted Edition"
      final="encrypted"
      mkdir -p /opt/appdata/pgblitz/vars
      touch /opt/appdata/pgblitz/vars/encrypted  1>/dev/null 2>&1
      mkdir -p /mnt/gcrypt
      mkdir -p /mnt/tcrypt
  elif [ "$gflag" != "on" ] && [ "$encryption" == "on" ]; then
      versioncheck="WARNING: GCrypt Not Configured Properly"
      final="gcrypt"
  elif [ "$tflag" != "on" ] && [ "$encryption" == "on" ];then
      versioncheck="WARNING: TCrypt Not Configured Properly"
      final="tcrypt"
  fi
  ################################################################## CORE
menu=$(cat /var/plexguide/manual.menu)
ansible-playbook /opt/plexguide/roles/menu-pgblitz/manual.yml
menu=$(cat /var/plexguide/manual.menu)

if [ "$menu" == "rclone" ]; then
  echo 'INFO - Selected: Transport Blitz Auto' > /var/plexguide/pg.log && bash /opt/plexguide/roles/log/log.sh
  rclone config
  touch /mnt/gdrive/plexguide/ 1>/dev/null 2>&1
  mkdir -p /root/.config/rclone/
  chown -R 1000:1000 /root/.config/rclone/
  cp ~/.config/rclone/rclone.conf /root/.config/rclone/ 1>/dev/null 2>&1
fi

if [ "$menu" == "jsons" ]; then
  echo 'INFO - Selected: PG Move - PG Drive' > /var/plexguide/pg.log && bash /opt/plexguide/roles/log/log.sh

  if [ "$final" == "gdrive" ]; then
    echo 'FAILURE - Must Configure gdrive for RCLONE' > /var/plexguide/pg.log && bash /opt/plexguide/roles/log/log.sh
    dialog --title "WARNING!" --msgbox "\nGDrive for RClone Must be Configured for PG Blitz!\n\nThis is required to BackUp/Restore any PG Data!" 0 0
    bash /opt/plexguide/roles/menu-pgblitz/scripts/main.sh
    exit
  fi
  if [ "$final" == "tdrive" ]; then
    echo 'FAILURE - Must Configure tdrive for RCLONE' > /var/plexguide/pg.log && bash /opt/plexguide/roles/log/log.sh
    dialog --title "WARNING!" --msgbox "\nTDrive for RClone Must be Configured for PG Blitz!\n\nThis is required for TeamDrives to Work!!" 0 0
    bash /opt/plexguide/roles/menu-pgblitz/scripts/main.sh
    exit
  fi
  if [ "$final" == "tcrypt" ] || [ "$final" == "gcrypt" ]; then
    echo 'FAILURE - Must Configure $final for RCLONE for Encrypted Edition' > /var/plexguide/pg.log && bash /opt/plexguide/roles/log/log.sh
    dialog --title "WARNING!" --msgbox "\n$final for RClone Must be Configured for PG Blitz!\n\nThis is required for the Encrypted Edition!!" 0 0
    bash /opt/plexguide/roles/menu-pgblitz/scripts/main.sh
    exit
  fi
      echo 'INFO - DEPLOYING CLOUDBLITZ' > /var/plexguide/pg.log && bash /opt/plexguide/roles/log/log.sh
      #### Deploy CloudBlitz
      clear && ansible-playbook /opt/plexguide/pg.yml --tags cloudblitz --extra-vars "skipend="yes --skip-tags cron
      #### Note How to Create Json files
      echo ""
      read -n 1 -s -r -p "Visit Port 7997 and Upload your JSON files\n\nKeys are Stored below for Processing:\n/opt/appdata/pgblitz/keys/unprocessed/\n\nUser - PW: plex / guide\n\nWhen Finished, Press [ENTER] to Continue!"
      echo ""
      echo "Please Wait"
      #dialog --title "NOTE" --msgbox "\nVisit Port 7997 and Upload your JSON files\n\nKeys are Stored below for Processing:\n/opt/appdata/pgblitz/keys/unprocessed/\n\nUser - PW: plex / guide\n\nWhen Finished, Press [ENTER] to Continue!" 0 0
      #dialog --infobox "Please Wait" 3 22
      docker stop cloudblitz 1>/dev/null 2>&1
      docker rm cloudblitz 1>/dev/null 2>&1
      echo ""
      read -n 1 -s -r -p "If you havn't already you need to use Option C\nand add you email's to your tdrive\nThen use option D to validate your JSON files"
fi

if [ "$menu" == "blitzmanual" ]; then
  echo 'INFO - Selected: Transport Blitz Manual' > /var/plexguide/pg.log && bash /opt/plexguide/roles/log/log.sh
  bash /opt/plexguide/roles/menu-pgblitz/scripts/main.sh
fi

if [ "$menu" == "enmove" ]; then
  echo 'INFO - Selected: PG Move - PG Drive' > /var/plexguide/pg.log && bash /opt/plexguide/roles/log/log.sh
  bash /opt/plexguide/roles/menu-move-en/scripts/main.sh
fi

echo 'INFO - Looping: Transport System Select Interface' > /var/plexguide/pg.log && bash /opt/plexguide/roles/log/log.sh
done

echo 'INFO - Exiting: Transport System Select Interface' > /var/plexguide/pg.log && bash /opt/plexguide/roles/log/log.sh
