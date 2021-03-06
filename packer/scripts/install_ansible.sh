#!/bin/bash
#License
#=======
#  Copyright (c) 2015 Genome Research Ltd. 
#
#  Author: James Beal <James.Beal@sanger.ac.uk>
#
#  This  is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.   This program is distributed
#  in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
#  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
#  PARTICULAR PURPOSE. See the GNU General Public License for more details. 
#  You should have received a copy of the GNU General Public License along
#  with this program. If not, see <http://www.gnu.org/licenses/>. 
#
#!/bin/bash -eux

cat << EOF > /tmp/install_ansible_ubuntu.sh
#!/bin/bash -eux
export DEBIAN_FRONTEND=noninteractive
apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y install software-properties-common
apt-add-repository -y ppa:ansible/ansible
apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" update
apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y install ansible
apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y upgrade
EOF

cat << EOF > /tmp/install_ansible_ubuntu_focal.sh
#!/bin/bash -eux
export DEBIAN_FRONTEND=noninteractive
apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y update
apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y install ansible
apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y upgrade
EOF
cat << EOF > /tmp/install_ansible_centos.sh
#!/bin/bash -eux
yum -y install epel-release
yum -y install ansible
yum -y update
EOF
chmod 755 /tmp/install_ansible_ubuntu.sh /tmp/install_ansible_centos.sh
if [ "$USER" == "ubuntu" ] ; then
 if [ "$(lsb_release  -c -s)" = "focal"  ] ; then
   echo ubuntu | sudo -E -S bash /tmp/install_ansible_ubuntu_focal.sh
 else
   echo ubuntu | sudo -E -S bash /tmp/install_ansible_ubuntu.sh
 fi
fi
if [ "$USER" == "centos" ] ; then
 sudo -E -S bash /tmp/install_ansible_centos.sh
fi
ansible --version
ansible all -c local -m shell   -i "localhost," -m setup 
true
