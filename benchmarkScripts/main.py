#!/usr/bin/env python3
# https://stackoverflow.com/questions/50032721/how-to-force-tensorflow-to-use-all-available-gpus

import os
import sys
import shutil
import clothesClassification
import numberClassification

def main():
    # Default Settings
    opts = dict()
    opts['DO_CPU'] = True
    opts['DO_GPU'] = False
    opts['USE_ALL_GPU'] = False
    opts['NUM_EPOCHS'] = 10

    # do_debug = False

    # Turn off warnings
    os.environ["TF_CPP_MIN_LOG_LEVEL"]='2'

    # Parse input
    k = 1
    while k < len(sys.argv):
        if sys.argv[k] == "-doCpuTest":
            k += 1
            if sys.argv[k].lower() in ['yes', 'y']:
                opts['DO_CPU'] = True
            else:
                opts['DO_CPU'] = False
        elif sys.argv[k] == "-doGpuTest":
            k += 1
            if sys.argv[k].lower() in ['yes', 'y']:
                opts['DO_GPU'] = True
            else:
                opts['DO_GPU'] = False
        elif sys.argv[k] == "-useAllGPUs":
            k += 1
            if sys.argv[k].lower() in ['yes', 'y']:
                opts['USE_ALL_GPU']  = True
            else:
                opts['USE_ALL_GPU'] = False
        elif sys.argv[k] == "-numEpochs":
            k += 1
            opts['NUM_EPOCHS'] = int(sys.argv[k])
        elif sys.argv[k] == "-benchmark":
            k += 1
            benchmark = sys.argv[k]
        elif sys.argv[k] == "-debug":
            os.environ["TF_CPP_MIN_LOG_LEVEL"]='0'
            # do_debug = True
        k += 1

    # Now need to move dataset files from /root/.keras to ${HOME}/.keras
    if os.environ.get("HOME") not in ['/', '/root']:
        shutil.copytree("/tmp/.keras/datasets", f'{os.environ.get("HOME")}/.keras/datasets',dirs_exist_ok=True)


    print("TF_CPP_MIN_LOG_LEVEL:", os.environ.get("TF_CPP_MIN_LOG_LEVEL"))
    if benchmark == "clothesClassification":
        clothesClassification.run(opts)
    elif benchmark == "numberClassification":
        numberClassification.run(opts)


if __name__ == "__main__":
    main()
