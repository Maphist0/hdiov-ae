## HD-IOV accelerator device
dev="-device vfio-pci,sysfsdev=/sys/devices/pci0000:6b/0000:6b:00.0/acb13c5a-6c82-4d5e-aaa5-34a2f9d01024
     -device vfio-pci,sysfsdev=/sys/devices/pci0000:70/0000:70:00.0/ad40d17e-3bb8-4441-b7ca-7976c58afe7a
     -device vfio-pci,sysfsdev=/sys/devices/pci0000:75/0000:75:00.0/3623ce9a-a6d7-4d0e-a7da-cbc87efa903a"

## HD-IOV network device
netdev="-device vfio-pci,sysfsdev=/sys/bus/mdev/devices/83b8f4f2-509f-382f-3c1e-e6bfe0fa1001"

## VM image
image=./testvm01.img

./qemu-system-x86_64 \
        --enable-kvm \
        -monitor telnet::2223,server,nowait \
        -drive file=$image \
        -m 8G \
        -smp 8 \
        -cpu host \
        -nic user,model=virtio,hostfwd=tcp::2222-:22 \
        -nographic \
        $dev \
        $netdev \
