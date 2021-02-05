###Image classification example

A small example to test vaccel virtio driver on unikraft.

The config file contains a config which enables everything that vaccel virtio 
driver needs from Unikraft including network support. 

Afer building unikraft you can run it using the below command.

```
LD_LIBRARY_PATH=/vaccel/local/lib:/usr/local/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64 qemu-system-x86_64 -cpu host -m 512 -enable-kvm -nographic -vga none -fsdev local,id=myid,path=./data/data,security_model=none -device virtio-9p-pci,fsdev=myid,mount_tag=data,disable-modern=on,disable-legacy=off -object acceldev-backend-vaccelrt,id=gen0 -device virtio-accel-pci,id=accl0,runtime=gen0,disable-legacy=off,disable-modern=on -kernel /vaccel/unikraft/apps/rt_classify/build/classify_kvm-x86_64 -append "vfs.rootdev=data -- dog_0.jpg 1"
```

