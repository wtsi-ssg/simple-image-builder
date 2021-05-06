#!/bin/bash -eux
set -e
#License
#=======
#  Copyright (c) 2018 Genome Research Ltd.
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
cd /tmp
git clone "https://${ANSIBLE_READ_USER}:${ANSIBLE_READ_SECRET}@gitlab.internal.sanger.ac.uk/configuration-management/ansible.git"

for i in /usr/local/sbin/lustre-tune /usr/local/sbin/mountLustre \
         /etc/systemd/system/lustre-tune.service /etc/systemd/system/mountLustre.service \
         /etc/default/lustre-tune
do
  cp /tmp/ansible/roles/farm/sanger.lustre/files/${i}  ${i}
  chmod 755 ${i}
done
rm -rf /tmp/ansible

# Only start lustre when lustre is configured
sed -i /etc/systemd/system/mountLustre.service  -e 's/After=network.target network-online.target$/After=network.target network-online.target lustre-config-setup.service/'

cat << EOT > /etc/lnet.conf-template-direct
net:
    - net type: LUSTRE_NETWORK
      local NI(s):
        - nid: LUSTRE_NETWORK
          status: up
          interfaces:
              0: LUSTRE_INTERFACE
          statistics:
              send_count: 0
              recv_count: 0
              drop_count: 0
          lnd tunables:
          tcp bonding: 0
          dev cpt: -1
          CPT: "[0]"
numa:
    range: 0
EOT

cat << EOT > /etc/lnet.conf-template-router
net:
    - net type: LUSTRE_NETWORK
      local NI(s):
        - nid: LUSTRE_NETWORK
          status: up
          interfaces:
              0: LUSTRE_INTERFACE
          statistics:
              send_count: 0
              recv_count: 0
              drop_count: 0
          tunables:
              peer_timeout: 180
              peer_credits: 8
              peer_buffer_credits: 0
              credits: 256
          lnd tunables:
          tcp bonding: 0
          dev cpt: -1
          CPT: "[0]"
numa:
    range: 0
route:
    - net: tcp0
      gateway: ROUTER1@LUSTRE_NETWORK
      priority: 0
      state: up
    - net: tcp0
      gateway: ROUTER2@LUSTRE_NETWORK
      priority: 0
      state: up
    - net: tcp0
      gateway: ROUTER3@LUSTRE_NETWORK
      priority: 0
      state: up
    - net: tcp0
      gateway: ROUTER4@LUSTRE_NETWORK
      priority: 0
      state: up
EOT

cat << EOF > /usr/local/sbin/lustre-config-setup
#!/bin/bash
#Lets wait a bit for an interface ( one minute )
i=0

while [[ \$i -lt 30 ]]
do
  ((i++))
  if [[ \$(ip --brief address show | awk '{if (\$3 !~ /^$/ && \$2 ~ /^UP$/ && \$1 ~ /^ens/ ) print \$0}' | wc -l) -gt 2 ]]; then
    break
  fi
  sleep 4
done
sleep 2 # For luck
# Hopefully we have more than 2 interfaces... ( but we might be in test )
ROUTES=/tmp/lnet.\$\$
LNET="tcp0"
#use the default route for lustre traffic unless any of the following provider networks are present.
ip r > \${ROUTES}
LUSTRE_INTERFACE=\$(grep default \${ROUTES} | awk '{print \$5}')
if grep -s 172.27.194.0/23 \${ROUTES} ; then
  LUSTRE_INTERFACE=\$(grep 172.27.194.0/23 \${ROUTES} | awk '{print \$3}' )
  LNET="tcp1"
  ROUTER4="172.27.195.22"
  ROUTER3="172.27.195.21"
  ROUTER2="172.27.195.28"
  ROUTER1="172.27.195.24"
fi
if grep -s 172.27.196.0/23 \${ROUTES} ; then
  LUSTRE_INTERFACE=\$(grep 172.27.196.0/23 \${ROUTES} | awk '{print \$3}' )
  LNET="tcp65532"
  ROUTER4="172.27.197.24"
  ROUTER3="172.27.197.32"
  ROUTER2="172.27.197.21"
  ROUTER1="172.27.197.30"
fi
if grep -s 172.27.198.0/23 \${ROUTES} ; then
  LUSTRE_INTERFACE=\$(grep 172.27.198.0/23 \${ROUTES} | awk '{print \$3}' )
  LNET="tcp65531"
  ROUTER4="172.27.199.34"
  ROUTER3="172.27.199.27"
  ROUTER2="172.27.199.25"
  ROUTER1="172.27.199.20"
