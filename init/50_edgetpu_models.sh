#!/bin/bash

if [ "$INSTALL_HOOK" == "1" ] && [ "$INSTALL_EDGETPU" == "1" ]; then
    echo "deb https://packages.cloud.google.com/apt coral-edgetpu-stable main" | tee /etc/apt/sources.list.d/coral-edgetpu.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    apt-get update
    apt-get -y install libedgetpu1-std python3-pycoral
    pip3 install https://github.com/google-coral/pycoral/releases/download/release-frogfish/tflite_runtime-2.5.0-cp38-cp38-linux_x86_64.whl
    usermod -aG plugdev www-data

    if [ ! -d /config/hook/models/coral_edgetpu ]; then
	   mkdir -p /config/hook/models/coral_edgetpu
    fi
    echo 'Checking for Google Coral Edge TPU data files...'
    targets=( 'coco_indexed.names' 'ssd_mobilenet_v2_coco_quant_postprocess_edgetpu.tflite')
    sources=('https://dl.google.com/coral/canned_models/coco_labels.txt'
             'https://github.com/google-coral/edgetpu/raw/master/test_data/ssd_mobilenet_v2_coco_quant_postprocess_edgetpu.tflite'
            )
    for ((i=0;i<${#targets[@]};++i))
    do
        if [ ! -f "/config/hook/models/coral_edgetpu/${targets[i]}" ]
        then
            wget "${sources[i]}"  -O"/config/hook/models/coral_edgetpu/${targets[i]}"
        else
            echo "${targets[i]} exists, no need to download"
        fi
    done
fi
