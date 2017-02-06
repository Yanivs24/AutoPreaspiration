#!/bin/bash

# This file is part of AutoPA - automatic extraction of pre-aspiration 
# from speech segments in audio files.
#
# Copyright (c) 2016 Yaniv Sheena

# Description: extract features from all the examples in a given config files, place the output files
#			   in the directory feature_extractions. feature_extractions/feature_names.txt will contain 
# 			   the absolute paths of the feature-files.


min_val=-50
max_val=60
examples_path=$1
num_of_samples=$2


EXPERIMENT=$(pwd)/..

# export bin directory
export PATH=$PATH:$EXPERIMENT/../AutoPA/bin
config_full_path=$EXPERIMENT/config


# Build train-set and the corresponding config files using python script
python $EXPERIMENT/python_scripts/build_config_files.py $examples_path $config_full_path $num_of_samples 0

# create dir for the feature-files
rm -rf feature_extractions
mkdir feature_extractions
mkdir feature_extractions/feature_files

# call feature extraction with the create config files
auto_pa_extract_features.py --window_min $min_val --window_max $max_val --pa_tier bell --pa_mark pre $EXPERIMENT/config/PreaspirationTrainTgList.txt $EXPERIMENT/config/PreaspirationTrainWavList.txt feature_extractions/input.txt feature_extractions/feature_names.txt feature_extractions/labels.txt $(pwd)/feature_extractions/feature_files
