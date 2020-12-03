#!/bin/bash

docker run --rm --network=host --gpus all -v $(pwd)/guest/qemu-guest-x86_64:/data -it --device=/dev/kvm cloudkernels/vaccel-qemu
