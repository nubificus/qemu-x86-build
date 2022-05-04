#!/bin/bash

DOCKER_BUILDKIT=0 docker build --network=host -t nubificus/vaccel-qemu \
	--build-arg "TOKEN=${TOKEN}" $@ .
