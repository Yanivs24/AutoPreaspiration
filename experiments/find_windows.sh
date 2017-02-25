#!/bin/bash

for num_of_samples in $(seq 200 200)
do
    # Build train-set and test-set and their corresponding config files using python script (both sets will contain 'num_of_samples' samples)
    python /home/yaniv/Documents/Research/VOT/autovot/experiments/data/preaspiration-samples/formated/build_config_files.py $num_of_samples $num_of_samples

    for min_val in $(seq -20 -5 -80)
    do
        for max_val in $(seq 20 5 80)      
        do
            # Train with default configs
            auto_vot_train.py --window_min $min_val --window_max $max_val --vot_tier bell --vot_mark pre config/PreaspirationTrainWavList.txt config/PreaspirationTrainTgList.txt models/PreaspirationModel.classifier

            # Decode test-set with default configs
            auto_vot_decode.py --window_min $min_val --window_max $max_val --vot_tier bell --vot_mark pre config/PreaspirationTestWavList.txt config/PreaspirationTestTgList.txt models/PreaspirationModel.classifier

            # Mesure preformence on test-set
            auto_vot_performance.py config/PreaspirationTestTgList.txt config/PreaspirationTestTgList.txt bell AutoVOT > run_results2/result_${num_of_samples}samples_${min_val}_${max_val}.txt
            
            # Clean test TG files in order to decode them again after training a new model (with cross-validation)
            python /home/yaniv/Documents/Research/VOT/autovot/experiments/data/preaspiration-samples/formated/clean_test_files.py

            # Train with 20% from the data as cross-validation
            auto_vot_train.py --cv_auto --window_min $min_val --window_max $max_val --vot_tier bell --vot_mark pre config/PreaspirationTrainWavList.txt config/PreaspirationTrainTgList.txt models/PreaspirationModel.classifier

            # Decode test-set with default configs
            auto_vot_decode.py --window_min $min_val --window_max $max_val --vot_tier bell --vot_mark pre config/PreaspirationTestWavList.txt config/PreaspirationTestTgList.txt models/PreaspirationModel.classifier

            # Mesure preformence on test-set
            auto_vot_performance.py config/PreaspirationTestTgList.txt config/PreaspirationTestTgList.txt bell AutoVOT > run_results3/result_${num_of_samples}samples_${min_val}_${max_val}_with_CV.txt

            # Clean test TG files in order to decode them again after training a new model
            python /home/yaniv/Documents/Research/VOT/autovot/experiments/data/preaspiration-samples/formated/clean_test_files.py
        done
    done
done