import sys
import numpy as np


from keras.models import load_model

MODEL_FILE = 'frame_model.h5'
LEFT_WINDOW_SIZE  = 50
RIGHT_WINDOW_SIZE = 60
NUM_OF_FEATURES   = 9

def get_feature_files(feature_names_file):
    with open(feature_names_file) as f:
        file_names = f.readlines()

    return [line.strip() for line in file_names]

def read_features(file_name):
    return np.loadtxt(file_name, skiprows=1)[:, :NUM_OF_FEATURES]

def smooth_binary_vector(vec):
    ''' Smooth binary vector using convolotion with 5 valued vectores of ones:
        [1,1,1,1,1], and binary threshold of 3'''
    smooth_vec = np.zeros(len(vec))
    for i in range(2, len(vec)-2):
        if sum(vec[i-2:i+3]) >= 3:
            smooth_vec[i] = 1

    return smooth_vec

def find_longest_event(vec):
    ''' finds the longest '1' subvector within a binary vector, returns the 
        indexes of the boundaries '''

    count = 0
    max_count = 0
    end_index = 0
    for i, val in enumerate(vec):
        if val == 1:
            count += 1 
        else:
            if count > max_count:
                max_count = count
                end_index = i
                count = 0

    return end_index-max_count, end_index-1



if __name__ == '__main__':

    try:
        _ , feature_names_file = sys.argv
    except ValueError:
        raise ValueError('Usage: %s feature_filenames_path' % sys.argv[0])

    # returns a compiled model
    # identical to the previous one
    model = load_model(MODEL_FILE)

    # get names of feature files to decode
    feature_files = get_feature_files(feature_names_file)

    # run over all feature files
    left_err = 0
    right_err = 0
    X = []
    Y = []
    for file in feature_files:
        # get feature matrix and the segment size
        fe_matrix = read_features(file) 
        segment_size = fe_matrix.shape[0]

        # get real labels - due to the windows sizes
        real_labels = (LEFT_WINDOW_SIZE, segment_size-RIGHT_WINDOW_SIZE)


        # For each time-frame, concatenate 2 vectors of frames to each side. 
        # We represnt each frame with 5 vectors, when the frame's vector is 
        # in the middle (dim is 9*5=45), and predicting for each frame whether
        # it part of the pre-aspiration event
        binary_vect = np.zeros(segment_size)
        for i in range(segment_size-4):
            frame = np.concatenate(fe_matrix[i:i+5,:])
            # get the binary prediction for each 1ms frame
            binary_vect[i+2] = np.argmax(model.predict(frame.reshape((1, 45))))

        # smooth the binary vector to avoid singular predictions
        smooth_vec = smooth_binary_vector(binary_vect)

        # find indexes of the longest subvector contains only ones
        predicted_labels = find_longest_event(smooth_vec)
        #print 'real labels: ', real_labels
        #print 'predicted labels: ', predicted_labels    

        # store pre-aspiration durations
        X.append(real_labels[1]-real_labels[0])
        Y.append(predicted_labels[1]-predicted_labels[0])

        left_err += np.abs(real_labels[0]-predicted_labels[0])
        right_err += np.abs(real_labels[1]-predicted_labels[1])

    print 'left_err: ',  float(left_err)/len(feature_files)
    print 'right_err: ', float(right_err)/len(feature_files)

    X = np.array(X)
    Y = np.array(Y)

    print "Mean of labeled/predicted preaspiration: %sms, %sms" % (str(np.mean(X)), str(np.mean(Y)))
    print "Standard deviation of labeled/predicted preaspiration: %sms, %sms" % (str(np.std(X)), str(np.std(Y)))
    print "max of labeled/predicted preaspiration: %sms, %sms" % (str(np.max(X)), str(np.max(Y)))
    print "min of labeled/predicted preaspiration: %sms, %sms" % (str(np.min(X)), str(np.min(Y)))


    thresholds = [2, 5, 10, 15, 20, 25, 50]
    print "Percentage of examples with labeled/predicted PA difference of at most:"
    print "------------------------------"
    
    for thresh in thresholds:
        print "%d msec: " % thresh, 100*(len(X[abs(X-Y)<thresh])/float(len(X)))
