#!/bin/bash

dir=${1:-.}
echo home dir is ${PWD}/${dir}
docker run -it -p 0.0.0.0:8443:8443 -v "${PWD}/${dir}:/home/coder/project" codercom/code-server --no-auth

