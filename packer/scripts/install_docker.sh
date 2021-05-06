#!/bin/bash

ancient_init_system()
{
	tee /etc/default/docker <<-'EOF'
	# Docker Upstart and SysVinit configuration file

	#
	# THIS FILE DOES NOT APPLY TO systemd
	#
	#   Please see the documentation for "systemd drop-ins":
	#   https://docs.docker.com/engine/articles/systemd/
	#

	# Customize location of Docker binary (especially for development testing).
	#DOCKERD="/usr/local/bin/dockerd"

	# Use DOCKER_OPTS to modify the daemon startup options.
	DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4 --bip=192.168.3.3/24 --mtu=1380 --registry-mirror=https://docker-hub-mirror.internal.sanger.ac.uk:5000"


	# If you need Docker to use an HTTP proxy, it can also be specified here.
	#export http_proxy="http://127.0.0.1:3128/"

	# This is also a handy place to tweak where Docker's temporary files go.
	#export TMPDIR="/mnt/bigdrive/docker-tmp"
	EOF
}

systemdsetup()
{
	mkdir /etc/docker
	chmod 0700 /etc/docker
	if [ -z "${DID}" ] ; then
	tee /etc/docker/daemon.json <<-EOF
{
  "bip": "192.168.3.3/24",
  "mtu": 1380,
  "registry-mirrors": [
    "https://docker-hub-mirror.internal.sanger.ac.uk:5000"
  ],
  "default-address-pools": [
    {
      "base": "192.168.4.0/16",
      "size": 24
    }
  ]
}
	EOF
        else
        tee /etc/docker/daemon.json <<-EOF
{
  "bip": "192.168.3.3/24",
  "mtu": 1380,
  "registry-mirrors": [
    "https://docker-hub-mirror.internal.sanger.ac.uk:5000"
  ],
  "default-address-pools": [
    {
      "base": "192.168.4.0/16",
      "size": 24
    }
  ],
  "default-runtime": "sysbox-runc",
  "runtimes": {
    "sysbox-runc": {
      "path": "/usr/local/sbin/sysbox-runc"
    }
  }
}

	EOF
        fi
}

apt_install()
{
	apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	apt-get update
	apt-get install -y docker-ce docker-ce-cli containerd.io
	adduser ubuntu docker
}

docker_in_docker()
{
        if [ -n "${DID}" ] ; then
          echo "Installing Docker in Docker support"
          cd /tmp || exit
          wget https://github.com/nestybox/sysbox/releases/download/v0.2.1/sysbox_0.2.1-0.ubuntu-focal_amd64.deb
          apt-get install -y jq libjq1
          apt-get install ./sysbox_0.2.1-0.ubuntu-focal_amd64.deb -y
        fi
}

yum_install()
{
	yum update
	yum install -y yum-utils
	yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
	yum update
	yum install -y docker-ce docker-ce-cli containerd.io
	usermod -aG docker centos
}

servicestart()
{
	service docker start
}

systemdstart()
{
	systemctl enable docker.service
	systemctl start docker
}

if [ -z "$CONTAINER" ] ; then
	echo "Skipping as CONTAINER not defined"
	exit 0
fi

groupadd docker
PLATFORM=$(python2 -mplatform | sed -e 's/.*focal.*/focal/i' -e 's/.*centos.*/centos/i' -e 's/.*xenial.*/xenial/i' -e 's/.*bionic.*/bionic/i')
case ${PLATFORM} in
	focal)
		DID="" systemdsetup
		apt_install
		systemdstart
	        docker_in_docker
                systemdsetup
		;;
        bionic)
                systemdsetup
                apt_install
                systemdstart
                ;;
	centos)
		systemdsetup
		yum_install
		systemdstart
		;;
esac
#this is the docker docs suggested way to install compose, yes vile
curl -L https://github.com/docker/compose/releases/download/1.18.0/run.sh > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

exit 0

