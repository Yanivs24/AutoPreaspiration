#!/bin/bash

# This file is part of AutoPA - automatic extraction of pre-aspiration 
# from speech segments in audio files.
#
# Copyright (c) 2016 Yaniv Sheena

# Description: preform leave speaker out  using all the speaker in data/speakers. 
# store the result in a new directory - according to 'result_dir' variable.

min_val=-50
max_val=60
num_of_samples_train=100000 # max value - take all examples in the directory
k=5 # 5 folds

data_path=data/speakers
result_dir="results/leave_one_speaker_out_results"

# export bin directory
export PATH=$PATH:$(pwd)/../AutoPA/bin
config_full_path=$(pwd)/config

# file names of the config files containing the file names
leave_speaker_out_tg_file=${config_full_path}/pa_speaker_out_tg.txt
leave_speaker_out_wav_file=${config_full_path}/pa_speaker_out_wav.txt


# create results dir (if not exists)
[ ! -d $result_dir ] && mkdir $result_dir

for speaker in $(ls $data_path)
do
	speaker_path=${data_path}/${speaker}

	# get test set (the current speaker's examples), and make config file for this test
	python python_scripts/build_config_files.py $speaker_path $config_full_path 0 100000

	# build a list containing all the other speakers dir paths
	speaker_except_current=""
	for sp in $(ls $data_path)
	do
		[ "$sp" == "$speaker" ] && continue
		speaker_except_current+=" ${data_path}/${sp}"
	done

	# build config files containing all the data except the current speaker
	find $speaker_except_current -maxdepth 1 -type f | grep TextGrid | sort  > ${leave_speaker_out_tg_file}
	find $speaker_except_current -maxdepth 1 -type f | grep wav 	 | sort	 > ${leave_speaker_out_wav_file}
	
	# train using all the speakers except the current speaker - 15% of the training data will be validation set (--cv_auto option) and we will use early stopping to finish training
	auto_pa_train.py --window_min $min_val --window_max $max_val --pa_tier bell --pa_mark pre ${leave_speaker_out_wav_file} ${leave_speaker_out_tg_file} models/PreaspirationModelLeaveOneOut.classifier --cv_method early_stopping --cv_auto 

    # Decode test-set with default configs
	auto_pa_decode.py --window_min $min_val --window_max $max_val --pa_tier bell --pa_mark pre config/PreaspirationTestWavList.txt config/PreaspirationTestTgList.txt models/PreaspirationModelLeaveOneOut.classifier

	# Mesure preformence on test-set
	auto_pa_performance.py config/PreaspirationTestTgList.txt config/PreaspirationTestTgList.txt bell AutoPA > ${result_dir}/result_${speaker}.txt
done

# Average all result files and place the new file in the same dir
python python_scripts/avg_results_files.py ${result_dir}
