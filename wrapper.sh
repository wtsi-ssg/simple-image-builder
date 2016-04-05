#!/bin/bash

cd image-creation/ubuntu14.04/ || exit 1
./create_image.py -tf template.json -vf ../../variables.json -m validate -p virtualbox -l $(which packer) 
