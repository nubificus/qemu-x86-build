#!/bin/bash

dd if=/dev/zero of=rootfs.img bs=1M count=0 seek=512
mkfs.ext4 rootfs.img
mkdir -p mnt
sudo mount rootfs.img mnt
sudo rsync -aogxvPH $@ mnt
sudo umount mnt
rmdir mnt
