#!/bin/bash

key=${1:-${HOME}/.ssh/awskey_rsa}
[[ -f ${key} ]] && rm ${key}
ssh-keygen -t ecdsa -b 521 -N "" -C Iono_AWS_Key -f ${key}
