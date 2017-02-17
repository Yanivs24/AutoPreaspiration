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

data_path=data/speakers
result_dir="leave_one_speaker_out_results"

# export bin directory
export PATH=$PATH:$(pwd)/../AutoPA/bin
config_full_path=$(pwd)/config


# create results dir (if not exists)
[ ! -d $result_dir ] && mkdir $result_dir

for speaker in $(ls $data_path)
do
	examples_path=${data_path}/${speaker}

	# build results directory
	rm -rf ${result_dir}/${speaker}
	mkdir ${result_dir}/${speaker}

	
	# train using all the data except partition #i - 15% of the training data will be validation set (--cv_auto option) and we will use early stopping to finish training
	auto_pa_train.py --window_min $min_val --window_max $max_val --pa_tier bell --pa_mark pre ${config_full_path}/PreaspirationWavListExceptFold${i}.txt ${config_full_path}/PreaspirationTgListExceptFold${i}.txt models/PreaspirationModelFold${i}.classifier --cv_method early_stopping --cv_auto 

    # decode the remaining partition - #i (will be used as test set) 
	auto_pa_decode.py --window_min $min_val --window_max $max_val --pa_tier bell --pa_mark pre ${config_full_path}/PreaspirationWavListFold${i}.txt ${config_full_path}/PreaspirationTgListFold${i}.txt models/PreaspirationModelFold${i}.classifier

    # Mesure preformence on the remaining partition
    auto_pa_performance.py ${config_full_path}/PreaspirationTgListFold${i}.txt ${config_full_path}/PreaspirationTgListFold${i}.txt bell AutoPA > ${result_dir}/${train_data}/result_on_fold${i}.txt

	
done

# Average k result files and place the new file in the same dir
python python_scripts/avg_results_files.py ${result_dir}/${train_data}
