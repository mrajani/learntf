#!/bin/bash

dir=${1:-${HOME}/learntf}
echo home dir is ${dir}
docker container run -it --rm --name vscode -p 8443:8443 \
        -v "${dir}:/home/coder/project" \
	-v "/Scratch:/Scratch" codercom/code-server:latest \
        --no-auth

