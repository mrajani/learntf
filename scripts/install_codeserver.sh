#!/bin/bash
# Install Code Server on Linux Platform 
url_latest=https://github.com/cdr/code-server/releases/latest
url_effective=$(curl -sSL -I -o /dev/null -w %{url_effective} ${url_latest})
tag=${url_effective##*/}
echo "Installing ${tag} version of codeserver"

codeserver=code-server${tag}-linux-x64.tar.gz
wget -q https://github.com/cdr/code-server/releases/download/${tag}/${codeserver}
vsdir=vscodeserver
[[ -d $vsdir ]] && rm -rf $vsdir
mkdir $vsdir \
&& tar zxf $codeserver -C $vsdir --strip-components 1 \
&& rm $codeserver
