#!/bin/bash

# Checks that said parameters are recieved
[ "$#" -ge 4 ] || { echo "Error: Missing required parameters"; exit 1; }

apt update > /dev/null 2>&1
apt install -y fdupes > /dev/null 2>&1

token=$1
class=$2

mkdir -p Training
cd Training


python <(curl -sL https://rb.gy/tjdxr) --link=https://drive.google.com/drive/folders/$3
name="$(\ls -1dt * | head -n 1)"
fdupes -dN $name > /dev/null


cd /workspace/Training/$name ; sh <(curl -sL https://rb.gy/8wzni) # rename photos
[ -d /workspace/Training/$name ] && for file in /workspace/Training/$name/*; \
do [ -f "$file" ] && echo "$token, $class, $4" > "${file%.*}.txt" ; done

mkdir -p /workspace/Training/clients/$name /workspace/Training/clients/$name/log \
/workspace/Training/clients/$name/reg /workspace/Training/clients/$name/img
cp -r /workspace/Training/$name /workspace/Training/clients/$name/img/"40_${token} ${class}"
cd /workspace/Training/clients/$name/reg/

case $class in
    "man")
        gdown -q 119tXRH65NyN352kKAtGdG7y9mD2ZFYOS
        ;;
    "woman")
        gdown -q 1rX5O9MSx9F26gCFp4xlgasoxhbLJI7f_
        ;;
    "person")
        gdown -q 1mXhhSOGEMS4BYYf8B0SvbBSCUCT_aMR3
        ;;
    "artstyle")
        gdown -q 122OVeaBooLJq5Hz9lg5mBUoFjsWp5Exl
        ;;
    *)
        echo "There is no such class: $class!"
        ;;
esac
[ -f $class.tar.gz ] && mkdir -p 1_$class && tar -xf $class.tar.gz -C 1_$class
[ -f $class.tar.gz ] && rm -rf $class.tar.gz


# Parameter for kohya-ss
sed "s/prod/$name/g" <(curl -sL https://raw.githubusercontent.com/DerJimno/kohya-ss-conf/main/dreambooth.json) \
> /workspace/dreambooth.json


if [ $? -ne 0 ]; then
  # An error occurred, redirect stderr to stdout
  echo "An error occurred" >&2
fi
