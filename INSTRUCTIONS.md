# Run a vAccel-enabled QEMU guest

TL;DR To start a container with a vAccel-enabled VM you just need to grab our pre-built kernel & rootfs.img, available here [link] and put them in a $(DATA_DIR) of your choice.

You can then run a VM with:

```
docker run --rm --network=host --device=/dev/net/tun --cap-add NET_ADMIN --gpus all -v $(DATA_DIR):/data -it --device=/dev/kvm nubificus/vaccel-qemu
```

The above command: -adds the tun device to the container and enables setting up a virtual network for the QEMU VM, -passes the host kvm device (/dev/kvm) to the container, -provides access to the GPU for the container instance and -mounts the directory containing the necessary data files for the VM to boot.

The entrypoint for the used container image (nubificus/vaccel-qemu) downloads the default ML network models needed for inference in $(DATA_DIR)/networks (using this script [link]) and starts a QEMU VM with our pre-built kernel & rootfs.img. This repository [link] contains the dockerfile from which these binaries have been produced. You can download ready-made binaries from the releases page. The first time the container is run, the script also downloads the default ML networks models needed for inference (using this script [link]).

To share data between the host and the guest at runtime, you can use the `guest/qemu-guest-{arch}/data` directory (created by the `build_guest.sh` script). The directory is mounted at `/root/data` (via 9p) inside the QEMU guest.

After sucessfully starting the container you should get to a login promt. Try root for username (no password).

To run an image classification example use:
```
classify <image_path> <iterations>
```

If (for any reason) you want to try out jetson-inference without booting the QEMU VM, you can just run the container with /bin/bash as an entrypoint, using the following command:

```
docker run --rm --network=host --device=/dev/net/tun --cap-add NET_ADMIN --gpus all -v $(pwd)/guest/qemu-guest-x86_64:/
data -it --entrypoint /bin/bash --device=/dev/kvm nubificus/vaccel-qemu
```

You can then view/change the default options for running QEMU in `/run.sh` before running the VM.
