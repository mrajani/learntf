#!/bin/bash

if [[ ( -z ${os} && -z ${dist} ) ]]; then
  if [ -e /etc/os-release ]; then
    . /etc/os-release
    os=$( echo ${ID} | awk '{ print tolower($1) }')
    dist=${VERSION_ID}
  fi
fi
echo "Found ${os} "

if [[ ${os} == "centos" ]]; then
  # Install Terraform in CentOS
  echo   
elif [[ ${os} == "amzn" ]]; then
  # Install Terraform in Amzn Linux
  echo Installing Terraform for AWS AMI   
elif [[ ${os} == "ubuntu" ]]; then
  # Install Docker in Ubuntu 18.04
  sudo apt-get -yqq update && sudo apt-get install -y unzip
else
  echo "Cannot identify the OS"
  exit 1;
fi

git clone https://github.com/tfutils/tfenv.git ~/.tfenv

if [ ! -d "$HOME/.local/bin" ] ; then
    mkdir -p $HOME/.local/bin
fi
ln -s $HOME/.tfenv/bin/* $HOME/.local/bin/
source $HOME/.profile
which tfenv
tfenv install latest
tfenv install latest:^0.11
