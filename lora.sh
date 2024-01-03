#!/bin/bash

# Checks that said parameters are recieved
[ "$#" -ge 3 ] || { echo "Error: Missing required parameters"; exit 1; }

apt update > /dev/null 2>&1
apt install -y fdupes > /dev/null 2>&1

token=$1
class=$2

mkdir -p Training
cd Training


python <(curl -sL https://rb.gy/tjdxr) --link=https://drive.google.com/drive/folders/$3
name="$(\ls -1dt * | head -n 1)"
fdupes -dN $name > /dev/null

num=$(ls -A "$name" | wc -l)
steps=$((120/$num))


cd /workspace/Training/$name ; sh <(curl -sL https://rb.gy/8wzni) # rename photos


mkdir -p /workspace/Training/clients/$name /workspace/Training/clients/$name/log \
/workspace/Training/clients/$name/reg /workspace/Training/clients/$name/img
cp -r /workspace/Training/$name /workspace/Training/clients/$name/img/"${steps}_${token} ${class}"
cd /workspace/Training/clients/$name/reg/

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
    *)
	    echo "There is no such class: $class!"
        ;;
esac
[ -f $class.tar.gz ] && mkdir -p 1_$class && tar -xf $class.tar.gz -C 1_$class
[ -f $class.tar.gz ] && rm -rf $class.tar.gz


cd /workspace/kohya_ss
/workspace/kohya_ss/venv/bin/python3 finetune/make_captions.py \
--batch_size=1 --num_beams=1 --top_p=0.9 --max_length=75 --min_length=5 --beam_search \
--caption_extension=.txt /workspace/Training/clients/$name/img/"${steps}_${token} ${class}" \
> /dev/null 2>&1


directory="/workspace/Training/clients/$name/img/${steps}_${token} ${class}"

if [ -d "$directory" ]; then
    for file in "$directory"/*.txt; do
        if [ -e "$file" ]; then
            echo -e "$token $(cat "$file")" > "$file"
        else
            echo "File does not exist: $file"
        fi
    done
else
    echo "Directory does not exist: $directory"
fi

# Style in Stable Diffuision
sed "s/name_class/$token a $class/g" <(curl -sL https://rb.gy/gd2e2) > /workspace/stable-diffusion-webui/styles.csv


# Parameter for kohya-ss
sed "s/client/$name/g" <(curl -sL https://rb.gy/a324d) > /workspace/lora.json




if [ $? -ne 0 ]; then
  # An error occurred, redirect stderr to stdout
  echo "An error occurred" >&2
fi