fi
if grep -s 172.27.200.0/23 \${ROUTES} ; then
  LUSTRE_INTERFACE=\$(grep 172.27.200.0/23 \${ROUTES} | awk '{print \$3}' )
  LNET="tcp65530"
  ROUTER4="172.27.201.29"
  ROUTER3="172.27.201.23"
  ROUTER2="172.27.201.25"
  ROUTER1="172.27.201.27"
fi
if grep -s 172.27.204.0/23 \${ROUTES} ; then
  LUSTRE_INTERFACE=\$(grep 172.27.204.0/23 \${ROUTES} | awk '{print \$3}' )
  LNET="tcp65529"
  ROUTER4="172.27.205.34"
  ROUTER3="172.27.205.33"
  ROUTER2="172.27.205.31"
  ROUTER1="172.27.205.22"
fi
if grep -s 172.27.206.0/23 \${ROUTES} ; then
  LUSTRE_INTERFACE=\$(grep 172.27.206.0/23 \${ROUTES} | awk '{print \$3}' )
  LNET="tcp65528"
  ROUTER4="172.27.207.21"
  ROUTER3="172.27.207.20"
  ROUTER2="172.27.207.24"
  ROUTER1="172.27.207.22"
fi
if grep -s 172.27.208.0/23 \${ROUTES} ; then
  LUSTRE_INTERFACE=\$(grep 172.27.208.0/23 \${ROUTES} | awk '{print \$3}' )
  LNET="tcp65527"
  ROUTER4="172.27.209.23"
  ROUTER3="172.27.209.22"
  ROUTER2="172.27.209.21"
  ROUTER1="172.27.209.26"
fi
if grep -s -E "(10.160.32.32|10.177.252.32)/27" \${ROUTES} ; then
  LUSTRE_INTERFACE=\$(grep -E "(10.160.32.32|10.177.252.32)/27" \${ROUTES} | awk '{print \$5}' )
  LNET="tcp1"
  grep -qxF '10.160.32.37  lus23-mds2' /etc/hosts || echo '10.160.32.37  lus23-mds2' >> /etc/hosts
  grep -qxF '10.160.32.36  lus23-mds1' /etc/hosts || echo '10.160.32.36  lus23-mds1' >> /etc/hosts
  grep -qxF 'lus23-mds2@tcp1:lus23-mds1@tcp1:/lus23 /lustre/scratch123 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus23-mds2@tcp1:lus23-mds1@tcp1:/lus23 /lustre/scratch123 lustre network=tcp1,localflock,noauto 0 0' >> /etc/fstab
  grep -qxF '10.177.252.37 lus20-mds2' /etc/hosts || echo '10.177.252.37 lus20-mds2' >> /etc/hosts
  grep -qxF '10.177.252.36 lus20-mds1' /etc/hosts || echo '10.177.252.36 lus20-mds1' >> /etc/hosts
  grep -qxF 'lus20-mds2@tcp1:lus20-mds1@tcp1:/lus20 /lustre/scratch120 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus20-mds2@tcp1:lus20-mds1@tcp1:/lus20 /lustre/scratch120 lustre network=tcp1,localflock,noauto 0 0' >> /etc/fstab
fi
if grep -s -E "(10.160.32.64|10.177.252.64)/27" \${ROUTES} ; then
  LUSTRE_INTERFACE=\$(grep -E "(10.160.32.64|10.177.252.64)/27" \${ROUTES} | awk '{print \$5}' )
  LNET="tcp2"
  grep -qxF '10.160.32.69  lus23-mds2' /etc/hosts || echo '10.160.32.69  lus23-mds2' >> /etc/hosts
  grep -qxF '10.160.32.68  lus23-mds1' /etc/hosts || echo '10.160.32.68  lus23-mds1' >> /etc/hosts
  grep -qxF 'lus23-mds2@tcp2:lus23-mds1@tcp2:/lus23 /lustre/scratch123 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus23-mds2@tcp2:lus23-mds1@tcp2:/lus23 /lustre/scratch123 lustre network=tcp2,localflock,noauto 0 0' >> /etc/fstab
  grep -qxF '10.177.252.69 lus20-mds2' /etc/hosts || echo '10.177.252.69 lus20-mds2' >> /etc/hosts
  grep -qxF '10.177.252.68 lus20-mds1' /etc/hosts || echo '10.177.252.68 lus20-mds1' >> /etc/hosts
  grep -qxF 'lus20-mds2@tcp2:lus20-mds1@tcp2:/lus20 /lustre/scratch120 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus20-mds2@tcp2:lus20-mds1@tcp2:/lus20 /lustre/scratch120 lustre network=tcp2,localflock,noauto 0 0' >> /etc/fstab
