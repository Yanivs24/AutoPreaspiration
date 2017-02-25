#!/bin/bash

# This file is part of AutoPA - automatic extraction of pre-aspiration 
# from speech segments in audio files.
#
# Copyright (c) 2016 Yaniv Sheena

# Usage: 
# train_model.sh DATA_PATH
#
# Description:
# Train a model using all the examples within the given path.
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

# Build training set and its corresponding config files using python script
python python_scripts/build_config_files.py $examples_path $config_full_path all 0

# Train with the given window sizes and the built training set
auto_pa_train.py --window_min $min_val --window_max $max_val --pa_tier bell --pa_mark pre config/PreaspirationTrainWavList.txt config/PreaspirationTrainTgList.txt models/PreaspirationModel.classifier --cv_auto
