#!/bin/bash
user=${1:-vagrant}

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
elif [[ ${os} == "ubuntu" ]]; then
  # Install Docker in Ubuntu 18.04
  sudo apt-get -yqq update && sudo apt-get install -y unzip
  sudo DEBIAN_FRONTEND=noninteractive apt-get -yqq upgrade
  sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
else
  echo "Cannot identify the OS"
  exit 1;
fi

curl -sSL https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip -o tf.zip
unzip tf.zip && sudo mv terraform /usr/local/bin/terraform
rm tf.zip
terraform -version
