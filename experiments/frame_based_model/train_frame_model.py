
'''Trains a simple deep NN on the MNIST dataset.
Gets to 98.40% test accuracy after 20 epochs
(there is *a lot* of margin for parameter tuning).
2 seconds per epoch on a K520 GPU.
'''

import numpy as np
np.random.seed(1337)  # for reproducibility

from keras.datasets import mnist
from keras.models import Sequential
from keras.layers.core import Dense, Dropout, Activation
from keras.optimizers import RMSprop, SGD
from keras.utils import np_utils

DATASET_FILE = 'pa_frame_dataset'

batch_size = 64
nb_epoch = 10

def train_keras_model(X_train, y_train, X_test, y_test, in_dim, out_dim=2):

	X_train = X_train.astype('float32')
	X_test = X_test.astype('float32')

	print X_train.shape[0], 'train samples'
	print X_test.shape[0], 'test samples'

	# convert class vectors to binary class matrices
	Y_train = np_utils.to_categorical(y_train, out_dim)
	Y_test = np_utils.to_categorical(y_test, out_dim)

	model = Sequential()
	model.add(Dense(200, input_shape=(in_dim,)))
	model.add(Activation('tanh'))
	model.add(Dropout(0.2))
	model.add(Dense(100))
	model.add(Activation('tanh'))
	model.add(Dropout(0.2))
	model.add(Dense(out_dim))
	model.add(Activation('softmax'))

	model.summary()

	model.compile(loss='categorical_crossentropy',
	              optimizer=RMSprop(),
	              metrics=['accuracy'])

	history = model.fit(X_train, Y_train,
	                    batch_size=batch_size, nb_epoch=nb_epoch,
	                    verbose=1, validation_data=(X_test, Y_test))

	score = model.evaluate(X_test, Y_test, verbose=0)
	print 'Test score:', score[0]
	print 'Test accuracy:', score[1]

	return model


if __name__ == '__main__':
    dataset = np.loadtxt(DATASET_FILE)

    data_size = len(dataset)


    # take 70% as train set and the rest will be test set
    train_size = int(0.7 * data_size)

    x_train = dataset[:train_size, :-1]
    y_train = dataset[:train_size, -1]
    x_test  = dataset[train_size:, :-1]
    y_test  = dataset[train_size:, -1]

    # train the model using the train set (test set for evaluation)
    in_dim = x_train.shape[1]
    model = train_keras_model(x_train, y_train, x_test, y_test, in_dim)

    # save model to a file
    print "Write model to 'frame_model.h5'"
    model.save('frame_model.h5')
    
