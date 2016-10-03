#!/bin/bash

## This will be changed by cloud-init
MYSQL_PASSWORD=supersecret

if [ -e /etc/debian_version ] ; then
    # actually Ubuntu...
    wget https://repo.percona.com/apt/percona-release_0.1-4.$(lsb_release -sc)_all.deb
    dpkg -i percona-release_0.1-4.$(lsb_release -sc)_all.deb
    apt-get update
    /bin/echo percona-server-server-5.7 percona-server-server-5.7/root-pass password ${MYSQL_PASSWORD} | debconf-set-selections
    /bin/echo percona-server-server-5.7 percona-server-server-5.7/re-root-pass password ${MYSQL_PASSWORD} | debconf-set-selections
    apt-get -y install percona-server-server-5.7 percona-toolkit percona-xtrabackup-24
elif [ -e /etc/centos-release ] ; then
    # need to remove mariadb before installing percona to avoid conflicts
    yum remove mariadb-devel mariadb-libs
    yum install -y http://www.percona.com/downloads/percona-release/redhat/0.1-3/percona-release-0.1-3.noarch.rpm
    yum install -y Percona-Server-server-57 percona-toolkit percona-xtrabackup-24
    systemctl start mysqld
    # hoopla because root's password is randomly set, and starts off expired
    GENPW=`grep "generated for root" /var/log/mysqld.log | sed 's/.*localhost: //'`
    mysqladmin --password="$GENPW" password C0mp-leX
    mysql --password=C0mp-leX mysql -e "uninstall plugin validate_password;"
    mysqladmin --password=C0mp-leX password ${MYSQL_PASSWORD}
else
    echo ""
    echo "Couldn't identify OS - help!"
    echo ""
    exit 1
fi
