#!/bin/bash
set -e
if [ -n "${CI_STORE_IMAGE}" ] ; then 
  . $(packer/scripts/make_venv.sh | tail -1 )/bin/activate
  cd packer
  mkdir -p /warehouse/isg_warehouse /mnt/smb
  if [ -z "${CIFS_USERNAME}" ] ; then 
    echo "CIFS_USERNAME not set" 
    exit 1 
  fi 
  if [ -z "${CIFS_PASSWORD}" ] ; then 
    echo "CIFS_PASSWORD not set" 
    exit 1 
  fi 
  mount -o rw,nolock,vers=3,tcp "${NFS_HOST_IP}:/data" /warehouse/isg_warehouse 
  mkdir -p /warehouse/isg_warehouse/SciaaS_images/openstack
  export OS_FLAVOR_NAME="${LARGEST_FLAVOR_NAME}"
  if [ -n "${NEEDS_CLOUD_INIT}" ] ; then
    export LIBGUESTFS_BACKEND="direct"
    TYPE=$(python -mplatform | sed -e 's/.*trusty.*/ubuntu/i' -e 's/.*centos.*/centos/i' -e 's/.*xenial.*/ubuntu/i'  -e 's/.*bionic.*/ubuntu/i' -e 's/.*redhat.*/redhat/' )
    case ${TYPE} in
      centos|redhat)
        export LIBGUESTFS_CMD="yum -y install cloud-init"
        ;;
      ubuntu)
        export LIBGUESTFS_CMD="apt-get install cloud-init"
        ;;
    esac
    export OS_FLAVOR_NAME="${LARGEST_FLAVOR_NAME}"
    export LIBGUESTFS_BACKEND="direct"
  fi
  echo "${IMAGE_NAME}_${CI_BUILD_REF}"
  ./cleanup.py -dt "${IMAGE_NAME}_${CI_BUILD_REF}" "${IMAGE_NAME}"
  cd /warehouse/isg_warehouse/SciaaS_images/openstack/
  QCOW="$(echo ${IMAGE_NAME}*${CI_BUILD_REF}.qcow)"
  UPLOAD="$(echo ${IMAGE_NAME}*${CI_BUILD_REF}.qcow.upload)"
  echo smbclient -W "${CIFS_DOMAIN}" -U "${CIFS_USERNAME}%password" "${CIFS_PATH}"  -c "put ${QCOW}"
  echo smbclient -W "${CIFS_DOMAIN}" -U "${CIFS_USERNAME}%password" "${CIFS_PATH}"  -c "put ${UPLOAD}"
  smbclient -W "${CIFS_DOMAIN}" -U "${CIFS_USERNAME}%${CIFS_PASSWORD}" "${CIFS_PATH}"  -c "put ${QCOW} SciaaS_images/openstack/${QCOW}"
  smbclient -W "${CIFS_DOMAIN}" -U "${CIFS_USERNAME}%${CIFS_PASSWORD}" "${CIFS_PATH}"  -c "put ${UPLOAD} SciaaS_images/openstack/${UPLOAD}"
  rm "${QCOW}" "${UPLOAD}"
else
  echo "Removing image ${IMAGE_NAME}_${CI_BUILD_REF}" 
  openstack image delete "${IMAGE_NAME}_${CI_BUILD_REF}"
fi

