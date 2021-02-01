#/bin/bash

cd /data

if [[ ! -d networks ]]; then
	mkdir -p networks
	/usr/local/share/jetson-inference/tools/download-models.sh
	[[ $? -eq 0 ]] && touch networks/.downloaded
fi

cp /usr/local/share/jetson-inference/data/networks/* /data/networks
export VACCEL_BACKENDS=/.local/lib/libvaccel-jetson.so
export VACCEL_IMAGENET_NETWORKS=/data/networks
LD_LIBRARY_PATH=/.local/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64 qemu-system-x86_64 -cpu host -m 512 -enable-kvm -nographic -vga none -fsdev local,id=myid,path=/data/data,security_model=none -device virtio-9p-pci,fsdev=myid,mount_tag=data,disable-modern=on,disable-legacy=off -object acceldev-backend-vaccelrt,id=gen0 -device virtio-accel-pci,id=accl0,runtime=gen0,disable-legacy=off,disable-modern=on -kernel /data/classify_kvm-x86_64 -append "vfs.rootdev=data -- dog_0.jpg 1"
##LD_LIBRARY_PATH=/usr/local/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64 qemu-system-x86_64 -cpu host -m 4096 -enable-kvm -nographic -vga none -fsdev local,id=myid,path=/data/data,security_model=none -device virtio-9p-pci,fsdev=myid,mount_tag=data,disable-modern=on,disable-legacy=off -object acceldev-backend-crypto,id=crypto0 -object acceldev-backend-generic,id=gen0 -device virtio-accel-pci,id=accel0,crypto=crypto0,generic=gen0,disable-legacy=off,disable-modern=on -kernel /data/classify_kvm-x86_64 -append "vfs.rootdev=data -- dog_0.jpg"