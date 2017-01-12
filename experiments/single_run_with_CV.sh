#!/bin/bash

# This file is part of AutoPA - automatic extraction of pre-aspiration 
# from speech segments in audio files.
#
# Copyright (c) 2016 Yaniv Sheena

# Description:
# Train a model with #num_of_samples_train examples and then test the trained model on
# a test set of #num_of_samples_test examples. The script take all the examples randomly
# from the given path (examples_path). When training - 15% of the train data will be validation
# set and the algorithm will use early stopping to finish the training.

min_val=-50
max_val=60
examples_path=$1
num_of_samples_train=$2
num_of_samples_test=$3

# export bin directory
export PATH=$PATH:$(pwd)/../AutoPA/bin
config_full_path=$(pwd)/config

# Build train-set and test-set and their corresponding config files using python script
python python_scripts/build_config_files.py $examples_path $config_full_path $num_of_samples_train $num_of_samples_test

# Train with default configs
auto_pa_train.py --window_min $min_val --window_max $max_val --pa_tier bell --pa_mark pre config/PreaspirationTrainWavList.txt config/PreaspirationTrainTgList.txt models/PreaspirationModel.classifier --cv_auto

# Decode test-set with default configs
auto_pa_decode.py --window_min $min_val --window_max $max_val --pa_tier bell --pa_mark pre config/PreaspirationTestWavList.txt config/PreaspirationTestTgList.txt models/PreaspirationModel.classifier

# Mesure preformence on test-set
auto_pa_performance.py config/PreaspirationTestTgList.txt config/PreaspirationTestTgList.txt bell AutoPA