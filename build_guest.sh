#!/bin/bash

cd guest

DOCKER_BUILDKIT=1 docker build --network=host -f Dockerfile_rumprun.x86_64 -t nubificus/vaccel-qemu_rumprun --build-arg "TOKEN=$TOKEN" --target artifacts --output type=local,dest=./qemu-rumprun-x86_64 .

cp -r data rumprun_example/qemu_run.sh ./qemu-rumprun-x86_64
