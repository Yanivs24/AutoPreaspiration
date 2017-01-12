#!/usr/bin/python
#
# This file is part of AutoPA - automatic extraction of pre-aspiration 
# from speech segments in audio files.
#
# Copyright (c) 2016 Yaniv Sheena
#
# This file is based on Autovot, a package for automatic extraction of
# voice onset time (VOT) from audio files (Copyright (c) 2014 Joseph 
# Keshet, Morgan Sonderegger, Thea Knowles)
#
# AutoPA is free software: you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# AutoPA is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with Autovot.  If not, see
# <http://www.gnu.org/licenses/>.
#
# auto_pa_decode_after_fe.py: If features have already been extracted
# (using auto_pa_extract_features.py) to files in in
# features_filename, with corresponding labels in labels_filename, for
# a set of stops, use an existing classifier (model_filename) to
# measure their PAs, outputting simply the average error
# (abs(predicted - labeled PA)) when done.

import argparse

from helpers.utilities import *


if __name__ == "__main__":

    # parse arguments
    parser = argparse.ArgumentParser(description='Decoding when features have already been extracted')
    parser.add_argument('features_filename', help="AutoPA front end features filename (training)")
    parser.add_argument('labels_filename', help="AutoPA front end labels filename (training)")
    parser.add_argument('model_filename', help="Name of classifier to be used to measure PA")
    parser.add_argument("--logging_level", help="Level of verbosity of information printed out by this program ("
                                                "DEBUG, INFO, WARNING or ERROR), in order of increasing verbosity. "
                                                "See http://docs.python.org/2/howto/logging for definitions. ("
                                                "default: %(default)s)", default="INFO")

    args = parser.parse_args()
    logging_defaults(args.logging_level)

    # decoding
    cmd_vot_decode = 'VotDecode -final_results -verbose %s -pos_only %s %s %s' % (args.logging_level,
                                                                             args.features_filename,
                                                                          args.labels_filename, args.model_filename)
    easy_call(cmd_vot_decode)
