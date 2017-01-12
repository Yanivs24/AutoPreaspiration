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
# auto_pa_performance.py: Compute various measures of performance
# given a set of labeled PAs and predicted PAs for the same stops,
# optionally writing information for each stop to a CSV file.
#

import argparse, os, csv
import numpy as np
import scipy.stats

corr2 = scipy.stats.spearmanr
corr1 = scipy.stats.pearsonr


from helpers.textgrid import *
from helpers.utilities import *

def num_lines(filename):
    lines = 0
    for _ in open(filename):
        lines += 1
    return lines


def read_textgrid_tier(textgrid_filename, pa_tier, mark):
     # read TextGrid
    textgrid = TextGrid()
    textgrid.read(textgrid_filename)

    # extract tier names
    tier_names = textgrid.tierNames()

    # check if the PA tier is one of the tiers in the TextGrid
    PAs = list()
    if pa_tier in tier_names:
        tier_index = tier_names.index(pa_tier)
        # run over all intervals in the tier
        for interval in textgrid[tier_index]:
            if interval.mark() == mark:
                PAs.append(interval)
    return PAs



if __name__ == "__main__":
    # parse arguments
    parser = argparse.ArgumentParser(description='Compute various measures of performance given a set of labeled PAs'
                                                 'and predicted PAs for the same stops, optionally writing information'
                                                 'for each stop to a CSV file.')
    parser.add_argument('labeled_textgrid_list', help="textfile listing TextGrid files containing manually labeled "
                                                      "PAs (one file per line)")
    parser.add_argument('predicted_textgrid_list', help="textfile listing TextGrid files containing predicted PAs ("
                                                        "one file per line). This can be the same as "
                                                        "labeled_textgrid_list, provided two different tiers are "
                                                        "given for labeled_pa_tier and predicted_pa_tier.")
    parser.add_argument('labeled_pa_tier', help='name of the tier containing manually labeled PAs in the TextGrids '
                                                 'in labeled_textgrid_list (default: %(default)s)', default='pa')
    parser.add_argument('predicted_pa_tier', help='name of the tier containing automatically labeled PAs in the '
                                                   'TextGrids in predicted_textgrid_list (default: %(default)s)',
                        default='AutoPA')
    parser.add_argument('--csv_file', help='csv file to dump labeled and predicted PA info to (default: none)')
    args = parser.parse_args()

    if is_textgrid(args.labeled_textgrid_list) and is_textgrid(args.predicted_textgrid_list):
        labeled_textgrids = [args.labeled_textgrid_list]
        predicted_textgrids = [args.predicted_textgrid_list]
    else:
        if num_lines(args.labeled_textgrid_list) != num_lines(args.predicted_textgrid_list):
            print "Error: the files %s and %s should have the same number of lines" % (args.labeled_textgrid_list,
                                                                                       args.predicted_pa_tier)
            exit()

        f = open(args.labeled_textgrid_list)
        labeled_textgrids = f.readlines()
        f.close()

        f = open(args.predicted_textgrid_list)
        predicted_textgrids = f.readlines()
        f.close()

    if len(labeled_textgrids) != len(predicted_textgrids):
        logging.error("Something's wrong. Didn't read the same number of files from textgrid lists.")

    x_xmin = []
    x_xmax = []
    x_pa = []
    y_xmin = []
    y_xmax = []
    y_pa = []

    x_files = []
    y_files = []
    
    for labeled_textgrid, predicted_textgrid in zip(labeled_textgrids, predicted_textgrids):
        labeled_pas = read_textgrid_tier(labeled_textgrid.strip(), args.labeled_pa_tier, 'pre')

        # ignore early labels (there is no prediction of them)
        #labeled_pas = filter(lambda x: x.xmin() > 0.05, labeled_PAs)

        x_xmin = x_xmin + [x.xmin() for x in labeled_pas]
        x_xmax = x_xmax + [x.xmax() for x in labeled_pas]
        x_pa = x_pa + [(x.xmax()-x.xmin()) for x in labeled_pas]
        x_files = x_files + [labeled_textgrid.strip() for x in labeled_pas]

        predicted_pas = read_textgrid_tier(predicted_textgrid.strip(), args.predicted_pa_tier, 'pred')
        y_xmin = y_xmin + [y.xmin() for y in predicted_pas]
        y_xmax = y_xmax + [y.xmax() for y in predicted_pas]
        y_pa = y_pa + [(y.xmax()-y.xmin()) for y in predicted_pas]
        y_files = y_files + [predicted_textgrid.strip() for x in predicted_pas]

        # Yaniv addition
        if len(labeled_pas) != len(predicted_pas):
            print 'Error - pre lables amount in the tier %s in "%s" is not identical'\
                     ' to the predictions amount in the tier %s in "%s"' \
                     % (args.labeled_pa_tier, labeled_textgrid, args.predicted_pa_tier, predicted_textgrid)


    labF = os.path.abspath(args.labeled_textgrid_list)
    predF = os.path.abspath(args.predicted_textgrid_list)


    print "\n\nEvaluating labeled vs. predicted preaspiration (pa), using:"
    print "- labeled PAs: '%s' tier in %s" % (args.labeled_pa_tier, labF)
    print "- predicted PAs: '%s' tier in %s" % (args.predicted_pa_tier, predF)

    # performance measure 1
    print
    print "Correlations (Pearson/Spearman) between predicted/labeled:"
    print "-------------"

    print "Left edge (PA onset): ", corr1(x_xmin, y_xmin)[0], "/", corr2(x_xmin, y_xmin)[0]
    print "Right edge (PA offset): ", corr1(x_xmax, y_xmax)[0], "/", corr2(x_xmax, y_xmax)[0]
    print "PAs: ", corr1(x_pa, y_pa)[0], "/", corr2(x_pa, y_pa)[0]

    print "\n(Note: if the Pearson and Spearman correlations differ much,\nyou probably have outliers which are " \
          "strongly influencing Pearson's R)\n"

    # numpy arrays of labeled PAs and predicted PAs (in sec)
    X, Y = np.array(x_pa), np.array(y_pa)

    # Yaniv's addition
    print "Mean of labeled/predicted preaspiration: %sms, %sms" % (str(1000*np.mean(X)), str(1000*np.mean(Y)))
    print "Standard deviation of labeled/predicted preaspiration: %sms, %sms" % (str(1000*np.std(X)), str(1000*np.std(Y)))
    print "max of labeled/predicted preaspiration: %sms, %sms" % (str(1000*np.max(X)), str(1000*np.max(Y)))
    print "min of labeled/predicted preaspiration: %sms, %sms" % (str(1000*np.min(X)), str(1000*np.min(Y)))
    print "Mean error of left edge predictions: %sms" % str(1000*np.mean(np.abs(np.array(x_xmin)-np.array(y_xmin))))
    print "Mean error of right edge predictions: %sms" % str(1000*np.mean(np.abs(np.array(x_xmax)-np.array(y_xmax))))
    print "------------------------------\n"

    # performance measure 2
    print "Mean, standard deviation of labeled/predicted difference:"
    print "------------------------------"
    print "PA:", 1000*np.mean(abs(X-Y)), "msec,", 1000*np.std(abs(X-Y)), "msec\n"

    # performance measure 3
    thresholds = [2, 5, 10, 15, 20, 25, 50]
    print "Percentage of examples with labeled/predicted PA difference of at most:"
    print "------------------------------"


    for thresh in thresholds:
        print "%d msec: " % thresh, 100*(len(X[abs(X-Y)< thresh/1000.0])/float(len(X)))

    ## dump predicted/labeled PA info to a CSV, for later examination in R, excel, etc.
    if args.csv_file:
        print "\nWriting labeled / predicted PA info to %s" % args.csv_file
        out_file = open(args.csv_file, 'wb')
        csv_file = csv.writer(out_file)
        csv_file.writerow(['filename_labeled', 'filename_predicted', 'time_in_labeledF', 'time_in_predictedF',
                           'tier_in_labeledF', 'tier_in_predictedF', 'pa_labeled', 'pa_predicted'])
        for i, xmin in enumerate(x_xmin):
            csv_file.writerow([x_files[i], y_files[i], str(xmin), str(y_xmin[i]), args.labeled_pa_tier,
                               args.predicted_pa_tier, str(x_pa[i]), str(y_pa[i])])
        out_file.close()
