#!/bin/bash

#docker run --rm --network=host --device=/dev/net/tun --cap-add NET_ADMIN --gpus all -v $(pwd)/guest/qemu-guest-aarch64:/data -it --device=/dev/kvm nubificus/vaccel-qemu:aarch64
docker run --rm --network=host --device=/dev/net/tun --cap-add NET_ADMIN --gpus all -v $(pwd)/guest/qemu-guest-x86_64:/data --device=/dev/kvm --device=/dev/vhost-vsock -it nubificus/vaccel-qemu
