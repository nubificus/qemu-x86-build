#!/bin/bash

DOCKER_BUILDKIT=1 docker build --network=host -t nubificus/vaccel-qemu --build-arg "TOKEN=$TOKEN" .
