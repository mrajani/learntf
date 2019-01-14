#!/bin/bash

cd ~/
curl "https://bootstrap.pypa.io/get-pip.py" -o "/tmp/get-pip.py"
sudo python /tmp/get-pip.py
sudo pip install awscli

