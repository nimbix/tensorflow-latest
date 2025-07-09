#!/usr/bin/env python3
# https://stackoverflow.com/questions/50032721/how-to-force-tensorflow-to-use-all-available-gpus

import time
import tensorflow as tf
from tensorflow import keras
from keras_sequential_ascii import keras2ascii

def get_model(hidden_layers=1, numDense=500):
    # Flatten layer for input
    layers = [keras.layers.Flatten(input_shape=(28, 28))]
    # hideen layers
    for i in range(hidden_layers):
        layers.append(keras.layers.Dense(numDense, activation='relu'),)
    # output layer
    layers.append(keras.layers.Dense(10, activation='sigmoid'))
    model = keras.Sequential(layers)
    model.compile(optimizer='adam',
                  loss='sparse_categorical_crossentropy',
                  metrics=['accuracy'])

    print("\nPrinting model layout...")
    keras2ascii(model)
    return model

def cpuBench(train_images_scaled, train_labels, numEpochs, numHiddenLayers, numDense):
    with tf.device('/CPU:0'):
        cpu_model = get_model(hidden_layers=numHiddenLayers, numDense=numDense)
        cpu_model.fit(train_images_scaled, train_labels, epochs=numEpochs, verbose=2)

def gpuBench(train_images_scaled, train_labels, numEpochs, numHiddenLayers, numDense):
    # GPU
    with tf.device('/GPU:0'):
        model_gpu = get_model(hidden_layers=numHiddenLayers, numDense=numDense)
        model_gpu.fit(train_images_scaled, train_labels, epochs=numEpochs, verbose=2)

def gpuBenchAll(train_images_scaled, train_labels, numEpochs, numHiddenLayers, numDense):
    # GPU
    gpus = tf.config.list_logical_devices('GPU')
    strategy = tf.distribute.MirroredStrategy(gpus)
    with strategy.scope():
        model_gpu = get_model(hidden_layers=numHiddenLayers, numDense=numDense)
        model_gpu.fit(train_images_scaled, train_labels, epochs=numEpochs, verbose=2)

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
    NUM_HIDDEN_LAYERS = 3
    NUM_DENSE = 500

    # if doDebug:
    #     print("Setting Verbosity to DEBUG")
    #     # import logging
    #     # logging.getLogger("tensorflow").setLevel(logging.DEBUG)

    # Get Data
    # loading dataset
    fashion_mnist = keras.datasets.fashion_mnist
    (train_images, train_labels), (test_images, test_labels) = fashion_mnist.load_data()

    # scaling
    train_images_scaled = train_images / 255.0

    if DO_CPU:
        print("\nRunning CPU Benchmark")
        startTime = time.time()
        cpuBench(train_images_scaled, train_labels, NUM_EPOCHS, NUM_HIDDEN_LAYERS, NUM_DENSE)
        endTime = time.time()
        printResults(startTime, endTime)

    if DO_GPU:
        print("\nRunning GPU Benchmark")
        startTime = time.time()
        if USE_ALL_GPU:
            gpuBenchAll(train_images_scaled, train_labels, NUM_EPOCHS, NUM_HIDDEN_LAYERS, NUM_DENSE)
        else:
            gpuBench(train_images_scaled, train_labels, NUM_EPOCHS, NUM_HIDDEN_LAYERS, NUM_DENSE)
        endTime = time.time()
        printResults(startTime, endTime)
