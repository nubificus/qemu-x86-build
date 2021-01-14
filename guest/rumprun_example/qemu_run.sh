#/bin/bash

cd /data

mkdir -p networks
if [[ ! -f networks/.downloaded ]]; then
	/usr/local/share/jetson-inference/tools/download-models.sh
	[[ $? -eq 0 ]] && touch networks/.downloaded
fi

LD_LIBRARY_PATH=/usr/local/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64 qemu-system-x86_64 -cpu host -m 4096 -enable-kvm -nographic -vga none -drive if=virtio,file=/data/data.iso,format=raw -device virtio-rng-pci -object acceldev-backend-crypto,id=crypto0 -object acceldev-backend-generic,id=gen0 -device virtio-accel-pci,id=accel0,crypto=crypto0,generic=gen0,disable-legacy=off,disable-modern=on -kernel /data/classify.bin -append "{,,\"blk\":{\"source\":\"dev\",,\"path\":\"/dev/ld0a\",,\"fstype\":\"blk\",,\"mountpoint\":\"/data/\"},,\"cmdline\": \"classify /data/dog_0.jpg\",,},,"
