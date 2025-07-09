#!/usr/bin/env bash

set -x
cd /opt/lambda/lambda-tensorflow-benchmark
git config --global --add safe.directory /opt/lambda/lambda-tensorflow-benchmark

min_num_gpus=$1
max_num_gpus=$2
num_runs=$3
num_batches_per_run=$4
thermal_sampling_frequency=$5
config_file=/opt/lambda/lambda-tensorflow-benchmark/config/$6
gpuVender=$7

TF_XLA_FLAGS=--tf_xla_auto_jit=2 \
    ./batch_benchmark.sh \
    $min_num_gpus \
    $max_num_gpus \
    $num_runs \
    $num_batches_per_run \
    $thermal_sampling_frequency \
    $config_file \
    $gpuVender
