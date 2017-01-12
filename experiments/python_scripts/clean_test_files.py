#!/usr/bin python
import os
from shutil import copyfile, rmtree



def delete_dirs(dir_paths):
    ''' deletes dir if the dir exists or has premission'''
    for c_dir in dir_paths:
        try:
            rmtree(c_dir)
        except OSError:
            pass


if __name__ == "__main__":
    base_path = '/home/yaniv/Documents/Research/VOT/autovot/experiments/data/pa_all_combined/formated'
    tg_files_path = '/home/yaniv/Documents/Research/VOT/autovot/experiments/config/PreaspirationTestTgList.txt'
    with open(tg_files_path) as f:
        tg_files_str = f.read()

    tg_files = tg_files_str.split('\n')

    # run over new TG files with old
    for file in tg_files:
        copyfile(base_path+'/'+os.path.split(file)[1], file)