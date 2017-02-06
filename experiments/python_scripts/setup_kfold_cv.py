#!/usr/bin/python
# This file is part of AutoPA - automatic extraction of pre-aspiration 
# from speech segments in audio files.
#
# Copyright (c) 2016 Yaniv Sheena

import os
import sys
import random
from shutil import copyfile, rmtree

def get_examples(dir_path):
    wav_extension = '.wav'
    tg_extension = '.TextGrid'
    wav_files = [n[:-len(wav_extension)] for n in os.listdir(dir_path) if n.endswith(wav_extension)]
    tg_files = [n[:-len(tg_extension)] for n in os.listdir(dir_path) if n.endswith(tg_extension)]

    # intesection between wav files and textgrid (we need both)
    examples = set(wav_files) & set(tg_files)
    return list(examples)


def delete_dirs(dir_paths):
    ''' deletes dir if the dir exists or has premission'''
    for c_dir in dir_paths:
        try:
            rmtree(c_dir)
        except OSError:
            pass


if __name__ == "__main__":

    if len(sys.argv) != 5:
        raise ValueError("expected exactly 4 inputs:\n1)examples dir path\n2)config dir path\n3)train-set size\n4)k (folds amount)")

    current_path = os.path.abspath(sys.argv[1])
    config_path  = sys.argv[2]
    if not config_path.endswith('/'):
        config_path += '/'
    train_size   = int(sys.argv[3])
    folds_amount = int(sys.argv[4]) # i.e. K

    # get all examples (this will take only the names of examples with wav+TextGrid files in the given path)
    examples_names = get_examples(current_path)

    # in order to choose randomly - shuffle list and then take from the beginning
    random.shuffle(examples_names)

    # real train size
    train_size = min(len(examples_names), train_size)

    # build k partitions
    partition_size = int(train_size/folds_amount)
    train_partitions = list()
    for i in range(folds_amount):
        train_partitions.append(examples_names[partition_size*i:partition_size*(i+1)])

    wav_train       = []
    wav_train_final = []
    tg_train        = []
    tg_train_final  = []

    # build train lists for each partition
    for i in range(len(train_partitions)):
        wav_train.append(list())
        tg_train.append(list())
        wav_train_final.append(list())
        tg_train_final.append(list())

        # build full paths lists of WAV and TextGrid files
        for ex_name in train_partitions[i]:
            wav_train[i].append('{0}/{1}.wav'.format(current_path, ex_name))
            tg_train[i].append('{0}/{1}.TextGrid'.format(current_path, ex_name))
            wav_train_final[i].append('{0}/Train{1}/{2}.wav'.format(current_path, str(i), ex_name))
            tg_train_final[i].append('{0}/Train{1}/{2}.TextGrid'.format(current_path, str(i), ex_name))


    # delete train and test dirs (if exists) and create new ones
    train_dst_dirs = ['%s/Train%s' % (current_path, str(j)) for j in range(len(train_partitions))]
    train_dir = '%s/Train' % current_path
    delete_dirs([train_dir] + train_dst_dirs)

    # build k empty train dirs
    for i in range(len(train_partitions)):
        os.mkdir(train_dst_dirs[i])

    # copy files to Train dirs
    for i in range(len(train_partitions)):
        for file_path in wav_train[i]+tg_train[i]:
            print 'copy %s to the Train%s directory' % (file_path, str(i))
            copyfile(file_path, train_dst_dirs[i]+'/'+os.path.split(file_path)[1])

    # Build the files that contain paths lists as needed and place them in 'config' dir    

    # build all partitions config files
    for i in range(len(train_partitions)):
        with open(config_path+'PreaspirationWavListFold%s.txt' % str(i), 'w') as f:
            f.write('\n'.join(wav_train_final[i]))

        with open(config_path+'PreaspirationTgListFold%s.txt' % str(i), 'w') as f:
            f.write('\n'.join(tg_train_final[i]))

        # build configs files that includes all train example except partition i - for training
        all_except_current_wav = []
        all_except_current_tg  = []
        for j in range(len(train_partitions)):
            if j == i:
                continue
            all_except_current_wav += wav_train_final[j]
            all_except_current_tg += tg_train_final[j]

        with open(config_path+'PreaspirationWavListExceptFold%s.txt' % str(i), 'w') as f:
            f.write('\n'.join(all_except_current_wav))
        with open(config_path+'PreaspirationTgListExceptFold%s.txt' % str(i), 'w') as f:
            f.write('\n'.join(all_except_current_tg))



