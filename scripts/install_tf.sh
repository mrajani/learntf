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
  sudo DEBIAN_FRONTEND=noninteractive apt-get -yqq upgrade
  sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
else
  echo "Cannot identify the OS"
  exit 1;
fi

rel=${1:-0.12.0}
curl -sSL https://releases.hashicorp.com/terraform/${rel}/terraform_${rel}_linux_amd64.zip -o tf.zip
unzip tf.zip && sudo mv terraform /usr/local/bin/terraform
rm tf.zip
terraform -version
