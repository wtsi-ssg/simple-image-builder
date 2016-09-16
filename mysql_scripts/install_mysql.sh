#!/bin/bash

## This will be changed by cloud-init
MYSQL_PASSWORD=supersecret

if [ "$USER" == "ubuntu" ] ; then
    PACKAGES="mysql-server-5.6"
    export DEBIAN_FRONTEND=noninteractive
    if ( apt-get -y install ${PACKAGES} ) ; then
            mysqladmin password ${MYSQL_PASSWORD}
    fi
fi
if [ "$USER" == "centos" ] ; then
    yum install -y mariadb-server mariadb
    systemctl start mariadb.service
    systemctl enable mariadb.service
    mysqladmin password ${MYSQL_PASSWORD}
fi

