#!/bin/bash
if [ "${REBOOT}" == "YES" ] ; then 
  echo "Rebooting"
  sleep 3
  sync
  reboot &
  sleep 30
  sync & 
  sleep 5
  echo b > /proc/sysrq-trigger
fi
echo "Skipping reboot"
