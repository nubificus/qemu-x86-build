#!/bin/bash

docker run --privileged  --rm --gpus all -v $(pwd)/guest/qemu-guest-x86_64:/data -it --device=/dev/kvm nubificus/unikernels_vaccel_gpu bash /data/qemu_run.sh /data/data/ data/unikraft_vaccel_$1_kvm-x86_64
