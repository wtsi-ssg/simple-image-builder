# Example Image builder

These are scripts to build a Ubuntu 14.04,16.04 and Centos 7.2 image. 
- Openstack 

The system is controlled via variables.json and .gitlab-ci.yml and finally the variables configured by the repository.

The variables that need to be defined are:

OS_TENANT_NAME which should be set to the tenant, each group should have their own tenant for ci jobs.

OS_USERNAME this should normally be the same as the OS_TENANT by convention

OS_PASSWORD this is the password for the OS_USERNAME

There is a branch named vmware which extends the system to support vmware...

## extra_script

An additional script to run to configure this image - this script must exist, if no additional customization is required this should be a "NOOP" script

## scripts

This directory contains the scripts used additional software. 

## ansible

This directory by default is linked to the image-creation repository, if you wish to use ansible to configure you system then you will need to remove the symbolic link and copy the contents of image-creation/packer/ansible to ansible and then make changes. If additional roles are required they should be listed in variables.json as a role_path


