#!/usr/bin/python
# This file is part of AutoPA - automatic extraction of pre-aspiration 
# from speech segments in audio files.
#
# Copyright (c) 2016 Yaniv Sheena

import os
import sys



if __name__ == "__main__":

    if len(sys.argv) != 2:
        raise ValueError("Please supply a path for the result dir")

    result_path = sys.argv[1]
    result_files = os.listdir(result_path)

    results = {}
    for file in result_files:
        contents = ''
        with open(result_path + '/' + file) as f:
            contents = f.read()

        results[file] = [0]*7
        for i, time_ms in enumerate((2,5,10,15,20,25,50)):
            word_to_find = '%s msec:' % str(time_ms)
            start_index = contents.find(word_to_find)+len(word_to_find)
            end_index = contents.find('\n', start_index)
            value = float(contents[start_index: end_index])
            results[file][i] = value




