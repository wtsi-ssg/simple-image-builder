#!/bin/bash -eux

apt-get update
apt-get -y upgrade
apt-get -y dist-upgrade
apt-get -y autoclean

# ensure the correct kernel headers are installed
apt-get -y install linux-headers-$(uname -r)

apt-get install -y accountsservice acpid adduser alien apparmor apport\
				apport-symptoms apt aptitude aptitude-common apt-transport-https apt-utils\
				apt-xapian-index at automake autotools-dev base-files base-passwd bash\
				bash-completion bc bind9-host biosdevname bsdmainutils bsdutils build-essential\
				busybox-initramfs busybox-static byobu bzip2 ca-certificates cloud-guest-utils\
				command-not-found command-not-found-data console-setup coreutils cpio cron\
				cryptsetup cryptsetup-bin curl cvs dash dbus debconf debconf-i18n debianutils\
				dh-python diffutils dkms dmidecode dmsetup dnsutils dosfstools dpkg e2fslibs\
				e2fsprogs eatmydata ed eject ethtool fakeroot file findutils\
				fonts-ubuntu-font-family-consol friendly-recovery ftp fuse gawk gcc-4.8-base\
				gcc-4.9-base gdisk geoip-database gettext-base gir1.2-glib-2.0 git gnupg gpgv\
				grep groff-base grub-common grub-legacy-ec2 grub-pc gzip hdparm hostname\
				ifupdown info initramfs-tools initramfs-tools-bin initscripts\
				init-system-helpers insserv installation-report install-info iproute2 iptables\
				iputils-ping iputils-tracepath irqbalance isc-dhcp-client isc-dhcp-common\
				iso-codes kbd keyboard-configuration klibc-utils kmod krb5-locales\
				landscape-client landscape-common language-pack-en language-pack-gnome-en\
				language-selector-common laptop-detect less libaccountsservice0 libacl1\
				libapparmor1 libapparmor-perl libapt-inst1.5 libapt-pkg4.12\
				libarchive-extract-perl libasn1-8-heimdal libasprintf0c2 libattr1 libaudit1\
				libaudit-common libbind9-90 libblkid1 libboost-iostreams1.54.0 libbsd0\
				libbz2-1.0 libc6 libcap2 libcap2-bin libcap-ng0 libc-bin libcgmanager0\
				libck-connector0 libclass-accessor-perl libcomerr2 libcryptsetup4 libcurl3\
				libcurl3-gnutls libcwidget3 libdb5.3 libdbus-1-3 libdbus-glib-1-2\
				libdebconfclient0 libdevmapper1.02.1 libdns100 libdrm2 libedit2 libelf1\
				libept1.4.12 libestr0 libevent-2.0-5 libexpat1 libffi6 libfribidi0 libfuse2\
				libgc1c2 libgcc1 libgck-1-0 libgcr-3-common libgcr-base-3-1 libgcrypt11 libgdbm3\
				libgeoip1 libgirepository-1.0-1 libglib2.0-0 libglib2.0-data libgnutls26\
				libgnutls-openssl27 libgpg-error0 libgpm2 libgssapi3-heimdal libgssapi-krb5-2\
				libhcrypto4-heimdal libheimbase1-heimdal libheimntlm0-heimdal libhx509-5-heimdal\
				libicu52 libidn11 libio-string-perl libisc95 libisccc90 libisccfg90 libjson0\
				libjson-c2 libk5crypto3 libkeyutils1 libklibc libkmod2 libkrb5-26-heimdal\
				libkrb5-3 libkrb5support0 libldap-2.4-2 liblocale-gettext-perl liblockfile1\
				liblockfile-bin liblog-message-simple-perl liblwres90 liblzma5 libmagic1\
				libmodule-pluggable-perl libmount1 libmpdec2 libncurses5 libncursesw5\
				libnewt0.52 libnfnetlink0 libnih1 libnih-dbus1 libnuma1 libp11-kit0 libpam0g\
				libpam-cap libpam-modules libpam-modules-bin libpam-runtime libpam-systemd\
				libparse-debianchangelog-perl libparted0debian1 libpcap0.8 libpci3 libpcre3\
				libpipeline1 libplymouth2 libpng12-0 libpod-latex-perl libpolkit-agent-1-0\
				libpolkit-backend-1-0 libpolkit-gobject-1-0 libpopt0 libprocps3 libpython2.7\
				libpython2.7-minimal libpython2.7-stdlib libpython3.4-minimal\
				libpython3.4-stdlib libpython3-stdlib libpython-stdlib libreadline6\
				libroken18-heimdal librtmp0 libsasl2-2 libsasl2-modules libsasl2-modules-db\
				libselinux1 libsemanage1 libsemanage-common libsepol1 libsigc++-2.0-0c2a\
				libsigsegv2 libslang2 libsqlite3-0 libss2 libssl1.0.0 libstdc++6\
				libsub-name-perl libsystemd-daemon0 libsystemd-login0 libtasn1-6 libterm-ui-perl\
				libtext-charwidth-perl libtext-iconv-perl libtext-soundex-perl\
				libtext-wrapi18n-perl libtimedate-perl libtinfo5 libtool libudev1 libusb-0.1-4\
				libusb-1.0-0 libustr-1.0-1 libuuid1 libwind0-heimdal libwrap0 libx11-6\
				libx11-data libxapian22 libxau6 libxcb1 libxdmcp6 libxext6 libxml2 libxmuu1\
				libxtables10 libyaml-0-2 linux-generic-lts-wily locales lockfile-progs login\
				logrotate lsb-base lsb-release lshw lsof ltrace lvm2 makedev man-db manpages\
				mawk mime-support mlocate module-assistant module-init-tools mount mountall\
				mtr-tiny multiarch-support nano ncurses-base ncurses-bin ncurses-term netbase\
				netcat-openbsd net-tools ntfs-3g ntpdate openssh-client openssh-server\
				openssh-sftp-server openssl open-vm-tools overlayroot parted passwd patch\
				pciutils perl perl-base perl-modules plymouth plymouth-theme-ubuntu-text\
				policykit-1 pollinate popularity-contest powermgmt-base ppp pppoeconf procps\
				psmisc pwgen python python2.7 python2.7-minimal python3 python3.4\
				python3.4-minimal python3-apport python3-apt python3-commandnotfound\
				python3-dbus python3-distupgrade python3-gdbm python3-gi python3-minimal\
				python3-newt python3-problem-report python3-pycurl python3-software-properties\
				python3-update-manager python-apt python-apt-common python-chardet\
				python-cheetah python-configobj python-debian python-gdbm python-jsonpatch\
				python-json-pointer python-minimal python-oauth python-openssl python-pam\
				python-pkg-resources python-prettytable python-pycurl python-requests\
				python-serial python-six python-twisted-bin python-twisted-core\
				python-twisted-names python-twisted-web python-urllib3 python-xapian python-yaml\
				python-zope.interface quilt readline-common resolvconf rsync rsyslog run-one\
				screen sed sensible-utils sgml-base shared-mime-info software-properties-common\
				ssh-import-id subversion sudo systemd-services systemd-shim sysvinit-utils\
				sysv-rc tar tasksel tasksel-data tcpd tcpdump telnet time tmux tzdata\
				ubuntu-keyring ubuntu-minimal ubuntu-release-upgrader-core ubuntu-standard ucf\
				udev ufw unattended-upgrades update-manager-core update-notifier-common upstart\
				ureadahead usbutils util-linux uuid-runtime vim vim-common vim-runtime vim-tiny\
				w3m wget whiptail xauth xkb-data xml-core xz-utils zerofree zlib1g\

apt-get -y clean

#we have to reboot here, so the re-build of the virtualbox additions links against the new kernel/headers
reboot

#make sure we wait for the reboot, otherwise we will run in ugly race conditions
sleep 999999 
