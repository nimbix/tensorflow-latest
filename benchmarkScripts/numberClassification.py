#!/usr/bin/env python3
# https://stackoverflow.com/questions/50032721/how-to-force-tensorflow-to-use-all-available-gpus


import sys
import time
import tensorflow as tf
from tensorflow import keras
from keras_sequential_ascii import keras2ascii

def get_model():
    model = keras.Sequential([
        keras.layers.Flatten(input_shape=(32,32,3)),
        keras.layers.Dense(5000, activation='relu'),
        keras.layers.Dense(3000, activation='relu'),
        keras.layers.Dense(1000, activation='relu'),
        keras.layers.Dense(10, activation='sigmoid')
    ])
    model.compile(optimizer='SGD',
              loss='categorical_crossentropy',
              metrics=['accuracy'])

    print("\nPrinting model layout...")
    keras2ascii(model)
    return model

def cpuBench(X_train_scaled, y_train_encoded, X_test_scaled, y_test_encoded, numEpochs):
    # CPU
    with tf.device('/CPU:0'):
        model_cpu = get_model()
        model_cpu.fit(X_train_scaled, y_train_encoded, epochs = numEpochs, verbose=2)

def gpuBench(X_train_scaled, y_train_encoded, X_test_scaled, y_test_encoded, numEpochs):
    # GPU
    with tf.device('/GPU:0'):
        model_gpu = get_model()
        model_gpu.fit(X_train_scaled, y_train_encoded, epochs = numEpochs, verbose=2)

def gpuBenchAll(X_train_scaled, y_train_encoded, X_test_scaled, y_test_encoded, numEpochs):
    # GPU
    print("Running All GPU Benchmark")
    gpus = tf.config.list_logical_devices('GPU')
    # print(gpus)
    strategy = tf.distribute.MirroredStrategy()
    # strategy = tf.distribute.MirroredStrategy(gpus)
    # strategy = tf.distribute.OneDeviceStrategy(f"device:GPU:{len(gpus)-1}")
    with strategy.scope():
        model = keras.Sequential([
                        keras.layers.Flatten(input_shape=(32,32,3)),
                        keras.layers.Dense(5000, activation='relu'),
                        keras.layers.Dense(3000, activation='relu'),
                        keras.layers.Dense(1000, activation='relu'),
                        keras.layers.Dense(10, activation='sigmoid')
                    ])
        model.compile(optimizer='SGD',
                        loss='categorical_crossentropy',
                        metrics=['accuracy']
                    )
        model.fit(X_train_scaled, y_train_encoded, epochs = numEpochs, verbose=2)

def printResults(startTime:float, endTime:float) -> None:
    diff = endTime - startTime
    score = 24*3600/diff
    print(
        f"BENCHMARK INFO: Benchmark took {diff:0.2f} seconds to run with score of {score:0.2f}."
    )

def run(opts:dict, doDebug:bool=False):
    # Get options
    DO_CPU = opts.get('DO_CPU')
    DO_GPU = opts.get('DO_GPU')
    USE_ALL_GPU = opts.get('USE_ALL_GPU')
    NUM_EPOCHS = opts.get('NUM_EPOCHS')

    # if doDebug:
    #     print("Setting Verbosity to DEBUG")
    #     # import logging
    #     # logging.getLogger("tensorflow").setLevel(logging.DEBUG)

    # Get Data
    (X_train, y_train), (X_test, y_test) = keras.datasets.cifar10.load_data()

    # scaling image values between 0-1
    X_train_scaled = X_train/255
    X_test_scaled = X_test/255

    # one hot encoding labels
    y_train_encoded = keras.utils.to_categorical(y_train, num_classes = 10, dtype = 'float32')
    y_test_encoded = keras.utils.to_categorical(y_test, num_classes = 10, dtype = 'float32')

    if DO_CPU:
        print("\nRunning CPU Benchmark")
        startTime = time.time()
        cpuBench(X_train_scaled, y_train_encoded, X_test_scaled, y_test_encoded, NUM_EPOCHS)
        endTime = time.time()
        printResults(startTime, endTime)

    if DO_GPU:
        print("\nRunning GPU Benchmark")
        startTime = time.time()
        if USE_ALL_GPU:
            gpuBenchAll(X_train_scaled, y_train_encoded, X_test_scaled, y_test_encoded, NUM_EPOCHS)
        else:
            gpuBench(X_train_scaled, y_train_encoded, X_test_scaled, y_test_encoded, NUM_EPOCHS)
        endTime = time.time()
        printResults(startTime, endTime)

def main():
    # Default Settings
    opts = dict()
    opts['DO_CPU'] = True
    opts['DO_GPU'] = False
    opts['USE_ALL_GPU'] = False
    opts['NUM_EPOCHS'] = 10

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
        k += 1


    run(opts)

if __name__ == "__main__":
    main()
