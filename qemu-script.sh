#!/bin/bash

export LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}
export QEMU_AUDIO_DRV=none
export VACCEL_BACKENDS=${VACCEL_BACKENDS:=/usr/local/lib/libvaccel-jetson.so}
export VACCEL_IMAGENET_NETWORKS=${VACCEL_IMAGENET_NETWORKS:=/data/networks}
export VACCEL_DEBUG_LEVEL=${VACCEL_DEBUG_LEVEL:=4}

smp=1
cpu=host
ram=512

machine="pc,accel=kvm"
kernel="-kernel bzImage"
dtb=""
rootfs=rootfs.img
cmdline="rw root=/dev/vda console=ttyS0 "
stderr=run/stderr.log
extra_args=
cid=

cd /data
mkdir -p run
while getopts 'c:m:r:a:s:v:n:' opt; do
	case $opt in
		c)
			# VM vCPUs
			[[ $OPTARG =~ ^[0-9]+$ ]] || error "${opt}: ${OPTARG} is not a number" 1
			smp="${OPTARG}"
			;;
		m)
			# VM RAM
			[[ $OPTARG =~ ^[0-9]+$ ]] || error "${opt}: ${OPTARG} is not a number" 1
			ram="${OPTARG}"
			;;
		r)
			# VM rootfs
			[[ -z "${OPTARG}" ]] && error "${opt}: requires a non-empty string" 1
			rootfs="${OPTARG}"
			;;
		a)
			# VM kernel command line append
			cmdline+="${OPTARG}"
			;;
		s)
			# QEMU output to socket
			[[ -z "${OPTARG}" ]] && error "${opt}: requires a non-empty string" 1
			vm_id="${OPTARG}"
			stderr="${vm_id}-stderr.log"
			extra_args+="-serial pipe:./run/${vm_id}.serial "
			extra_args+="-chardev socket,id=monitor,path=./run/${vm_id}.monitor,server,nowait "
			extra_args+="-monitor chardev:monitor "
			;;
		n)
			# VM w/ network
			[[ -z "${OPTARG}" ]] && mac="52:54:00:12:34:01" || mac="${OPTARG}"
			extra_args+="-netdev type=tap,id=net0 -device virtio-net,netdev=net0 "
			;;
		v)
			# VM w/ vsock
			[[ $OPTARG =~ ^[0-9]+$ ]] || error "${opt}: ${OPTARG} is not a number" 1
			cid="${OPTARG}"
			extra_args+="-device vhost-vsock-pci,id=vhost-vsock-pci0,guest-cid=${cid} "
			;;
		:)
			error "Option -$OPTARG requires an argument" 1
			;;
		\?)
			exit 1
			;;
	esac
done
cmdline+="mem=${ram}M"

mkdir -p networks
if [[ ! -f networks/.downloaded ]]; then
	/usr/local/share/jetson-inference/tools/download-models.sh
	[[ $? -eq 0 ]] && touch networks/.downloaded
	cp -r /usr/local/bin/networks/* networks/
fi

fsck.ext4 -fy $rootfs 1>/dev/null 2>&1

[[ -z "${cid}" ]] || vaccelrt-agent -a "vsock://${cid}:2048" &

TERM=linux qemu-system-x86_64 \
	-cpu $cpu -m $ram -smp $smp -M $machine -nographic $kernel $dtb -append "$cmdline" 2>stderr.log \
	-drive if=none,id=rootfs,file=$rootfs,format=raw,cache=none -device virtio-blk,drive=rootfs \
	-fsdev local,id=fsdev0,path=/data/data,security_model=none \
	-device virtio-9p-pci,fsdev=fsdev0,mount_tag=data \
	-device virtio-rng-pci \
	-object acceldev-backend-vaccelrt,id=rt0 \
	-device virtio-accel-pci,id=accel0,runtime=rt0 \
	$extra_args
