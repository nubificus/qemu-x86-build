#!/bin/bash

export LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}
export QEMU_AUDIO_DRV=none
export OCL_DEV_TYPE=1

smp=1
cpu=host
ram=2048

machine="pc,accel=kvm"
kernel="-kernel bzImage"
dtb=""
rootfs=rootfs.img
cmdline="rw root=/dev/vda mem=${ram}M console=ttyS0"
stderr=run/stderr.log
extra_args=

mkdir -p run
while getopts 'c:m:r:a:s:n' opt; do
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
			extra_args+="-monitor chardev:monitor"
			;;
		n)
			# VM w/ network
			extra_args+="-netdev type=tap,id=net0 -device virtio-net,netdev=net0 "
			;;
		:)
			error "Option -$OPTARG requires an argument" 1
			;;
		\?)
			exit 1
			;;
	esac
done

mkdir -p networks
if [[ ! -f networks/.downloaded ]]; then
	/usr/local/share/jetson-inference/tools/download-models.sh
	[[ $? -eq 0 ]] && touch networks/.downloaded
fi

fsck.ext4 -fy $rootfs 1>/dev/null 2>&1

TERM=linux qemu-system-x86_64 \
	-cpu $cpu -m $ram -smp $smp -M $machine -nographic $kernel $dtb -append "$cmdline" 2>$stderr \
	-drive if=none,id=rootfs,file=$rootfs,format=raw,cache=none -device virtio-blk,drive=rootfs \
	-fsdev local,id=fsdev0,path=/data/data,security_model=none \
	-device virtio-9p-pci,fsdev=fsdev0,mount_tag=data \
	-object acceldev-backend-generic,id=gen0 \
	-device virtio-accel-pci,id=accel0,generic=gen0 \
	$extra_args
