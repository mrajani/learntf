#!/bin/bash

dir=${1:-.}
echo home dir is ${PWD}/${dir}
docker run -it -p 8443:8443 -v "${PWD}/${dir}:/home/coder/project" \
	-v "/Scratch:/Scratch" codercom/code-server --no-auth

