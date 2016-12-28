#!/bin/bash
min_val=$1
max_val=$2
num_of_samples_train=$3
num_of_samples_test=$4

for c in $(seq 1 1 200)
do
    # Build train-set and test-set and their corresponding config files using python script 
    python /home/yaniv/Documents/Research/VOT/autovot/experiments/data/preaspiration-samples/formated/build_config_files.py $num_of_samples_train $num_of_samples_test

    # Train with default configs
    auto_vot_train.py --C $c --window_min $min_val --window_max $max_val --vot_tier bell --vot_mark pre config/PreaspirationTrainWavList.txt config/PreaspirationTrainTgList.txt models/PreaspirationModel.classifier

    # Decode test-set with default configs
    auto_vot_decode.py --window_min $min_val --window_max $max_val --vot_tier bell --vot_mark pre config/PreaspirationTestWavList.txt config/PreaspirationTestTgList.txt models/PreaspirationModel.classifier

    # Mesure preformence on test-set
    auto_vot_performance.py config/PreaspirationTestTgList.txt config/PreaspirationTestTgList.txt bell AutoVOT > run_calib_c/result_c_${c}.txt

done