fi
if grep -s -E "(10.160.32.96|10.177.252.96)/27" \${ROUTES} ; then
  LUSTRE_INTERFACE=\$(grep -E "(10.160.32.96|10.177.252.96)/27" \${ROUTES} | awk '{print \$5}' )
  LNET="tcp3"
  grep -qxF '10.160.32.101  lus23-mds2' /etc/hosts || echo '10.160.32.101  lus23-mds2' >> /etc/hosts
  grep -qxF '10.160.32.100  lus23-mds1' /etc/hosts || echo '10.160.32.100  lus23-mds1' >> /etc/hosts
  grep -qxF 'lus23-mds2@tcp3:lus23-mds1@tcp3:/lus23 /lustre/scratch123 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus23-mds2@tcp3:lus23-mds1@tcp3:/lus23 /lustre/scratch123 lustre network=tcp3,localflock,noauto 0 0' >> /etc/fstab
  grep -qxF '10.177.252.101 lus20-mds2' /etc/hosts || echo '10.177.252.101 lus20-mds2' >> /etc/hosts
  grep -qxF '10.177.252.100 lus20-mds1' /etc/hosts || echo '10.177.252.100 lus20-mds1' >> /etc/hosts
  grep -qxF 'lus20-mds2@tcp3:lus20-mds1@tcp3:/lus20 /lustre/scratch120 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus20-mds2@tcp3:lus20-mds1@tcp3:/lus20 /lustre/scratch120 lustre network=tcp3,localflock,noauto 0 0' >> /etc/fstab
fi
if grep -s -E "(10.160.32.128|10.177.252.128)/27" \${ROUTES} \${ROUTES} ; then
  LUSTRE_INTERFACE=\$(grep -E "(10.160.32.128|10.177.252.128)/27" \${ROUTES} | awk '{print \$5}' )
  LNET="tcp4"
  grep -qxF '10.160.32.133  lus23-mds2' /etc/hosts || echo '10.160.32.133  lus23-mds2' >> /etc/hosts
  grep -qxF '10.160.32.132  lus23-mds1' /etc/hosts || echo '10.160.32.132  lus23-mds1' >> /etc/hosts
  grep -qxF 'lus23-mds2@tcp4:lus23-mds1@tcp4:/lus23 /lustre/scratch123 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus23-mds2@tcp4:lus23-mds1@tcp4:/lus23 /lustre/scratch123 lustre network=tcp4,localflock,noauto 0 0' >> /etc/fstab
  grep -qxF '10.177.252.133 lus20-mds2' /etc/hosts || echo '10.177.252.133 lus20-mds2' >> /etc/hosts
  grep -qxF '10.177.252.132 lus20-mds1' /etc/hosts || echo '10.177.252.132 lus20-mds1' >> /etc/hosts
  grep -qxF 'lus20-mds2@tcp4:lus20-mds4@tcp1:/lus20 /lustre/scratch120 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus20-mds2@tcp4:lus20-mds1@tcp4:/lus20 /lustre/scratch120 lustre network=tcp4,localflock,noauto 0 0' >> /etc/fstab
fi
if grep -s -E "(10.160.32.160|10.177.252.160)/27" \${ROUTES} ; then
  LUSTRE_INTERFACE=\$(grep -E "(10.160.32.160|10.177.252.160)/27" \${ROUTES} | awk '{print \$5}' )
  LNET="tcp5"
  grep -qxF '10.160.32.165  lus23-mds2' /etc/hosts || echo '10.160.32.165  lus23-mds2' >> /etc/hosts
  grep -qxF '10.160.32.164  lus23-mds1' /etc/hosts || echo '10.160.32.164  lus23-mds1' >> /etc/hosts
  grep -qxF 'lus23-mds2@tcp5:lus23-mds1@tcp5:/lus23 /lustre/scratch123 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus23-mds2@tcp5:lus23-mds1@tcp5:/lus23 /lustre/scratch123 lustre network=tcp5,localflock,noauto 0 0' >> /etc/fstab
  grep -qxF '10.177.252.165 lus20-mds2' /etc/hosts || echo '10.177.252.165 lus20-mds2' >> /etc/hosts
  grep -qxF '10.177.252.164 lus20-mds1' /etc/hosts || echo '10.177.252.164 lus20-mds1' >> /etc/hosts
  grep -qxF 'lus20-mds2@tcp5:lus20-mds1@tcp5:/lus20 /lustre/scratch120 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus20-mds2@tcp5:lus20-mds1@tcp5:/lus20 /lustre/scratch120 lustre network=tcp5,localflock,noauto 0 0' >> /etc/fstab
