#!/usr/bin/env python

from __future__ import print_function
import re
import time
import sys
import string
import random
import subprocess
import os
from os import environ
import argparse
import json

from keystoneauth1.identity import v3
from keystoneauth1 import session
from novaclient import client as nova_client
from glanceclient import client as glance_client

def authenticate():
    """
    This function returns authenticated nova and glance objects
    """
    try:
      auth = v3.Password(username=os.environ['OS_USERNAME'],
       password=os.environ['OS_PASSWORD'],
       auth_url=os.environ['OS_AUTH_URL'],
       project_name=os.environ['OS_TENANT_NAME'],
       user_domain_name='Default',
       project_domain_name='Default',
       )

      sess = session.Session(auth=auth)
      glance = glance_client.Client('2',session=sess)
      nova = nova_client.Client(2, session=sess)
    except:
      print('Sourcing openstack environment variables failed, please check that the environment variables are set correctly.')
      sys.exit(2)

    return nova, glance


def download(input_name, output_location, date_time):
    '''
    shrinks the image and replaces the standard image
    '''

    nova, glance = authenticate()
    image_count = 0

    try:
        images = glance.images.list()
    except:
        print("Could not get a list of images")
        sys.exit(1)

    for image in images:
        if 'private' not in image['visibility']:
            continue
        if input_name == image['name'] or input_name + '_' + environ.get('CI_COMMIT_SHA') == image['name']:
            try:
                if date_time:
                  file_name_ending = '_' + time.strftime("%Y%m%d%H%M%S") + '_' +  environ.get('CI_COMMIT_SHA') +  ".qcow"
                else:
                  file_name_ending = ".qcow"
                if environ.get('CI_STORE_IMAGE') is not None:
                  image_count = image_count + 1
                  downloaded_file = output_location + file_name_ending
                  print("downloaded file is called: " + downloaded_file)
                  try:
                    subprocess.check_call(['glance', 'image-download', '--progress', '--file', downloaded_file, image.id])
                  except subprocess.CalledProcessError as e:
                    print(json.dumps(image))
                    print(e.output)
                    sys.exit(1)
                  if environ.get('LIBGUESTFS_CMD') is not None:
                     print("Executing " + environ.get('LIBGUESTFS_CMD'))
                     try:
                       subprocess.check_call(['virt-customize','-a',downloaded_file,'--run-command', environ.get('LIBGUESTFS_CMD')])
                     except subprocess.CalledProcessError as e:
                       print(e.output)
                       sys.exit(1)
                  uploadinstructions(output_location,file_name_ending,nova)
                subprocess.check_call(['openstack', 'image', 'delete', image['id']])
                print("successfully deleted " + str(image['name']))
            except subprocess.CalledProcessError as e:
                print(json.dumps(image))
                print(e.output)
                print('The original image could not be destroyed, please run this manually')
                sys.exit(1)
    if environ.get('CI_STORE_IMAGE') is not None and image_count != 1:
        print('Image called ' + input_name + ' Not found/Unique count is ' + str(image_count))
        sys.exit(1)

def uploadinstructions(output_location,file_name_ending,nova):
    '''
    generates the instruction to upload the  image as a private image
    '''

    flavourlist = nova.flavors.list()
    correctflavour = next(i for i in flavourlist if i.name == environ.get('OS_FLAVOR_NAME'))
    min_disk = correctflavour.disk
    with open(output_location + file_name_ending + ".upload", 'w') as instructions:
        instructions.write("""
#!/bin/bash -e
OS_PROJECT_NAME="ssg-isg-image-store"
""")
        instructions.write("\nqemu-img convert -f qcow2 -O raw {} {}".format(
            output_location + file_name_ending,
            output_location + file_name_ending + ".raw"))
        instructions.write('''\nIMAGE_LIST="$(openstack   image list --public  -f json | jq -r '.[]|select(.Name | startswith("{}"))|.ID' )"'''.format(
            re.sub('[0-9]*$', '' ,environ.get('IMAGE_NAME'))))
        instructions.write("\nopenstack image create --disk-format raw --container-format bare --public --file={} --property url={} --property branch={} --property commit={} --min-disk {} {}_{}\n".format(
            output_location + file_name_ending + ".raw",
            environ.get('CI_PROJECT_URL'),
            environ.get('CI_COMMIT_REF_NAME'),
            environ.get('CI_COMMIT_SHORT_SHA'),
            min_disk,
            output_location.split('/')[-1],
            environ.get('CI_COMMIT_SHORT_SHA')))
        instructions.write("""
for image in ${IMAGE_LIST}
do
  IMAGE_OWNER="$( openstack image show -f json  $image |jq -r '.owner')"
  if [ "${IMAGE_OWNER}" = "288ce868e9e74c1abe46c468a2ae219e" -o "${IMAGE_OWNER}" = "6aa285393c104dc79cf220758a228e0b" ] ; then
    # Only hide admin owned images
    glance image-update --hidden True $image
  fi
done
""")
        instructions.write("\nrm {}".format(output_location + file_name_ending + ".raw"))

def parsing():
    parser = argparse.ArgumentParser(description="This script cleans up the openstack images after testing and store them locally")
    parser.add_argument(
        'input', help='The name of the file in openstack')
    parser.add_argument(
        'output', help='The output name')
    parser.add_argument(
        '-f', '--file_path', dest='file_path', default='/warehouse/isg_warehouse/SciaaS_images/openstack/',
        help='The output location')
    parser.add_argument(
        '-dt', '--datetime', dest='date_time', action='store_true', help='Store the date and time in the name of the file')

    return parser.parse_args()


def main():
    args = parsing()
    download(args.input, args.file_path + args.output, args.date_time)

if __name__ == "__main__":
    main()
