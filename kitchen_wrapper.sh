#!/bin/bash 

function cat_logs {
  for i in .kitchen/logs/* ; do
    echo
    echo "${i}"
    echo
    cat "${i}" | sed -e "s/${ANSIBLE_READ_SECRET}/ANSIBLE_READ_SECRET/g" -e "s/${CIFS_PASSWORD}/CIFS_PASSWORD/g" \
	             -e "s/${IRODS_PASSWORD}/IRODS_PASSWORD/g" -e "s/${OS_PASSWORD}/OS_PASSWORD/g" \
		     -e "s/${VMWARE_PASSWORD}/VMWARE_PASSWORD/g"
  done
}
        
function debug_out {  
  if [ "$DEBUG" == "1" ]
    then
      echo "${1}" 
  fi
}  

function run_test {
KITCHEN_FLAGS=""
if [ "${DEBUG}" == "1" ]
  then
    echo "Keypair : ${KEYPAIR}"
    cat "${KEYPAIR_FILENAME}"
    kitchen diagnose | sed -e "s/${ANSIBLE_READ_SECRET}/ANSIBLE_READ_SECRET/g" -e "s/${CIFS_PASSWORD}/CIFS_PASSWORD/g" \
	                   -e "s/${IRODS_PASSWORD}/IRODS_PASSWORD/g" -e "s/${OS_PASSWORD}/OS_PASSWORD/g" \
	                   -e "s/${VMWARE_PASSWORD}/VMWARE_PASSWORD/g"
    KITCHEN_FLAGS="-l debug" 
fi
echo -e "section_start:`date +%s`:kitchen_destroy\r\e[0KCleaning up any previous runs"
kitchen destroy
echo -e "section_end:`date +%s`:kitchen_destroy\r\e[0K"
echo -e "section_start:`date +%s`:kitchen_create\r\e[0KCreating instance"
kitchen create ${KITCHEN_FLAGS} > >(tee -a "/tmp/stdout-${BUILD}.log") 2> >(tee -a "/tmp/stderr-${BUILD}.log" >&2)  || {
  ERR=$?
  cat_logs
  if [ $ERR -ne 0 ] ; then kitchen diagnose --all ; kitchen diagnose --no-instances --loader; fi
  exit $ERR
}
echo -e "section_end:`date +%s`:kitchen_create\r\e[0K"
echo -e "section_start:`date +%s`:kitchen_converge\r\e[0KRunning kitchen converge"
kitchen converge ${KITCHEN_FLAGS} > >(tee -a "/tmp/stdout-${BUILD}.log") 2> >(tee -a "/tmp/stderr-${BUILD}.log" >&2)  || {
  ERR=$?
  cat_logs
  if [ $ERR -ne 0 ] ; then kitchen diagnose --all ; kitchen diagnose --no-instances --loader; fi
  exit $ERR
}
echo -e "section_end:`date +%s`:kitchen_converge\r\e[0K"
echo -e "section_start:`date +%s`:kitchen_setup\r\e[0KRunning kitchen setup"
kitchen setup ${KITCHEN_FLAGS} > >(tee -a "/tmp/stdout-${BUILD}.log") 2> >(tee -a "/tmp/stderr-${BUILD}.log" >&2) || {
  ERR=$?
  cat_logs
  if [ $ERR -ne 0 ] ; then kitchen diagnose --all ; fi
  exit $ERR
}
echo -e "section_end:`date +%s`:kitchen_setup\r\e[0K"
echo -e "section_start:`date +%s`:kitchen_verify\r\e[0KStarting kitchen verify, including running the actual tests"
kitchen verify ${KITCHEN_FLAGS} > >(tee -a "/tmp/stdout-${BUILD}.log") 2> >(tee -a "/tmp/stderr-${BUILD}.log" >&2) || {
  ERR=$?
  cat_logs
  if [ $ERR -ne 0 ] ; then kitchen diagnose --all ; kitchen diagnose --no-instances --loader ; fi
  if [ "$DEBUG" == "1" ]
  then
    echo "cat << EOF > /tmp/tmp_key.$$"
    cat "${KEYPAIR_FILENAME}"
    echo "EOF"
    echo "chmod 0700  /tmp/tmp_key.$$"
    IP=$(grep "Attaching floating IP" "/tmp/stdout-${BUILD}.log" | tail -1 | sed -e 's/^.*<//' -e 's/>$//' -e 's/ *//g')
    echo "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o IdentityFile=/tmp/tmp_key.$$ -o IdentitiesOnly=yes ${IMAGE_USERNAME}@${IP} -i /tmp/tmp_key.$$"
    echo "rm /tmp/tmp_key.$$"
    let TOTAL_TIME=${SLEEPTIME:=1200}
    let EACH_LOOP=TOTAL_TIME/100
    for ((n=1;n<101;n++))
    do
      echo "$n of 100...."
      sleep ${EACH_LOOP}
    done
  else
    echo "Set DEBUG to 1 to allow login to failed instance"
  fi
  rm -f "/tmp/stdout-${BUILD}.log" "/tmp/stderr-${BUILD}.log"
  kitchen destroy
  openstack keypair delete "${KEYPAIR}"
  exit $ERR
 }
echo -e "section_end:`date +%s`:kitchen_verify\r\e[0K"
IP=$(grep "Attaching floating IP" "/tmp/stdout-${BUILD}.log" | tail -1 | sed -e 's/^.*<//' -e 's/>$//' -e 's/ *//')
}

BUILD="${CI_BUILD_REF}_$(date +%Y%m%d%H%M%S)_${MODE}"
export BUILD
export KEYPAIR="${CI_BUILD_ID}${MODE}"
export KEYPAIR_FILENAME="${KEYPAIR}"
openstack keypair create "${KEYPAIR}" > "${KEYPAIR_FILENAME}"
chmod 700 "${KEYPAIR_FILENAME}"
run_test
rm -f "/tmp/stdout-${BUILD}.log"  "/tmp/stderr-${BUILD}.log"
kitchen destroy
openstack keypair delete "${KEYPAIR}"
