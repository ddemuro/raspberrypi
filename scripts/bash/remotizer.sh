#!/bin/bash
################################
# Remotizer for SSH to Raspi   #
################################
SCRIPT='/opt/raspberrypi/remotizer.sh'
TAKELAN_HOST='somehost.com'
TAKELAN_PORT='22222'
BACKUP_HOST='some.host.com'
BACKUP_PORT='22222'

chmod 755 $SCRIPT
crontab -l | grep -q "@reboot $SCRIPT"  && EX_EXIST=0 || EX_EXIST=1

if [ $EX_EXIST -eq 1 ]; then
  line="@reboot $SCRIPT"
  (crontab -u userhere -l; echo "$line" ) | crontab -u userhere -
fi

ssh -f -N -T -R"$TAKELAN_PORT":localhost:22 "$TAKELAN_HOST"
RESULT=$?
if [ $RESULT -eq 0 ]; then
  echo "Connection to $TAKELAN_HOST:$TAKELAN_PORT main, succeeded."
else
  echo "Connection to $TAKELAN_HOST:$TAKELAN_PORT main, failed."
fi

ssh -f -N -T -R"$BACKUP_PORT":localhost:22 "$BACKUP_HOST"
RESULT=$?
if [ $RESULT -eq 0 ]; then
  echo "Connection to $BACKUP_PORT:$BACKUP_PORT main, succeeded."
else
  echo "Connection to $BACKUP_PORT:$BACKUP_PORT main, failed."
fi
