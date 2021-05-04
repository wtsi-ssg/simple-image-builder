# Image Creation
This repository contains scripts to build images on:
- Virtual Box
- Openstack   

Currently Ubuntu 18.04, Ubuntu 20.04 and Centos 7 are supported.
## Usage

**Legacy:** *./packer.sh (build|validate) (virtualbox|openstack|all)*  
./create_image.py (build|validate) [options]

This will build images for the supplied platform(s) or all. If the option validate is issued then the template will only be checked for syntax.

## Prequisites

- Packer version 1.6.1 (or later), this can be set either in the path, as an environment variable $PACKER_BIN or on the command line. If none of these are set then ./create_image.py will try and use the copy of packer in /software
- Openstack packages
- python packages:  
  - python-glanceclient  
  - python-novaclient  
  - python-openstackclient  
  - argparse  
  - random  
  - string  
  - os  
  - subprocess  
  - sys  


## Openstack Credentials

The openstack credentials & environment is configured in the **remote_username**


- COMPUTE_API_VERSION

Version required to support openstack clients (1.1 minimum)

- OS_CLOUDNAME

Name of the cloud to connect to (in the event of multiple cloud environments)

- OS_AUTH_URL

URL of the API endpoint

- NOVA_VERSION

Should match the COMPUTE_API_VERSION above.

- OS_USERNAME

** Defined in Variables section of project settings ** Username to connect to the openstack environment with

- OS_PASSWORD

** Defined in Variables section of project settings ** Password for the above user

- OS_TENANT_NAME

** Defined in Variables section of project settings ** Tenant within openstack to use for the build

- OS_BASE_IMAGE

Base image ID to use for the build

- OS_SECURITY_GRP

Security group to apply to the build (must allow SSH access to the booted image)

- OS_NETWORK_IDS

The network(s) on which to build and test. Only necessary in tenants with more than 1 network

## CIFS Credentials

If CI_STORE_IMAGE is set then the images will be stored via cifs

- CIFS_PATH for example: //172.30.139.13/isg_warehouse

- CIFS_USERNAME for example: image_creator note the lack of SANGER/ this should be a service account as the password is specified in the below variable

- CIFS_PASSWORD

## 

## Variables

The files *variables.json* contains default configuration variables required to build the image important variables are:-

### packer_username &  packer_password
The username & password that will be burnt into the image as a default user

### extra_script
An additional script to run to configure this image - this script must exist, if no additional customization is required this should be a "NOOP" script (eg /bin/true)
### directory 
The directory variable is a file path to the image-creation/ubuntu14.04 directory. This is useful if this repository is being used as a subrepo. This is how the majority of the images are being built in the SciaaS area of gitlab. If you have simply cloned the image and want to run it inside this repository then simply leave the value as '.' 


## Scripts

The scripts directory contains provisioner scripts that are called by packer to customize the image.

- compiler_tools.sh

Installs the packages require to bulid software & linux kernel

- sudoers.sh

Updates the sudoers file

- update.sh

Updates all packages to the latest version (apt-get ugrade / dist-upgrade) and purges the cache

- install_cloud-init.sh

Installs the cloud-init package used for per-instance configuration of the machine.

This script also patches the cc_disk_setup.py module of cloud init to fix a bug in version 0.7.5. The script will check that the file is the correct one before attempting to patch.

The Cloud-init configuration is updated to cause the initialization & mounting of the first extra disk (the name of this is dependant on the hypervisor in use - vdb for openstack or sdb for vmware/virtualbox)

# Contributing
**All commits to the master branch should only be done after thorough testing on another branch. Any commit to the master branch should have a tag that follows semantic versioning as laid out at semver.org. Before commiting a major change all users must be told**
 At the time of writing all repositories in the SciaaS area of gitlab use this repository. Therefore all contributors to those repositories must be informed. If the user base is not known then email http://lists.sanger.ac.uk/mailman/listinfo/openstack-beta

# Generating images with the CI
The CI will only save images if CI_STORE_IMAGE is set in the CI pipeline. This can be done in the web UI with the Run Pipeline form (green button, top right)  
It can also be done via the api if the user has an api token. An example to start storing pipelines of all the supported branches:
```
for i in $(cat .supported_branches); do
  curl -XPOST "https://gitlab.internal.sanger.ac.uk/api/v4/projects/86/pipeline?ref=${i}&variables[][key]=CI_STORE_IMAGE&variables[][value]=true" --header "PRIVATE-TOKEN: $TOKEN"
done
```