fi
if grep -s -E "(10.160.32.192|10.177.252.192)/27"  \${ROUTES} ; then
  LUSTRE_INTERFACE=\$(grep -E "(10.160.32.192|10.177.252.192)/27" \${ROUTES} | awk '{print \$5}' )
  LNET="tcp6"
  grep -qxF '10.160.32.197  lus23-mds2' /etc/hosts || echo '10.160.32.197  lus23-mds2' >> /etc/hosts
  grep -qxF '10.160.32.196  lus23-mds1' /etc/hosts || echo '10.160.32.196  lus23-mds1' >> /etc/hosts
  grep -qxF 'lus23-mds2@tcp6:lus23-mds1@tcp6:/lus23 /lustre/scratch123 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus23-mds2@tcp6:lus23-mds1@tcp6:/lus23 /lustre/scratch123 lustre network=tcp6,localflock,noauto 0 0' >> /etc/fstab
  grep -qxF '10.177.252.197 lus20-mds2' /etc/hosts || echo '10.177.252.197 lus20-mds2' >> /etc/hosts
  grep -qxF '10.177.252.196 lus20-mds1' /etc/hosts || echo '10.177.252.196 lus20-mds1' >> /etc/hosts
  grep -qxF 'lus20-mds2@tcp6:lus20-mds6@tcp1:/lus20 /lustre/scratch120 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus20-mds2@tcp6:lus20-mds1@tcp6:/lus20 /lustre/scratch120 lustre network=tcp6,localflock,noauto 0 0' >> /etc/fstab
fi
if grep -s -E "(10.160.32.224|10.177.252.224)/27" \${ROUTES} ; then
  LUSTRE_INTERFACE=\$(grep -E "(10.160.32.224|10.177.252.224)/27" \${ROUTES} | awk '{print \$5}' )
  LNET="tcp7"
  grep -qxF '10.160.32.229  lus23-mds2' /etc/hosts || echo '10.160.32.229  lus23-mds2' >> /etc/hosts
  grep -qxF '10.160.32.228  lus23-mds1' /etc/hosts || echo '10.160.32.228  lus23-mds1' >> /etc/hosts
  grep -qxF 'lus23-mds2@tcp7:lus23-mds1@tcp7:/lus23 /lustre/scratch123 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus23-mds2@tcp7:lus23-mds1@tcp7:/lus23 /lustre/scratch123 lustre network=tcp7,localflock,noauto 0 0' >> /etc/fstab
  grep -qxF '10.177.252.229 lus20-mds2' /etc/hosts || echo '10.177.252.229 lus20-mds2' >> /etc/hosts
  grep -qxF '10.177.252.228 lus20-mds1' /etc/hosts || echo '10.177.252.228 lus20-mds1' >> /etc/hosts
  grep -qxF 'lus20-mds2@tcp7:lus20-mds1@tcp7:/lus20 /lustre/scratch120 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus20-mds2@tcp7:lus20-mds1@tcp7:/lus20 /lustre/scratch120 lustre network=tcp7,localflock,noauto 0 0' >> /etc/fstab
fi
if grep -s -E "(10.160.33.0|10.177.253.0)/27" \${ROUTES} ; then
  LUSTRE_INTERFACE=\$(grep -E "(10.160.33.0|10.177.253.0)/27" \${ROUTES} | awk '{print \$5}' )
  LNET="tcp8"
  grep -qxF '10.160.33.5  lus23-mds2' /etc/hosts || echo '10.160.33.5  lus23-mds2' >> /etc/hosts
  grep -qxF '10.160.33.4  lus23-mds1' /etc/hosts || echo '10.160.33.4  lus23-mds1' >> /etc/hosts
  grep -qxF 'lus23-mds2@tcp8:lus23-mds1@tcp8:/lus23 /lustre/scratch123 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus23-mds2@tcp8:lus23-mds1@tcp8:/lus23 /lustre/scratch123 lustre network=tcp8,localflock,noauto 0 0' >> /etc/fstab
  grep -qxF '10.177.253.5 lus20-mds2' /etc/hosts || echo '10.177.253.5 lus20-mds2' >> /etc/hosts
  grep -qxF '10.177.253.4 lus20-mds1' /etc/hosts || echo '10.177.253.4 lus20-mds1' >> /etc/hosts
  grep -qxF 'lus20-mds2@tcp8:lus20-mds1@tcp8:/lus20 /lustre/scratch120 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus20-mds2@tcp8:lus20-mds1@tcp8:/lus20 /lustre/scratch120 lustre network=tcp8,localflock,noauto 0 0' >> /etc/fstab
