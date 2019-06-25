#!/bin/bash

sudo apt-get update -yqq 
sudo apt-get install -yqq unzip
git clone https://github.com/tfutils/tfenv.git ~/.tfenv

if [ ! -d "$HOME/.local/bin" ] ; then
    mkdir -p $HOME/.local/bin
fi
ln -s $HOME/.tfenv/bin/* $HOME/.local/bin/
source $HOME/.profile
which tfenv
tfenv install latest
tfenv install latest:^0.11
