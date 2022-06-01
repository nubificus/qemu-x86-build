#!/bin/bash

##docker run --rm --network=host --device=/dev/net/tun --cap-add NET_ADMIN --gpus all -v $(pwd)/guest/qemu-rumprun-x86_64:/data -it --device=/dev/kvm nubificus/unikernels_vaccel-qemu
docker run --rm --network=host --device=/dev/net/tun --gpus all -v $(pwd)/guest/qemu-guest-x86_64:/data -it --device=/dev/kvm nubificus/unikernels_vaccel-qemu bash /data/qemu_run.sh $1 $2
