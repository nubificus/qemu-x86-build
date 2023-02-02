#!/bin/bash

usage()
{ 
	echo "Build the host where unikernel guest using vAccel can be executed"
	echo "usage:"
	echo "	-h		Display this help message"
	echo "	-u <gpu|fpga	Build host with vAccelrt support for GPUs or FPGAs"
	echo "	-r		Build host without vAccelrt support"
	exit 1
}

while getopts "hu:r" flag
do
    case "${flag}" in
        h)
		usage
	;;
        u)
		unikernel=unikraft
		haccel=$OPTARG
		DOCKER_BUILDKIT=1 docker build --network=host -f Dockerfile_$haccel -t nubificus/unikernels_vaccel_$haccel .
	;;
        r)
		unikernel=rumprun
		DOCKER_BUILDKIT=1 docker build --network=host -t nubificus/unikernels_vaccel-qemu --build-arg "TOKEN=$TOKEN" .
	;;
	*)
		usage
	;;
    esac
done

shift $((OPTIND-1))
if [ -z "${unikernel}" ]; then
	usage
fi
