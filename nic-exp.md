# Network Experiment Guide

## A few notes
1. This guide covers the experiment results in Figure 8-13.
2. The hardware requirement is listed in the [README](https://github.com/Maphist0/hdiov-ae) file.

Structure of this guide.
1. [Host setup](https://github.com/Maphist0/hdiov-ae/blob/main/nic-exp.md#1-host-setup): configure VDEV devices and launch VM.
2. [Guest setup](https://github.com/Maphist0/hdiov-ae/blob/main/nic-exp.md#2-guest-setup): run benchmarks in guest VM.
3. [Container setup](https://github.com/Maphist0/hdiov-ae/blob/main/nic-exp.md#3-container-setup): run container benchmarks (Figure 12).

## 1. Host setup
Pre-experiment checklist, please make sure every box below has been checked on your platform.
- [ ] On boot, make sure IOMMU SM mode is enabled. You should see `intel_iommu=on,sm=on` is shown in `$ cat /proc/cmdline`.
- [ ] Download and install [QEMU](https://www.qemu.org). Validated in Ubuntu 20.04 (host) with QEMU 5.0.0.

### Step 1.1: Create VDEV
Next, load Intel E810 driver and create VDEV. Assume the PF has a BDF of `0000:16:00.0`. 
```
insmod ice.ko
echo "2b8d29e3-6ded-4f87-96d8-65b28e64ef7c" > /sys/class/mdev_bus/0000:16:00.0/mdev_supported_types/ice-vdcm/create
```

### Step 1.2: Start VM
Append a new device option to the QEMU command when launching the VM. Please make sure BDF and UUID numbers have been changed to your case.
```
-device vfio-pci,sysfsdev=/sys/devices/pci0000\:16/0000\:16\:00.0/2b8d29e3-6ded-4f87-96d8-65b28e64ef7c
```

You may need to manually assign an IP for VM. Please verify that the network between VM and the client works, e.g., by using `ping`.

In the following discussion, `CLIENT_IP` refers to the IP address of the client.

## 2. Guest setup

### Step 2.1: Start benchmark
Below is a list of benchmark tools for each experiment.
1. Figure 8
    1. `iperf` is used in this experiment.
    2. On client, run `$ iperf -s`.
    3. In VM, run `$ iperf -c {CLIENT_IP} -i 1 -u -b 1G -l {PKT_SIZE} -P 4`, where `PKT_SIZE` is 64, 128, 256, 512, 1024, 1470.
3. Figure 9
    1. `ping` is used in this experiment.
    2. In VM, run `$ ping -s {PKT_SIZE} {CLIENT_IP}`, where `PKT_SIZE` is 56, 120, 248, 504, 1016, and 1462. This value plus 8 bytes of ICMP header is the actual packet size.
5. Figure 10
    1. This experiment is similar to figure 8, however, the number of QPs is set to different values.
    2. On client, run `$ iperf -s`.
    3. In VM, run `$ iperf -c {CLIENT_IP} -i 1 -u -b 1G -l 512 -P 4`.
7. Figure 11
    1. This experiment is similar to figure 8, however, multiple VMs run `iperf` at the same time.
    2. We launch 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, and 758 VMs using VDEV.
    3. On client, run `$ iperf -s`.
    4. On host, repeatedly run `$ ssh {VM_IP} "iperf -c {CLIENT_IP} -i 1 -u -b 1G -l 1470 -P 4"`, where `VM_IP` is the IP address of each launched VM.
8. Figure 13
    1. VM runs `nginx`, client runs `ApacheBench` to generate workload.
    2. In VM, install nginx. Then generate a small payload (1KB) and a larget payload (100KB) using `$ dd bs=1000 count=10 </dev/urandom >/usr/html/{SIZE}.bin`, where `SIZE` is `1kb` and `100kb`.
    3. In VM, copy the nginx [configuration file](https://github.com/Maphist0/hdiov-ae/blob/main/figure_13_nginx.conf) `$ cp figure_13_nginx.conf /etc/nginx/nginx.conf`. Then start nginx by `$ start-stop-daemon -S -x "/usr/sbin/nginx" -p "/var/run/nginx.pid"`.
    4. In client, run the [experiment script](https://github.com/Maphist0/hdiov-ae/blob/main/figure_13_client_ab.sh) to obtain all performance results: `$ ./figure_13_client_ab.sh ${VM_IP}`, replace `VM_IP` with the VM's ip address.

## 3. Container setup

### Step 3.1: Build docker image
Download DPDK 20.11 source code `$ wget https://fast.dpdk.org/rel/dpdk-20.11.9.tar.xz` and extract. Assume the extracted DPDK folder is called `./dpdk-stable-20.11.9`.

Apply our logging patch, which prints the timestamp for the driver initialization time.
```
cd ./dpdk-stable-20.11.9
cp ../figure_12_dpdk_printf.patch .

# Dry-run, check if any error
patch -p1 --dry-run < figure_12_dpdk_printf.patch

# Actually patch it
patch -p1 < figure_12_dpdk_printf.patch
```

Use the provided Dockerfile to build a container image.
```
docker build .
```

### Step 3.2: Create VDEV (similar to [step 1.1](https://github.com/Maphist0/hdiov-ae/blob/main/nic-exp.md#step-11-create-vdev))
Next, on the host, load Intel E810 driver and create VDEV. Assume the PF has a BDF of `0000:16:00.0`. 
```
insmod ice.ko
echo "2b8d29e3-6ded-4f87-96d8-65b28e64ef7c" > /sys/class/mdev_bus/0000:16:00.0/mdev_supported_types/ice-vdcm/create
```
Enable hugepages.
```
echo 1024 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB
echo 1024 > /sys/devices/system/node/node1/hugepages/hugepages-2048kB
mount -t hugetlbfs -o pagesize=2M none /dev/hugepages
```
### Step 3.3: Launch container
Please replace the argument `{IMAGE}` with the name in step 3.1.
```
docker run -it --name=test --device=/dev/vfio/172 --device=/dev/vfio/vfio --ulimit memlock=-1:-1  -v /dev/hugepages:/dev/hugepages -v /sys:/sys -v /dev:/dev {IMAGE} /bin/bash
```

### Step 3.4: Run benchmark
In the terminal of the container, run DPDK testpmd, the initialization time will print to the terminal.
```
sudo ./build/app/dpdk-testpmd -l 1-3 -n 4  -- -i --total-num-mbufs=1025
```
Our test procedure for Figure 12 is as follows:
1. Start the i-th container, gather its results in the terminal. Then stop the i-th container. `i += 1`.
2. Repeat the above step until all 256 containers have been started once.

### Additional resources
- [Intel® Scalable I/O Virtualization – Decrease Startup Time of Cloud-native Network Function on Pass-through Devices](https://networkbuilders.intel.com/solutionslibrary/intel-scalable-i-o-virtualization-decrease-startup-time-of-cloud-native-network-function-on-pass-through-devices-technology-guide)
