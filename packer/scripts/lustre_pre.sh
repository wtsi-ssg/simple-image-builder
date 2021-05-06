#!/bin/bash
UCF_FORCE_CONFOLD=1   DEBIAN_FRONTEND=noninteractive apt-get -y install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" linux-image-4.15.0-72-generic libsnmp30 libsensors4 libsnmp-base linux-headers-generic libyaml-dev zlib1g-dev

UCF_FORCE_CONFOLD=1   DEBIAN_FRONTEND=noninteractive apt-get -y update -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" 
UCF_FORCE_CONFOLD=1   DEBIAN_FRONTEND=noninteractive apt-get -y upgrade -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

cat << EOT > /etc/cloud/cloud.cfg.d/50_sanger.cfg 
package_update: true
package_upgrade: true
EOT

# We are now just auto updating
#apt-mark hold linux-image-virtual
#grub-set-default 'Advanced options for Ubuntu>Ubuntu, with Linux 4.15.0-72-generic' 
update-grub

echo 172.17.149.4  lus06-mds1  >> /etc/hosts
echo 172.17.149.5  lus06-mds2  >> /etc/hosts
echo "#lus06-mds1@tcp0:lus06-mds2@tcp0:/lus06 /lustre/secure lustre localflock,noauto 0 0" >> /etc/fstab

mkdir -p /lustre/secure /lustre/scratch123 /lustre/scratch120

