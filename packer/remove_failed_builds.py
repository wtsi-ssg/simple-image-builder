#!/usr/bin/env python

from __future__ import print_function
import argparse
import sys
import subprocess
import os
from os import environ
from keystoneauth1.identity import v3
from keystoneauth1 import session
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
    except Exception as e:
      print('Auth token failed. '+str(e))
      sys.exit(2)

    try:
      sess = session.Session(auth=auth)
    except:
      print('session failed.')
      sys.exit(3)

    try:
      glance = glance_client.Client('2',session=sess)
    except:
      print('glance failed')
      sys.exit(4)
    return glance

def remove(image_names):
    glance = authenticate()

    removed = 0
    for image in glance.images.list():
        if 'private' not in image.visibility:
            continue
        if image.name in image_names:
            print("removing image %s (%s)" % (image.id, image.name))
            try:
                glance.images.delete(image.id)
                removed+=1
            except glexc.HTTPException as e:
                print("could not delete image %s: %s" % (image.id, e))
    print("deleted %d images" %(removed))

def main():
    parser = argparse.ArgumentParser(description="Removes the specified images from OpenStack after a failed build")
    parser.add_argument('--image_name','-i', action='append', dest='image_names', help='The image(s) to remove (may be repeated)')
    args = parser.parse_args()
    remove(args.image_names)

if __name__ == "__main__":
    main()
