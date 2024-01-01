#!/bin/bash

apt update > /dev/null 2>&1
apt install -y fdupes > /dev/null 2>&1
pip install github-clone --break-system-packages > /dev/null 2>&1

token=$1
class=$2

mkdir -p Training
cd Training


python <(curl -sL https://rb.gy/tjdxr) --link=https://drive.google.com/drive/folders/$3
name="$(\ls -1dt * | head -n 1)"
fdupes -dN $name > /dev/null


cd /workspace/Training/$name ; sh <(curl -sL https://rb.gy/8wzni) # rename photos

mkdir -p /workspace/Training/clients/$name /workspace/Training/clients/$name/log \
/workspace/Training/clients/$name/reg /workspace/Training/clients/$name/img
cp -r /workspace/Training/$name /workspace/Training/clients/$name/img/"40_${token} ${class}"
cd /workspace/Training/clients/$name/reg/
ghclone https://github.com/DerJimno/SD-Regularization-Images/tree/main/$class
mv $class "1_${class}"


# Parameter for kohya-ss
sed "s/client/$name/g" <(curl -sL https://raw.githubusercontent.com/DerJimno/kohya-ss-conf/main/dreambooth.json) > /workspace/dreambooth.json


if [ $? -ne 0 ]; then
  # An error occurred, redirect stderr to stdout
  echo "An error occurred" >&2
fi
