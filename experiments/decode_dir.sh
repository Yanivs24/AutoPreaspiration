#!/bin/bash

# This file is part of AutoPA - automatic extraction of pre-aspiration 
# from speech segments in audio files.
#
# Copyright (c) 2016 Yaniv Sheena

# Usage: 
# decode_dir.sh DATA_PATH
#
# Description:
# Decode the examples in the given directory (DATA_PATH) and test the performance by
# comparing the predictions to the manually coded pre-aspiration (within the textgrids).
# Note: The examples should be formated using "python_scripts/format_wav_files.py" 
#       and filtered using "python_scripts/filter_examples.py"

# export bin directory
export PATH=$PATH:$(pwd)/../AutoPA/bin
config_full_path=$(pwd)/config

# window sizes (ms)
min_val=-50
max_val=60

# Input validations 
if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    echo "Usage: $0 DATA_PATH"
    exit 1
fi

# Get examples path 
examples_path=$1

if [ ! -d $examples_path ]; then
	echo "\"${examples_path}\" - not a directory"
	exit 2
fi

# Build test set and its corresponding config files using python script
python python_scripts/build_config_files.py $examples_path $config_full_path 0 all

# Decode the built test-set 
auto_pa_decode.py --window_min $min_val --window_max $max_val --pa_tier bell --pa_mark pre config/PreaspirationTestWavList.txt config/PreaspirationTestTgList.txt models/PreaspirationModel.classifier

# Mesure preformence
auto_pa_performance.py config/PreaspirationTestTgList.txt config/PreaspirationTestTgList.txt bell AutoPA