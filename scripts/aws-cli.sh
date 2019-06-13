#!/bin/bash
# Specific for Ubuntu distro 

cd ~/
sudo apt-get install -yqq python3-pip
pip3 install awscli
source $HOME/.profile
complete -C `which aws_completer` aws

