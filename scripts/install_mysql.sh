#!/bin/bash -x

echo DEBUG: USER = ${USER}
lsb_release -a

## This will be changed by cloud-init
MYSQL_PASSWORD=supersecret

if [ "$USER" == "ubuntu" ] ; then
    wget https://repo.percona.com/apt/percona-release_0.1-4.$(lsb_release -sc)_all.deb
    dpkg -i percona-release_0.1-4.$(lsb_release -sc)_all.deb
    apt-get update
    /bin/echo percona-server-server-5.7 percona-server-server-5.7/root-pass password ${MYSQL_PASSWORD} | debconf-set-selections
    /bin/echo percona-server-server-5.7 percona-server-server-5.7/re-root-pass password ${MYSQL_PASSWORD} | debconf-set-selections
    apt-get -y install percona-server-server-5.7 percona-toolkit percona-xtrabackup-24
fi
if [ "$USER" == "centos" ] ; then
    yum install -y http://www.percona.com/downloads/percona-release/redhat/0.1-3/percona-release-0.1-3.noarch.rpm
    yum install -y Percona-Server-server-57 percona-toolkit percona-xtrabackup-24
    mysqladmin password ${MYSQL_PASSWORD}
fi