fi
if grep -s -E "(10.160.33.32|10.177.253.32)/27" \${ROUTES} ; then
  LUSTRE_INTERFACE=\$(grep -E "(10.160.33.32|10.177.253.32)/27" \${ROUTES} | awk '{print \$5}' )
  LNET="tcp9"
  grep -qxF '10.160.33.37  lus23-mds2' /etc/hosts || echo '10.160.33.37  lus23-mds2' >> /etc/hosts
  grep -qxF '10.160.33.36  lus23-mds1' /etc/hosts || echo '10.160.33.36  lus23-mds1' >> /etc/hosts
  grep -qxF 'lus23-mds2@tcp9:lus23-mds1@tcp9:/lus23 /lustre/scratch123 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus23-mds2@tcp9:lus23-mds1@tcp9:/lus23 /lustre/scratch123 lustre network=tcp9,localflock,noauto 0 0' >> /etc/fstab
  grep -qxF '10.177.253.37 lus20-mds2' /etc/hosts || echo '10.177.253.37 lus20-mds2' >> /etc/hosts
  grep -qxF '10.177.253.36 lus20-mds1' /etc/hosts || echo '10.177.253.36 lus20-mds1' >> /etc/hosts
  grep -qxF 'lus20-mds2@tcp9:lus20-mds1@tcp9:/lus20 /lustre/scratch120 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus20-mds2@tcp9:lus20-mds1@tcp9:/lus20 /lustre/scratch120 lustre network=tcp9,localflock,noauto 0 0' >> /etc/fstab
fi
if grep -s -E "(10.160.33.64|10.177.253.64)/27" \${ROUTES} ; then
  LUSTRE_INTERFACE=\$(grep -E "(10.160.33.64|10.177.253.64)/27" \${ROUTES} | awk '{print \$5}' )
  LNET="tcp10"
  grep -qxF '10.160.33.69  lus23-mds2' /etc/hosts || echo '10.160.33.69  lus23-mds2' >> /etc/hosts
  grep -qxF '10.160.33.68  lus23-mds1' /etc/hosts || echo '10.160.33.68  lus23-mds1' >> /etc/hosts
  grep -qxF 'lus23-mds2@tcp10:lus23-mds1@tcp10:/lus23 /lustre/scratch123 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus23-mds2@tcp10:lus23-mds1@tcp10:/lus23 /lustre/scratch123 lustre network=tcp10,localflock,noauto 0 0' >> /etc/fstab
  grep -qxF '10.177.253.69 lus20-mds2' /etc/hosts || echo '10.177.253.69 lus20-mds2' >> /etc/hosts
  grep -qxF '10.177.253.68 lus20-mds1' /etc/hosts || echo '10.177.253.68 lus20-mds1' >> /etc/hosts
  grep -qxF 'lus20-mds2@tcp10:lus20-mds1@tcp10:/lus20 /lustre/scratch120 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus20-mds2@tcp10:lus20-mds1@tcp10:/lus20 /lustre/scratch120 lustre network=tcp10,localflock,noauto 0 0' >> /etc/fstab
fi
if grep -s  -E "(10.160.33.96|10.177.253.96)/27" \${ROUTES} ; then
  LUSTRE_INTERFACE=\$(grep -E "(10.160.33.96|10.177.253.96)/27" \${ROUTES} | awk '{print \$5}' )
  LNET="tcp11"
  grep -qxF '10.160.33.101  lus23-mds2' /etc/hosts || echo '10.160.33.101  lus23-mds2' >> /etc/hosts
  grep -qxF '10.160.33.100  lus23-mds1' /etc/hosts || echo '10.160.33.100  lus23-mds1' >> /etc/hosts
  grep -qxF 'lus23-mds2@tcp11:lus23-mds1@tcp11:/lus23 /lustre/scratch123 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus23-mds2@tcp11:lus23-mds1@tcp11:/lus23 /lustre/scratch123 lustre network=tcp11,localflock,noauto 0 0' >> /etc/fstab
  grep -qxF '10.177.253.101 lus20-mds2' /etc/hosts || echo '10.177.253.101 lus20-mds2' >> /etc/hosts
  grep -qxF '10.177.253.100 lus20-mds1' /etc/hosts || echo '10.177.253.100 lus20-mds1' >> /etc/hosts
  grep -qxF 'lus20-mds2@tcp11:lus20-mds1@tcp11:/lus20 /lustre/scratch120 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus20-mds2@tcp11:lus20-mds1@tcp11:/lus20 /lustre/scratch120 lustre network=tcp11,localflock,noauto 0 0' >> /etc/fstab
