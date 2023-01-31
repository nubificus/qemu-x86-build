#!/bin/bash

usage()
{ 
	echo "Build a unikernel image and get everything ready to run this unikernel:"
	echo "usage:"
	echo "	-h		Display this help message"
	echo "	-u <example>	Build unikraft unikernel"
	echo "	-r		Build rumprun unikernel"
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
		example=$OPTARG
	;;
        r)
		unikernel=rumprun
	;;
	*)
		usage
		exit 1
	;;
    esac
done

shift $((OPTIND-1))
if [ -z "${unikernel}" ]; then
	usage
	exit 1
fi

if [[ "$unikernel" == "rumprun" ]]; then
	cd guest
	
	sudo DOCKER_BUILDKIT=1 docker build --network=host -f Dockerfile_rumprun.x86_64 -t nubificus/vaccel-qemu_rumprun --build-arg "TOKEN=$TOKEN" --target artifacts --output type=local,dest=./qemu-guest-x86_64 .
	
	cp -r data ${unikernel}_example/qemu_run.sh ./qemu-guest-x86_64
elif [[ "$unikernel" == "unikraft" ]]; then
	if [ -z "${example}" ]; then
		usage
		exit 1
	fi
	pushd guest/
	pushd unikraft_example
	sudo DOCKER_BUILDKIT=1 docker build --network=host -f Dockerfile -t unikraft_vaccel_example --build-arg "EXAMPLE=$example" --target artifacts --output type=local,dest=../qemu-guest-x86-64 .
	popd
	sudo cp -r data unikraft_example/qemu_run.sh ./qemu-guest-x86-64
	popd
fi
