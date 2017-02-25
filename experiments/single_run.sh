#!/bin/bash

# This file is part of AutoPA - automatic extraction of pre-aspiration 
# from speech segments in audio files.
#
# Copyright (c) 2016 Yaniv Sheena
#
# Usage: 
# single_run.sh DATA_PATH SIZE_OF_TRAIN_SET SIZE_OF_TEST_SET
#
#
# Description:
# Train a model with #SIZE_OF_TRAIN_SET examples and then test the trained model on
# a test set of SIZE_OF_TEST_SET examples. The script take all the examples randomly
# from the given path (SIZE_OF_TRAIN_SET)

# export bin directory
export PATH=$PATH:$(pwd)/../AutoPA/bin
config_full_path=$(pwd)/config

# window sizes (ms)
min_val=-50
max_val=60

# Input validations 
if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters"
    echo "Usage: $0 DATA_PATH SIZE_OF_TRAIN_SET SIZE_OF_TEST_SET"
    exit 1
fi

# get inputs
examples_path=$1
num_of_samples_train=$2
num_of_samples_test=$3

if [ ! -d $examples_path ]; then
	echo "\"${examples_path}\" - not a directory"
	exit 2
fi

# Build train-set and test-set and their corresponding config files using python script
python python_scripts/build_config_files.py $examples_path $config_full_path $num_of_samples_train $num_of_samples_test

# Train with default configs
auto_pa_train.py --window_min $min_val --window_max $max_val --pa_tier bell --pa_mark pre config/PreaspirationTrainWavList.txt config/PreaspirationTrainTgList.txt models/PreaspirationModel.classifier

# Decode test-set with default configs
auto_pa_decode.py --window_min $min_val --window_max $max_val --pa_tier bell --pa_mark pre config/PreaspirationTestWavList.txt config/PreaspirationTestTgList.txt models/PreaspirationModel.classifier

# Mesure preformence on test-set
auto_pa_performance.py config/PreaspirationTestTgList.txt config/PreaspirationTestTgList.txt bell AutoPA