fi
if grep -s -E "(10.160.33.128|10.177.253.128)/27" \${ROUTES} ; then
  LUSTRE_INTERFACE=\$(grep  -E "(10.160.33.128|10.177.253.128)/27" \${ROUTES} | awk '{print \$5}' )
  LNET="tcp12"
  grep -qxF '10.160.33.133  lus23-mds2' /etc/hosts || echo '10.160.33.133  lus23-mds2' >> /etc/hosts
  grep -qxF '10.160.33.132  lus23-mds1' /etc/hosts || echo '10.160.33.132  lus23-mds1' >> /etc/hosts
  grep -qxF 'lus23-mds2@tcp12:lus23-mds1@tcp12:/lus23 /lustre/scratch123 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus23-mds2@tcp12:lus23-mds1@tcp12:/lus23 /lustre/scratch123 lustre network=tcp12,localflock,noauto 0 0' >> /etc/fstab
  grep -qxF '10.177.253.133 lus20-mds2' /etc/hosts || echo '10.177.253.133 lus20-mds2' >> /etc/hosts
  grep -qxF '10.177.253.132 lus20-mds1' /etc/hosts || echo '10.177.253.132 lus20-mds1' >> /etc/hosts
  grep -qxF 'lus20-mds2@tcp12:lus20-mds1@tcp12:/lus20 /lustre/scratch120 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus20-mds2@tcp12:lus20-mds1@tcp12:/lus20 /lustre/scratch120 lustre network=tcp12,localflock,noauto 0 0' >> /etc/fstab
fi
if grep -s -E "(10.160.33.160|10.177.253.160)/27" \${ROUTES} ; then
  LUSTRE_INTERFACE=\$(grep -E "(10.160.33.160|10.177.253.160)/27" \${ROUTES} | awk '{print \$5}' )
  LNET="tcp13"
  grep -qxF '10.160.33.165  lus23-mds2' /etc/hosts || echo '10.160.33.165  lus23-mds2' >> /etc/hosts
  grep -qxF '10.160.33.164  lus23-mds1' /etc/hosts || echo '10.160.33.164  lus23-mds1' >> /etc/hosts
  grep -qxF 'lus23-mds2@tcp13:lus23-mds1@tcp13:/lus23 /lustre/scratch123 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus23-mds2@tcp13:lus23-mds1@tcp13:/lus23 /lustre/scratch123 lustre network=tcp13,localflock,noauto 0 0' >> /etc/fstab
  grep -qxF '10.177.253.165 lus20-mds2' /etc/hosts || echo '10.177.253.165 lus20-mds2' >> /etc/hosts
  grep -qxF '10.177.253.164 lus20-mds1' /etc/hosts || echo '10.177.253.164 lus20-mds1' >> /etc/hosts
  grep -qxF 'lus20-mds2@tcp13:lus20-mds1@tcp13:/lus20 /lustre/scratch120 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus20-mds2@tcp13:lus20-mds1@tcp13:/lus20 /lustre/scratch120 lustre network=tcp13,localflock,noauto 0 0' >> /etc/fstab
