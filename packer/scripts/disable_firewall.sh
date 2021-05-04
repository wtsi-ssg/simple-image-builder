#!/bin/bash
set -e
TYPE=$(python -mplatform | sed -e 's/.*focal.*/ubuntu/i' -e 's/.*centos.*/centos/i' -e 's/.*xenial.*/ubuntu/i'  -e 's/.*bionic.*/ubuntu/i' )
case ${TYPE} in
  centos)
       systemctl disable firewalld
    ;;
esac
