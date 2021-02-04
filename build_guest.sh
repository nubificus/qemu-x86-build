#!/bin/bash

usage()
{ 
	echo "Build a unikernel image and get everything ready to run this unikernel:"
	echo "usage:"
	echo "	-h	Display this help message"
	echo "	-u	Build unikraft unikernel"
	echo "	-r	Build rumprun unikernel"
	exit 1
}

while getopts "hur" flag
do
    case "${flag}" in
        h)
		usage
	;;
        u)
		unikernel=unikraft
	;;
        r)
		unikernel=rumprun
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

cd guest

DOCKER_BUILDKIT=1 docker build --network=host -f Dockerfile_${unikernel}.x86_64 -t nubificus/vaccel-qemu_${unikernel} --build-arg "TOKEN=$TOKEN" --target artifacts --output type=local,dest=./qemu-guest-x86_64 .

cp -r data networks ${unikernel}_example/qemu_run.sh ./qemu-guest-x86_64
