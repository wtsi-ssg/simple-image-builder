#!/bin/bash
set -e
VENV=/tmp/venv
mkdir -p $VENV
python3 -m venv $VENV
. $VENV/bin/activate
pip3 install wheel
pip3 install -r packer/requirements.txt
echo $VENV
