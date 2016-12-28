#! /usr/bin/env python
#
# This file is part of AutoPA - automatic extraction of pre-aspiration 
# from speech segments in audio files.
#
# Copyright (c) 2016 Yaniv Sheena
#
# Description: 
# Gets an examples' directory path as argument and filter all
# useless examples. This is done by reading TextGrid files and looking for
# 'pre' marks in their last tier. If such event starts earlier than 50ms after the beginning
# of the file or ends 60ms before the end of the file they are useless (we need window) and 
# therefore we delete them from the tier. If after this routine there are no 'pre' marks left -
# delete the example utterly (including WAV file).


# external imports
import os
import sys

# internal imports
from textgrid import TextGrid


def get_files_with_extension(dir_path, extention):
    return [os.path.join(dir_path, f_name) for f_name in os.listdir(dir_path) if f_name.endswith(extention)]



if __name__ == "__main__":

    # Assuming the first cmd-line argument (if existed) is the path of
    # the directory with the wav files, otherwise use current working dir.
    if len(sys.argv) != 2:
        raise ValueError("expected exactly one inputs - the dest dir path")

    dir_path = sys.argv[1]

    # get a list of wav files paths
    tg_list = get_files_with_extension(dir_path, '.TextGrid')

    # loop over all examples' TextGrids
    for tg_file in tg_list:
        tg = TextGrid()
        tg.read(tg_file) 

        file_length = tg.xmax()

        # The Preaspirations are expected to be in the last tier
        last_tier = tg[-1]

        # build a list of all Preaspiration intervals in the file
        pa_events = [interval for interval in last_tier if interval.mark() == 'pre']

        # filter events that are too close to the boundries of the file
        remove_count = 0
        for interval in pa_events:
            if interval.xmin() < 0.05 or interval.xmax() >  file_length - 0.06:
                print '%s - removing pre tier due to illegal range: (%s, %s)' % (os.path.split(tg_file)[-1], str(interval.xmin()),
                                                                                 str(interval.xmax()))
                last_tier.remove(interval)
                remove_count += 1

        # after filtering - if there are no events left, delete example from 
        # 'dir_path' and continue looping
        if len(pa_events) == remove_count:
            print 'Deleting %s since it has no PA events in the expected range' % os.path.split(tg_file)[-1]
            os.remove(tg_file)
            wav_file = tg_file[:tg_file.rfind('.')] + '.wav'
            os.remove(wav_file)
            continue

        # There are good pa event - change tier name to 'bell' (for uniformity) and save
        # (run over the old one) the TextGrid file
        last_tier.change_name('bell')
        tg.write(tg_file)