fi
if grep -s -E "(10.160.33.192|10.177.253.192)/27" \${ROUTES} ; then
  LUSTRE_INTERFACE=\$(grep -E "(10.160.33.192|10.177.253.192)/27" \${ROUTES} | awk '{print \$5}' )
  LNET="tcp14"
  grep -qxF '10.160.33.197  lus23-mds2' /etc/hosts || echo '10.160.33.197  lus23-mds2' >> /etc/hosts
  grep -qxF '10.160.33.196  lus23-mds1' /etc/hosts || echo '10.160.33.196  lus23-mds1' >> /etc/hosts
  grep -qxF 'lus23-mds2@tcp14:lus23-mds1@tcp14:/lus23 /lustre/scratch123 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus23-mds2@tcp14:lus23-mds1@tcp14:/lus23 /lustre/scratch123 lustre network=tcp14,localflock,noauto 0 0' >> /etc/fstab
  grep -qxF '10.177.253.197 lus20-mds2' /etc/hosts || echo '10.177.253.197 lus20-mds2' >> /etc/hosts
  grep -qxF '10.177.253.196 lus20-mds1' /etc/hosts || echo '10.177.253.196 lus20-mds1' >> /etc/hosts
  grep -qxF 'lus20-mds2@tcp14:lus20-mds14@tcp1:/lus20 /lustre/scratch120 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus20-mds2@tcp14:lus20-mds1@tcp14:/lus20 /lustre/scratch120 lustre network=tcp14,localflock,noauto 0 0' >> /etc/fstab
fi
if grep -s -E "(10.160.33.224|10.177.253.224)/27" \${ROUTES} ; then
  LUSTRE_INTERFACE=\$(grep -E "(10.160.33.224|10.177.253.224)/27" \${ROUTES} | awk '{print \$5}' )
  LNET="tcp15"
  grep -qxF '10.160.33.229  lus23-mds2' /etc/hosts || echo '10.160.33.229  lus23-mds2' >> /etc/hosts
  grep -qxF '10.160.33.228  lus23-mds1' /etc/hosts || echo '10.160.33.228  lus23-mds1' >> /etc/hosts
  grep -qxF 'lus23-mds2@tcp15:lus23-mds1@tcp15:/lus23 /lustre/scratch123 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus23-mds2@tcp15:lus23-mds1@tcp15:/lus23 /lustre/scratch123 lustre network=tcp15,localflock,noauto 0 0' >> /etc/fstab
  grep -qxF '10.177.253.229 lus20-mds2' /etc/hosts || echo '10.177.253.229 lus20-mds2' >> /etc/hosts
  grep -qxF '10.177.253.228 lus20-mds1' /etc/hosts || echo '10.177.253.228 lus20-mds1' >> /etc/hosts
  grep -qxF 'lus20-mds2@tcp15:lus20-mds1@tcp15:/lus20 /lustre/scratch120 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus20-mds2@tcp15:lus20-mds1@tcp15:/lus20 /lustre/scratch120 lustre network=tcp15,localflock,noauto 0 0' >> /etc/fstab
fi
if grep -s -E "(10.160.34.0|10.177.254.0)/27" \${ROUTES} ; then
  LUSTRE_INTERFACE=\$(grep -E "(10.160.34.0|10.177.254.0)/27" \${ROUTES} | awk '{print \$5}' )
  LNET="tcp16"
  grep -qxF '10.160.34.5  lus23-mds2' /etc/hosts || echo '10.160.34.5  lus23-mds2' >> /etc/hosts
  grep -qxF '10.160.34.4  lus23-mds1' /etc/hosts || echo '10.160.34.4  lus23-mds1' >> /etc/hosts
  grep -qxF 'lus23-mds2@tcp16:lus23-mds1@tcp16:/lus23 /lustre/scratch123 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus23-mds2@tcp16:lus23-mds1@tcp16:/lus23 /lustre/scratch123 lustre network=tcp16,localflock,noauto 0 0' >> /etc/fstab
  grep -qxF '10.177.254.5 lus20-mds2' /etc/hosts || echo '10.177.254.5 lus20-mds2' >> /etc/hosts
  grep -qxF '10.177.254.4 lus20-mds1' /etc/hosts || echo '10.177.254.4 lus20-mds1' >> /etc/hosts
  grep -qxF 'lus20-mds2@tcp16:lus20-mds1@tcp16:/lus20 /lustre/scratch120 lustre localflock,noauto 0 0' /etc/fstab || echo '#lus20-mds2@tcp16:lus20-mds1@tcp16:/lus20 /lustre/scratch120 lustre network=tcp16,localflock,noauto 0 0' >> /etc/fstab
fi

# don't accept connections
echo "options lnet networks=\"\$LNET(\$LUSTRE_INTERFACE)\" accept=none lnet_peer_discovery_disabled=1" > /etc/modprobe.d/lustreclient.conf

IP=\$(ip a show dev \${LUSTRE_INTERFACE} | awk '/inet / {print \$2}' | sed -s 's#/.*\$##' )

