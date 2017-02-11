import numpy as np
import random
import sys


NUM_OF_FEATURES   = 9
LEFT_WINDOW_SIZE  = 50
RIGHT_WINDOW_SIZE = 60

FEATURE_NAMES_FILE = 'feature_extractions/feature_names.txt'
DATA_SET_FILE      = 'pa_frame_dataset'

def get_feature_files(feature_names_file):
	with open(feature_names_file) as f:
		file_names = f.readlines()

	return [line.strip() for line in file_names]

def read_features(file_name):
	return np.loadtxt(file_name, skiprows=1)[:, :NUM_OF_FEATURES]

def write_examples(data_set):
	with open(DATA_SET_FILE, 'w') as f:
		for x,y in data_set:
			f.write("%s %s\n" % (' '.join(map(str, x)), str(y)))


if __name__ == '__main__':

	if len(sys.argv) == 2:
		_ , feature_names_file = sys.argv	
	elif len(sys.argv) == 1:
		feature_names_file = FEATURE_NAMES_FILE	
	else:
		raise ValueError('Usage: %s [feature_filenames_path]' % sys.argv[0])


	# get feature files, one file for each example (voice segment)
	print 'Reading feature file-names from %s' % feature_names_file
	feature_files = get_feature_files(feature_names_file)

	data_set = []
	print 'Extracting frames from the feature files..'
	# run over all feature files
	for file in feature_files:

		# get feature matrix and the segment size
		fe_matrix = read_features(file) 
		segment_size = fe_matrix.shape[0]

		# For each time-frame, concatenate 2 vectors of frames to each side. 
		# We represnt each frame with 5 vectors, when the frame's vector is 
		# in the middle (dim is 9*5=45)
		for i in range(segment_size-4):
			frame = np.concatenate(fe_matrix[i:i+5,:])

			# if the represented frame is within the pre-aspiration range - set label 1
			# and otherwise the label will be 0
			label = 0
			if (i+2 >= LEFT_WINDOW_SIZE) and (i+2 <= (segment_size-RIGHT_WINDOW_SIZE)):
				label = 1

			# append the example to the data set
			data_set.append((frame, label))


	# since there are much more frames that are not part of pre-aspiration event (negative examples),
	# we balance the data set by randomly dropping such negative examples.
	positive_size = sum(example[1]==1 for example in data_set)
	negative_drop_amount = len(data_set) - 2*positive_size

	# shuffle data 
	random.shuffle(data_set)

	ind = 0
	dropped_amount = 0
	# Remove first #negative_drop_amount negative examples
	while dropped_amount < negative_drop_amount:
		if data_set[ind][1] == 0:
			data_set.pop(ind)
			dropped_amount += 1
		else:
			ind += 1


	# shuffle data again
	random.shuffle(data_set)

	# write data set to file
	print 'Write resulted examples to: "%s"' % DATA_SET_FILE
	write_examples(data_set)








	
