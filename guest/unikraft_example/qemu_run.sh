#/bin/bash

cd /data

##export VACCEL_IMAGENET_NETWORKS=/data/networks
export VACCEL_BACKENDS=/.local/lib/libvaccel-jetson.so

IMAGE=$1
ITER=$2


LD_LIBRARY_PATH=/.local/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64 qemu-system-x86_64 \
	-cpu host -m 512 -enable-kvm -nographic -vga none \
	 -net nic,model=virtio -net tap,script=no,ifname=tap105 \
	-object acceldev-backend-vaccelrt,id=gen0 -device virtio-accel-pci,id=accl0,runtime=gen0,disable-legacy=off,disable-modern=on \
	-kernel /data/classify_kvm-x86_64 -append "netdev.ipv4_addr=10.10.10.2 netdev.ipv4_gw_addr=10.10.10.1 netdev.ipv4_subnet_mask=255.255.255.0 -- dog_0.jpg 1"

##LD_LIBRARY_PATH=/.local/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64 qemu-system-x86_64 \
##	-cpu host -m 512 -enable-kvm -nographic -vga none \
##	-fsdev local,id=myid,path=/data/data,security_model=none \
##	-device virtio-9p-pci,fsdev=myid,mount_tag=data,disable-modern=on,disable-legacy=off \
##	-object acceldev-backend-vaccelrt,id=gen0 -device virtio-accel-pci,id=accl0,runtime=gen0,disable-legacy=off,disable-modern=on \
##	-kernel /data/classify_kvm-x86_64 -append "vfs.rootdev=data -- $IMAGE $ITER"
