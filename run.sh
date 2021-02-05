#!/bin/bash

##docker run --rm --network=host --device=/dev/net/tun --cap-add NET_ADMIN --gpus all -v $(pwd)/guest/qemu-rumprun-x86_64:/data -it --device=/dev/kvm nubificus/unikernels_vaccel-qemu
docker run --rm --network=host --device=/dev/net/tun --cap-add NET_ADMIN --gpus all -it --device=/dev/kvm nubificus/unikernels_vaccel-qemu
