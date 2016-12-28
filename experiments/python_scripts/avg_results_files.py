import os
import re
import sys
import numpy as np



if __name__ == "__main__":

    if len(sys.argv) != 2:
        raise ValueError("expected 1 value - results path")

    results_path = sys.argv[1]
    current_path = os.getcwd()

    results_full_path = current_path + '/' + results_path


    file_data = ''
    numbers_res = []
    for file in os.listdir(results_path):
        with open(os.path.join(results_full_path, file), 'r') as f:
            file_data = f.read()

        # get all results in the order they appeared
        numbers_res.append(map(float, re.findall('\d+\.\d+', file_data)))
        text_pattern = re.split('\d+\.\d+', file_data)

    # average results
    avg_results = np.zeros(len(numbers_res[0]))
    for res in numbers_res:
        avg_results = avg_results+np.array(res)

    avg_results /= len(numbers_res)

    print 'Read %s result files - the average is:' % len(numbers_res)
    print avg_results

    # write results to file with the same format
    res_path = os.path.join(results_full_path, 'averaged_results.txt')
    f = open(res_path, 'w')
    for num, part in zip(avg_results, text_pattern):
        f.write(part)
        f.write(str(num))

    f.close()

    print 'Saved average results to: %s' % res_path

