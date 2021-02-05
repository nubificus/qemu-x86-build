# Build & run a vAccel-enabled QEMU unikernels

This repo contains the Dockerfiles & scripts to produce a vAccel-enabled QEMU unikernels.

### Building guest unikernel

To generate the necessary binaries and directories to run a QEMU unikernel, use:

```
bash build_guest.sh -u ## for Unikraft
bash build_guest.sh -r ## for Rumprun
```

### Building container

To build the container with vAccel runtime library & QEMU binaries, use:
```
bash build.sh -u ## for Unikraft
bash build.sh -r ## for Rumprun
```

\*you will have to export the TOKEN variable to be able to pull private repos (only for the Rumprun).

### Example usage

To execute the vAccel QEMU Unikraft, use:

```
bash run.sh $IMAGE $ITERATIONS
```

To execute the vAccel QEMU Rumprun, use:
```
bash run.sh 
```

You can use the `guest/qemu-guest-{arch}/data` directory (created by the `build_guest.sh` script) to share data between the host and the guest at runtime. The directory is mounted with 9p in Unikraft and with virtio-blk in Rumprun.

Please note you have to setup nvidia-docker beforehand, in order to use the GPU from the container. Further instructions are provided here: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker
