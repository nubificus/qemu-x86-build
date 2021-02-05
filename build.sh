#!/bin/bash

DOCKER_BUILDKIT=1 docker build --network=host -t nubificus/unikernels_vaccel-qemu --build-arg "TOKEN=$TOKEN" .
