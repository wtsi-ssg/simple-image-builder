# MySQL Ubuntu 14.04 Image builder

These are scripts to build a Ubuntu 14.04 image with a MySQL database on: 
- Virtual Box
- VMWare
- Openstack 

## Usage

**Legacy:** *./packer.sh (build|validate) (virtualbox|vmware|openstack|all)*  
./create_image.py (build|validate) (template) (variable file) [options]

This will build images for the supplied platform(s) or all. If the option validate is issued then the template will only be checked for syntax.

## Prequisites

- Packer version 0.9.0 (or later), this can be set either in the path, as an environment variable $PACKER_BIN or on the command line. If none of these are set then ./create_image.py will try and use the copy of packer in /software
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
  - time  


## VMWare private key

Communication with the ESX server is via SSH a private key is required to connect to the server, this should be placed in the file **vmware_private_key.pem** 

## Openstack Credentials

The openstack.sh script should be modified with the appropriate openstack credentials & environment in the variables:-


- COMPUTE_API_VERSION

Version required to support openstack clients (1.1 minimum)

- OS_CLOUDNAME

Name of the cloud to connect to (in the event of multiple cloud environments)

- OS_AUTH_URL

URL of the API endpoint

- NOVA_VERSION

Should match the COMPUTE_API_VERSION above.

- OS_USERNAME

Username to connect to the openstack environment with

- OS_PASSWORD

Password for the above user

- OS_TENANT_NAME

Tenant within openstack to use for the build

- OS_BASE_IMAGE

Base image ID to use for the build

- OS_SECURITY_GRP

Security group to apply to the build (must allow SSH access to the booted image)

## 

## Variables

The files *variables.json* contains configuration variables required to build the image important variables are:-

### packer_username &  packer_password
The username & password that will be burnt into the image as a default user

### iso_url &  iso_checksum
The URL of an ISO image to build against - this is used for virtualbox & vmware builds

### vm_pass
The password to use to connect to the vmware build host
### extra_script
An additional script to run to configure this image - this script must exist, if no additional customization is required this should be a "NOOP" script

### directory 
The directory variable is a file path to the image-creation/ubuntu14.04 directory. This directory contains the standard scripts and files that are capable of building the base image

## scripts
This directory contains the scripts used to configure MySQL. 



## VMWare cleanup

If the vmware build fails it can leave residue behind on the ESX host. This will prevent future builds from working. 

To clean up:-

- Login to the esxi host:-
```
ssh -i vmware_private_key.pem vmbuildadmin@wtgc-vmbd-01.internal.sanger.ac.uk
cd /vmfs/volumes/wtgc-vmbd-01:datastore1
```

- Check to see if there are any registered vms:-
	
```	
vim-cmd vmsvc/getallvms
Vmid         Name                                        File                                    Guest OS      Version   Annotation
40     packer-vmware-iso   [wtgc-vmbd-01:datastore1] packer-vmware-iso/packer-vmware-iso.vmx   ubuntu64Guest   vmx-08              
```

_Here 40 is the VM identifier, that will be used for the further examples, this will be different._

- If there are any registered under **'packer-vmware-iso'** then check their power state:-

```
vim-cmd vmsvc/power.getstate 40
Retrieved runtime info
Powered off
```

- If running power off with `vim-cmd vmsvc/power.off 40` 
- Unregister the VM with `vim-cmd vmsvc/unregister 40`
- Finally delete the directory 'packer-vmware-iso' (if it exists)



