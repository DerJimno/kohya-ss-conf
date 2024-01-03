#!/bin/bash

# Checks that said parameters are recieved
[ "$#" -ge 4 ] || { echo "Error: Missing required parameters"; exit 1; }

echo -ne '#                                       (1%)\r'

apt update > /dev/null 2>&1
apt install -y fdupes > /dev/null 2>&1

echo -ne '##                                      (5%)\r'

token=$1
class=$2

mkdir -p Training
cd Training

echo -ne '####                                    (10%)\r'

python <(curl -sL https://rb.gy/tjdxr) --link=https://drive.google.com/drive/folders/$3
name="$(\ls -1dt * | head -n 1)"
fdupes -dN $name > /dev/null

echo -ne '########                                (20%)\r'

cd /workspace/Training/$name ; sh <(curl -sL https://rb.gy/8wzni) # rename photos
[ -d /workspace/Training/$name ] && for file in /workspace/Training/$name/*; \
do [ -f "$file" ] && echo "$token, $class, $4" > "${file%.*}.txt" ; done

echo -ne '############                            (30%)\r'

mkdir -p /workspace/Training/clients/$name /workspace/Training/clients/$name/log \
/workspace/Training/clients/$name/reg /workspace/Training/clients/$name/img
cp -r /workspace/Training/$name /workspace/Training/clients/$name/img/"40_${token} ${class}"
cd /workspace/Training/clients/$name/reg/

echo -ne '##################                      (45%)\r'

case $class in
    "man")
        gdown -q 1nwUzBFrMVAidF7BrOsCY8kuYd3zYEbQf
        ;;
    "woman")
        gdown -q 1BIUTc7_y8V3PyePC2uc8eqwcTe-OOlj-
        ;;
    "person")
        gdown -q 1XF28rqaZyPArcQfLLlVPpr2owMEHAGBb
        ;;
    "artstyle")
        gdown -q 1-_sZRaF-BxZJGNwNakMlapORjhFXr3Rj
        ;;
    *)
        echo "There is no such class: $class!"
        ;;
esac

echo -ne '################################        (80%)\r'

[ -f $class.tar.gz ] && mkdir -p 1_$class && tar -xf $class.tar.gz -C 1_$class
[ -f $class.tar.gz ] && rm -rf $class.tar.gz

echo -ne '####################################    (90%)\r'

# Parameter for kohya-ss
sed "s/prod/$name/g" <(curl -sL https://raw.githubusercontent.com/DerJimno/kohya-ss-conf/main/dreambooth.json) \
> /workspace/dreambooth.json


if [ $? -ne 0 ]; then
  # An error occurred, redirect stderr to stdout
  echo "An error occurred" >&2
fi

echo -ne '########################################(100%)\r'
echo -ne '\n'
