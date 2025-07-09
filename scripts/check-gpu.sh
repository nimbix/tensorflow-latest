#!/usr/bin/env bash

function checkNvidiaDriver() (
    # Now need to check that the driver version is at least the minimum version...
    # https://www.tensorflow.org/install/pip#software_requirements
    MINIMUM_DRIVER_VERSION=525.60.13
    MIN_MAJOR=$(echo "$MINIMUM_DRIVER_VERSION" | tr '.' ' ' | awk '{print $1}')
    MIN_MINOR=$(echo "$MINIMUM_DRIVER_VERSION" | tr '.' ' ' | awk '{print $2}')
    MIN_PATCH=$(echo "$MINIMUM_DRIVER_VERSION" | tr '.' ' ' | awk '{print $3}')
    MIN_VERSION_NUMBER=$((MIN_MAJOR*1024*1024 + MIN_MINOR*1024 + MIN_PATCH))

    CURRENT_DRIVER_VERSION=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader --id=0)
    CUR_MAJOR=$(echo "$CURRENT_DRIVER_VERSION" | tr '.' ' ' | awk '{print $1}')
    CUR_MINOR=$(echo "$CURRENT_DRIVER_VERSION" | tr '.' ' ' | awk '{print $2}')
    CUR_PATCH=$(echo "$CURRENT_DRIVER_VERSION" | tr '.' ' ' | awk '{print $3}')
    CUR_VERSION_NUMBER=$((CUR_MAJOR*1024*1024 + CUR_MINOR*1024 + CUR_PATCH))

    echo "INFO: Detected NVIDIA Driver $CURRENT_DRIVER_VERSION"

    if [[ $CUR_VERSION_NUMBER -ge $MIN_VERSION_NUMBER ]]; then
        echo "INFO: NVIDIA driver up-to-date"
        return 0
    else
        echo "ERROR: Current driver version is insufficient for GPU enabled compute."
        echo "       Minimum driver needed as reported by TensorFlow is $MINIMUM_DRIVER_VERSION"
        exit 255
    fi
)

#!/usr/bin/env bash

function checkCudaVersion() (
    # Now need to check that the driver version is at least the minimum version...
    MINIMUM_CUDA_VERSION=12.3
    MIN_MAJOR=$(echo "$MINIMUM_CUDA_VERSION" | tr '.' ' ' | awk '{print $1}')
    MIN_MINOR=$(echo "$MINIMUM_CUDA_VERSION" | tr '.' ' ' | awk '{print $2}')
    MIN_CUDA_NUMBER=$((MIN_MAJOR*1024 + MIN_MINOR))

    CURRENT_CUDA_VERSION=$(nvidia-smi | grep CUDA | awk '{print $9}')
    CUR_MAJOR=$(echo "$CURRENT_CUDA_VERSION" | tr '.' ' ' | awk '{print $1}')
    CUR_MINOR=$(echo "$CURRENT_CUDA_VERSION" | tr '.' ' ' | awk '{print $2}')
    CUR_CUDA_NUMBER=$((CUR_MAJOR*1024 + CUR_MINOR))

    echo "INFO: Detected CUDA Version $CURRENT_CUDA_VERSION"

    if [[ $CUR_CUDA_NUMBER -ge $MIN_CUDA_NUMBER ]]; then
        echo "INFO: CUDA version is up-to-date"
        return 0
    else
        echo "ERROR: Current cuda version is insufficient for GPU enabled compute."
        echo "       Minimum cuda version needed as reported by TensorFlow is $MINIMUM_CUDA_VERSION"
        exit 255
    fi
)

function checkGPU() (
    set -e
    # Check if nvidia-smi is available
    if [[ ! -f /usr/local/nvidia/bin/nvidia-smi ]]; then
        echo "INFO: No GPU Detected"
        return 0
    fi

    echo "INFO: GPU System Detected"
    export PATH=/usr/local/nvidia/bin:$PATH

    checkNvidiaDriver
    checkCudaVersion
    echo "INFO: Enabled GPU Compute"
    exit 0
)
