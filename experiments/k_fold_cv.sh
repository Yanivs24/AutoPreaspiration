#!/bin/bash

# This file is part of AutoPA - automatic extraction of pre-aspiration 
# from speech segments in audio files.
#
# Copyright (c) 2016 Yaniv Sheena

# Description: preform k-fold-cross validation using all the examples in the direcrory. 
# store the result in a new directory - according to 'result_dir' variable.

min_val=-50
max_val=60
num_of_samples_train=100000 # max value - take all examples in the directory
k=5 # 5 folds

result_dir="cross_validation_results"

# export bin directory
export PATH=$PATH:$(pwd)/../AutoPA/bin
config_full_path=$(pwd)/config

# choose from:  abe12_abe14_plosives | abe24_abe18_plosives | aber_female_plosives_a | aber_female_plosives_b | aber_fricatives
# 				aber_males_plosives | pa_all_combined | pa_all_combined_no_fricatives


# create results dir (if not exists)
[ ! -d $result_dir ] && mkdir $result_dir

#for train_data in pa_all_combined_no_fricatives
for train_data in abe12_abe14_plosives abe24_abe18_plosives aber_female_plosives_a aber_female_plosives_b aber_fricatives aber_males_plosives pa_all_combined_no_fricatives
do
	echo "run k-fold-cross-validation with k=${k} over the data: ${train_data}"

	examples_path=data/${train_data}/formated

	# Build k partitions that randomly sampled from the train-set including randomly sampled test-set and their corresponding config files using python script
	python python_scripts/setup_kfold_cv.py $examples_path $config_full_path $num_of_samples_train $k

	# build results directory
	rm -rf ${result_dir}/${train_data}
	mkdir ${result_dir}/${train_data}

	# Train k times (k-fold cross validation) - each time we take k-1 partitiones as train-set and the remaining partition as test-set
	# Save each result (W) in different file
	for ((i = 0; i < $k; i++ ))
	do
		# train using all the data except partition #i - 15% of the training data will be validation set (--cv_auto option) and we will use early stopping to finish training
	    auto_pa_train.py --window_min $min_val --window_max $max_val --pa_tier bell --pa_mark pre ${config_full_path}/PreaspirationWavListExceptFold${i}.txt ${config_full_path}/PreaspirationTgListExceptFold${i}.txt models/PreaspirationModelFold${i}.classifier --cv_method early_stopping --cv_auto 

	    # decode the remaining partition - #i (will be used as test set) 
	    auto_pa_decode.py --window_min $min_val --window_max $max_val --pa_tier bell --pa_mark pre ${config_full_path}/PreaspirationWavListFold${i}.txt ${config_full_path}/PreaspirationTgListFold${i}.txt models/PreaspirationModelFold${i}.classifier

	    # Mesure preformence on the remaining partition
		auto_pa_performance.py ${config_full_path}/PreaspirationTgListFold${i}.txt ${config_full_path}/PreaspirationTgListFold${i}.txt bell AutoPA > ${result_dir}/${train_data}/result_on_fold${i}.txt
	done

	# Average k result files and place the new file in the same dir
	python python_scripts/avg_results_files.py ${result_dir}/${train_data}
done

