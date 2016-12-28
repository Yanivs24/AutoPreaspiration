import numpy as np
from shutil import copyfile
import sys




if __name__ == "__main__":

    if len(sys.argv) != 3:
        raise ValueError("expected 2 value - model's path and model's amount")

    models_path, models_amount = sys.argv[1:]
    models_amount = int(models_amount)
    models_sum = None
    for i in range(models_amount):
        w_i = np.loadtxt('%s/PreaspirationModelFold%s.classifier.pos' % (models_path, str(i)))
        print 'got model %s:\n%s' % (str(i), w_i)
        if models_sum is None:
            models_sum = w_i
        else:
            models_sum += w_i 
        
    models_avg = models_sum/models_amount

    # first element is vector sise - must be int
    vec_size = int(models_avg[0]) 

    print '\nAveraged Model:\n%s' % models_avg

    # save avrage model - first element is size
    np.savetxt('%s/PreaspirationModelFoldAvg.classifier.pos' % (models_path), models_avg[1:], newline=' ', fmt='%f', header = str(vec_size), comments = '')
    
    # neg model is unchanged
    copyfile(models_path+'/PreaspirationModelFold0.classifier.neg', models_path+'/PreaspirationModelFoldAvg.classifier.neg')