#!/bin/bash
#
# install_cloud-init.sh
#  Installs the cloud init package after building
#

function cloud-init {
	CLOUD_FILE=$1; DEVICE=$2

        PLATFORM=$(python -mplatform)

        if [ "$( echo "$PLATFORM" | sed -e 's/.*ubuntu.*/ubuntu/i')" = "ubuntu" ] ; then
          apt-get -y install cloud-init patch
        fi

        if [ "$( echo "$PLATFORM" | sed -e 's/.*redhat.*/redhat/i')" = "redhat" ] ; then
          yum install -y cloud-init patch
	fi
}


function main {
	echo "Installing cloud-init"
	case ${PACKER_BUILDER_TYPE} in
		null)
			CLOUD_FILE=/tmp/cloud.cfg
			DEVICE=/dev/null
		;;
		openstack)
			CLOUD_FILE=/etc/cloud/cloud.cfg
			DEVICE=/dev/vdb
		;;
		virtualbox-iso)
			CLOUD_FILE=/etc/cloud/cloud.cfg
			DEVICE=/dev/sdb
		;;
		*)
			echo "Unknown builder!"
			exit 1
		;;
	esac

	cloud-init ${CLOUD_FILE} ${DEVICE}
}

main
