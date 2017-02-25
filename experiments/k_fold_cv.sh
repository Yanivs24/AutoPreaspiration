#!/bin/bash

# This file is part of AutoPA - automatic extraction of pre-aspiration 
# from speech segments in audio files.
#
# Copyright (c) 2016 Yaniv Sheena

# Usage: 
# k_fold_cv.sh DATA_PATH NUM_OF_FOLDS RESULT_DIR_NAME
#
# Description: 
# Preform k-fold-cross validation using all the examples in the direcrory. 
# store the result in the results directory - according to the given name (RESULT_DIR_NAME).


# export bin directory
export PATH=$PATH:$(pwd)/../AutoPA/bin
config_full_path=$(pwd)/config

min_val=-50
max_val=60
num_of_samples_train=100000 # max value - take all examples in the directory

# Input validations 
if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters"
    echo "Usage: $0 DATA_PATH NUM_OF_FOLDS RESULT_DIR_NAME"
    exit 1
fi

# Get examples path 
examples_path=$1
# Num of folds
k=$2
# Result dir name
data_name=$3

if [ ! -d $examples_path ]; then
	echo "\"${examples_path}\" - not a directory"
	exit 2
fi

# create results dir (if not exists)
result_dir="results/cross_validation_results"
[ ! -d $result_dir ] && mkdir $result_dir

# choose from:  abe12_abe14_plosives | abe24_abe18_plosives | aber_female_plosives_a | aber_female_plosives_b | aber_fricatives
# 				aber_males_plosives | pa_all_combined | pa_all_combined_no_fricatives | all_plosives | welsh
for cur_path in $examples_path
do
	echo "run k-fold-cross-validation with k=${k} over the data: ${cur_path}"

	# Build k partitions that randomly sampled from the train-set including randomly sampled test-set and their corresponding config files using python script
	python python_scripts/setup_kfold_cv.py $cur_path $config_full_path $num_of_samples_train $k

	# build results directory
	res_dir_name=${result_dir}/${data_name}_${k}_folds
	rm -rf ${res_dir_name}
	mkdir  ${res_dir_name}

	# Train k times (k-fold cross validation) - each time we take k-1 partitiones as train-set and the remaining partition as test-set
	# Save each result (W) in different file
	for ((i = 0; i < $k; i++ ))
	do
		# train using all the data except partition #i - 15% of the training data will be validation set (--cv_auto option) and we will use early stopping to finish training
	    auto_pa_train.py --window_min $min_val --window_max $max_val --pa_tier bell --pa_mark pre ${config_full_path}/PreaspirationWavListExceptFold${i}.txt ${config_full_path}/PreaspirationTgListExceptFold${i}.txt models/PreaspirationModelFold${i}.classifier --cv_method early_stopping --cv_auto 

	    # decode the remaining partition - #i (will be used as test set) 
	    auto_pa_decode.py --window_min $min_val --window_max $max_val --pa_tier bell --pa_mark pre ${config_full_path}/PreaspirationWavListFold${i}.txt ${config_full_path}/PreaspirationTgListFold${i}.txt models/PreaspirationModelFold${i}.classifier

	    # Mesure preformence on the remaining partition
  	    auto_pa_performance.py ${config_full_path}/PreaspirationTgListFold${i}.txt ${config_full_path}/PreaspirationTgListFold${i}.txt bell AutoPA > ${res_dir_name}/result_on_fold${i}.txt
	done

	# Average k result files and place the new file in the same dir
	python python_scripts/avg_results_files.py ${res_dir_name}
done

