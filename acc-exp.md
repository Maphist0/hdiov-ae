# Accelerator Experiment Guide

## A few notes
1. This guide covers the experiment results in Figure 14, 15, and 16.
2. The hardware requirement is listed in the [README](https://github.com/Maphist0/hdiov-ae) file.
3. The following experiments can be done on only one server.

Structure of this guide.
1. [Host setup](https://github.com/Maphist0/hdiov-ae/blob/main/acc-exp.md#1-host-setup): install host drivers and configure QAT devices, launch VM and verify devices in the guest.
2. [Guest setup](https://github.com/Maphist0/hdiov-ae/blob/main/acc-exp.md#2-guest-setup): install guest drivers and run benchmarks.
3. [Best practices and troubleshooting](https://github.com/Maphist0/hdiov-ae/blob/main/acc-exp.md#3-best-practices-and-troubleshooting).

## 1. Host setup
Pre-experiment checklist, please make sure every box below has been checked on your platform.
- [ ] On boot, make sure IOMMU SM mode is enabled. You should see `intel_iommu=on,sm=on` is shown in `$ cat /proc/cmdline`.
- [ ] Download and install [QEMU](https://www.qemu.org). Validated in Ubuntu 20.04 (host) with QEMU 5.0.0.
- [ ] Download the latest [Intel QAT driver for hardware version 2.0](https://www.intel.com/content/www/us/en/download/765501/intel-quickassist-technology-driver-for-linux-hw-version-2-0.html), extract and install driver on host.
```
# ICP_ROOT is the path to your extracted driver folder
# e.g., /opt/QAT20.L.0.8.3-00028
export ICP_ROOT=/xxx/xxx/xxx
cd $ICP_ROOT

./configure --enable-icp-sriov=host
make -j8
make install

service qat_service start
service qat_service status
```

### Step 1.1: PF configuration
Next, configure QAT PF into either SRIOV or HD-IOV mode. Each QAT PF can work in either HD-IOV or SRIOV mode, not both. By default, the configuration file is located at `/etc/4xxx_dev{0,1,2,3}.conf`. Notice that in the same folder, you may see configuration files with `vf` or `shim` words in their names, we won't touch them.

QAT can accelerate three types of algorithms: Data compression (DC, corresponds to Figure 14 in the paper), Asymmetric encryption (ASYM, Figure 15), and Symmetric encryption (SYM, Figure 16). Each PF can generate at maximum 16 virtual devices (VDEV) for all types, i.e., `4 ASYM + 4 SYM + 8 DC` or `16 ASYM` are both OK.

Assume we are configuring PF0, open the configuration file `vim /etc/4xxx_dev0.conf` and edit it according to the below instructions.
```
# Change your supported algorithm here:
[GENERAL]
ServicesEnabled = asym  # options: asym;sym;dc
...
...
# Change the maximum VDEVs here:
[SIOV]
NumberAdis = 16         # 0 means SRIOV mode, non-zero means HD-IOV mode
```

Restart qat service: `$ service qat_service stop && service qat_service start`, navigate to driver folder `$ cd $ICP_ROOT` and use a tool to show VDEVs for each PF `$ ./build/vqat_ctl show`. You should see the output similar to the following.
```
# You should see multiple 'missing', because they are VFs
Missing MDEV entry: 0000:xx:00.0
...
...
# And you should see PF0 has available asym VDEVs
BDF: 0000:6b:00.0

        Available sym    : 0

        Available asym   : 16

        Available dc     : 0

  

        Active VQATs:

        --------------------------------------------------------------

        INDEX   TYPE                                    UUID    STATUS

        --------------------------------------------------------------
# The list is empty because we haven't created VDEV yet
```

### Step 1.2: Create VDEV
Assume PF0 is the PCIe device with BDF `0000:6b:00.0` (it might be different on your platform), we'll use `vqat_ctl` tool to create a VDEV for PF0.
```
cd $ICP_ROOT
./build/vqat_ctl create 0000:6b:00.0 asym

# Output in the terminal:
VQAT-asym created successfully, device name = 2b8d29e3-6ded-4f87-96d8-65b28e64ef7c
```
To verify the created VDEV, use `$ ./build/vqat_ctl show`, it should print info similar to the following.
```
# PF0's list is non-empty now
BDF: 0000:6b:00.0

        Available sym    : 0

        Available asym   : 15

        Available dc     : 0

  

        Active VQATs:

        --------------------------------------------------------------

        INDEX   TYPE                                    UUID    STATUS

        1       asym    2b8d29e3-6ded-4f87-96d8-65b28e64ef7c    active

        --------------------------------------------------------------
```

### Step 1.3: Start VM
Append a new device option to the QEMU command when launching the VM. Please make sure BDF and UUID numbers have been changed to your case.
```
-device vfio-pci,sysfsdev=/sys/devices/pci0000\:6b/0000\:6b\:00.0/2b8d29e3-6ded-4f87-96d8-65b28e64ef7c
```

### Step 1.4: Verify VDEV in VM
When VM boots up, inside guest OS, you should see the following QAT VDEV device with `$ lspci`.
```
00:xx.0 Co-processor: Intel Corporation Device 0da5 (rev02)
```

## 2. Guest setup

### Step 2.1: VDEV configuration
It is recommended to install the same version of QAT driver in guest OS. The argument for `enable-icp-sriov` is different.
```
# This is what we use for host
./configure --enable-icp-sriov=host

# This is what we use now, for guest
./configure --enable-icp-sriov=guest

make -j8
make install
```

In guest OS, remove in-tree qat driver and probe the one that we have compiled.
```
modprobe -r intel_qat # Remove in-tree driver
modprobe mdev
modprobe uio

cd $ICP_ROOT
modprobe build/intel_qat.ko

modprobe build/qat_vqat.ko     # <-- for HD-IOV
# OR
modprobe build/qat_4xxxvf.ko   # <-- for SRIOV

service qat_service restart
service qat_service status
```

Verify VDEV works with `$ ./build/adf_ctl status`. You should see a `vqat-adi` device with state `up`.

### Step 2.2: Build benchmark
The source code for QAT driver benchmarks are located at: `$ICP_ROOT/quickassist/lookaside/access_layer/src/sample_core/performance`.
```
# Compile samples
cd $ICP_ROOT
make samples
```

### Step 2.3: Run benchmark
Navigate to the benchmark directory and run it.
```
cd quickassist/lookaside/access_layer/src/sample_core/performance/build/linux_2.6/user_space
./cpa_sample_code
```
The benchmark tries to run every algorithm that VDEV supports. The settings for each result are printed in the terminal. Please refer to the paper for the exact setting in Figure 14/15/16. 

Host performance numbers can be obtained by running the benchmark in host QAT driver.

## 3. Best practices and troubleshooting

### Optimal performance
It is recommended to enable only one type of algorithms for each benchmark. This can be enforced by appending an arg to driver. We also use these arguments in our experiment.
```
# Enable host driver to support ASYM only
./configure --enable-icp-sriov=host --enable-icp-asym-only

# Enable host driver to support SYM only
./configure --enable-icp-sriov=host --enable-icp-sym-only

# Enable host driver to support DC only
./configure --enable-icp-sriov=host --enable-icp-dc-only
```

### QAT driver issues
Please enable debug mode in QAT driver if you encounter driver errors. Usually these errors contain an `ICP` word in the error message.
```
# Enable debug on host driver
./configure --enable-icp-debug --enable-icp-sriov=host

# Enable debug on guest driver
./configure --enable-icp-debug --enable-icp-sriov=guest

# Must re-install driver everytime you re-configure
make -j8
make install
```

If guest benchmark does not run and you see error messages in `$ dmesg` complaining mis-configuration. 
```
# In guest OS
vim /etc/vqat_dev{0,1,2,3}.conf

# Benchmark code requires that a [SSL] block is presented in the VDEV conf file
# Under "User Process Instance Section", you should see:
[SSL]

# You should change to "[SSL]" if it has another name, for example:
[SHIM]
```

### Additional resources
- [Getting Started Guide - Intel QAT HW 2.0](https://cdrdv2-public.intel.com/632506/632506-qat-getting-started-guide-v2.0.pdf)