if [ -z "\${ROUTER1}" ] ; then
  cat /etc/lnet.conf-template-direct | sed -e "s/LUSTRE_NETWORK/\$LNET/g" -e "s/LUSTRE_INTERFACE/\$LUSTRE_INTERFACE/g" > /etc/lnet.conf
  cat << EOT > /etc/netplan/60-lustre_nets.yaml
network:
    version: 2
    renderer: NetworkManager
    ethernets:
        ens4:
            optional: true
            dhcp4: true
        ens5:
            optional: true
            dhcp4: true
        ens6:
            optional: true
            dhcp4: true
        ens7:
            optional: true
            dhcp4: true
        ens8:
            optional: true
            dhcp4: true
        ens9:
            optional: true
            dhcp4: true
        ens10:
            optional: true
            dhcp4: true
        ens11:
            optional: true
            dhcp4: true
EOT
else
  cat /etc/lnet.conf-template-router | sed -e "s/LUSTRE_NETWORK/\$LNET/g" -e "s/LUSTRE_INTERFACE/\$LUSTRE_INTERFACE/g" -e "s/ROUTER1/\$ROUTER1/g" -e "s/ROUTER2/\$ROUTER2/g" -e "s/ROUTER3/\$ROUTER3/g" -e "s/ROUTER4/\$ROUTER4/g" > /etc/lnet.conf
  cat << EOT > /etc/netplan/60-lustre_nets.yaml
network:
    version: 2
    renderer: NetworkManager
    ethernets:
        ens4:
            optional: true
            dhcp4: true
            mtu: 1500
            dhcp4-overrides:
               use-mtu: false
               use-routes: false
        ens5:
            optional: true
            dhcp4: true
            mtu: 1500
            dhcp4-overrides:
               use-mtu: false
               use-routes: false
        ens6:
            optional: true
            dhcp4: true
            mtu: 1500
            dhcp4-overrides:
               use-mtu: false
               use-routes: false
EOT
fi
EOF

chmod 755 /usr/local/sbin/lustre-config-setup

cat << EOF > /etc/systemd/system/lustre-config-setup.service
[Unit]
Description=lustre config autoconfig
After=network-online.target
Wants=network-online.target
Before=lnet.service

ConditionPathExists=!/proc/sys/lnet/

[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=/usr/local/sbin/lustre-config-setup

[Install]
WantedBy=multi-user.target
EOF

cat << 'EOF' > /etc/default/lustre-mount
tries=30
found="false"
while ! [ $found = "true" -o $tries -eq 0 ]
do
  for nid in $( cat /etc/fstab | sed -e 's/^#//'|  awk -F: '/\slustre\s/ { printf("%s %s ", $1,$2);}' )
  do
    if lctl ping $nid ; then
      found="true"
      sed -e "/^#.*$nid.*\slustre\s/ s/^#\(.*\)/\1/"  -i /etc/fstab
    fi
    sleep 1
  done
  let "tries=tries-1"
done
sleep 5
EOF

# Need a less buggy bit of networking code
# That accepts turning routes off

apt-get -y install network-manager netplan.io

cat << EOF > /etc/netplan/60-lustre_nets.yaml
network:
    version: 2
    renderer: NetworkManager
    ethernets:
        ens4:
            optional: true
            dhcp4: true
        ens5:
            optional: true
            dhcp4: true
        ens6:
            optional: true
            dhcp4: true
        ens7:
            optional: true
            dhcp4: true
        ens8:
            optional: true
            dhcp4: true
        ens9:
            optional: true
            dhcp4: true
        ens10:
            optional: true
            dhcp4: true
        ens11:
            optional: true
            dhcp4: true
EOF

netplan generate

systemctl daemon-reload
systemctl enable lustre-config-setup
systemctl enable lustre-tune.service
systemctl enable mountLustre.service

LUSTRE_VERSION="2.12.5-sanger1-1"
CLIENT_MODULES="lustre-client-modules-dkms_${LUSTRE_VERSION}_amd64.deb"
CLIENT_UTILS="lustre-client-utils_${LUSTRE_VERSION}_amd64.deb"
curl "https://cog.sanger.ac.uk/lustre_debs/${CLIENT_MODULES}" -o "/tmp/${CLIENT_MODULES}"
curl "https://cog.sanger.ac.uk/lustre_debs/${CLIENT_UTILS}"   -o "/tmp/${CLIENT_UTILS}"
dpkg -i "/tmp/${CLIENT_MODULES}" "/tmp/${CLIENT_UTILS}"
systemctl enable lnet.service 
systemctl daemon-reload

