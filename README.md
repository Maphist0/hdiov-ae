# HD-IOV: SW-HW Co-designed I/O Virtualization with Scalability and Flexibility for Hyper-Density Cloud

This page holds the artifact for paper "HD-IOV" to be published in EuroSys'24.

HD-IOV is a software-hardware co-designed I/O virtualization solution. HD-IOV decouples virtualization and resource management logic from hardware devices to software, reducing device complexity and enabling more flexible hardware resource management. DMA transactions and interrupts are sent directly to guest VMs without VM exits. Isolation is achieved by leveraging an existing PCIe feature, PASID, allowing IOMMU to enforce queue pair level isolation. 

Our experiments show that HD-IOV achieves similar performance as SR-IOV for both network and accelerator devices. Furthermore, HD-IOV supports maximally 2.96x higher device count with 2.9x faster median device initialization time.

More details can be found in our EuroSys-2024 paper with the same title.

## A few notes
The code of HD-IOV has been contributed to the Intel Scalable I/O Virtualization (SIOV) project. [Link to: Intel SIOV specification](https://cdrdv2-public.intel.com/671403/intel-scalable-io-virtualization-technical-specification.pdf)

### Hardware requirements
To deploy HD-IOV, you'll need two physical servers: one is the virtualization server (device-under-test), the other is a client.
1. CPU: The virtualization server must use Intel 4th generation Xeon Scalable Processors (code name: [Sapphire Rapids, SPR](https://ark.intel.com/content/www/us/en/ark/products/codename/126212/products-formerly-sapphire-rapids.html)). No CPU requirement for the client.
1. Network: To deploy HD-IOV for network virtualization experiments, you'll need at least one Intel Ethernet Network Adapter E810 network card. This network card is not needed for accelerator virtualization experiments.
2. Accelerator: To deploy HD-IOV for accelerator virtualization experiments, SPR CPUs have provided built-in Intel Quick-Assist Technology (QAT) hardware version 2.0\*.
3. Platform: Please make sure the IOMMU "scalable mode" (SM) has been enabled\*\*. Configure Linux kernel boot args with `intel_iommu=on,sm=on`.

> \* A few SPR CPU models do not have QAT support. Please check Intel ARK to make sure your current CPU has QAT devices. Legacy QAT PCIe cards (hardware versions 1.7) DO NOT support HD-IOV, e.g., Intel QuickAssist Adapter 8960/8970.
> 
> \*\* Most SPR platforms should support SM, however, SM is probably disabled by default.

### Software requirements

1. Operating system
    1. Validated in Ubuntu 20.04 (host) with kernel 5.11.0 and Centos 8 (guest) with kernel 5.15.4.
1. QEMU
    1. Download newest qemu from [qemu.org](https://www.qemu.org/)
    2. Install qemu on host according to the guideline
    3. Validated in QEMU 5.0 and 6.1
1. Docker
    1. Validated in Docker 20.10
1. *(Only in accelerator virtualization experiments)* Intel QAT Driver
    1. Download newest driver and guideline from the [QAT website](https://www.intel.com/content/www/us/en/download/765501/intel-quickassist-technology-driver-for-linux-hw-version-2-0.html)
    2. Install driver on host and guest according to the guideline

## 1. Network Virtualization Experiments
*Experiment (E1):* Network virtualization experiments with virtual machines.

We create a virtual device (VDEV) of HD-IOV, start a virtual machine with the VDEV, and launch benchmarks inside the VM, which communicates with the client.

*Experiment (E2):* Network virtualization scalability experiments. 

This experiment shares the same steps as experiment E1. Instead of launching one VM, this experiment creates all VDEVs that the physical device supports and launches all VMs simultaneously. The iperf tool is used, the packet size is fixed to 1470bytes in this experiment.

*Experiment (E3):* Network virtualization experiments with containers.

We create all VDEVs that the physical device supports and launches each container one-by-one. Each container uses one VDEV. We launch DPDK testpmd sample application in the container. The initialization time will print in the terminal.

These three experiments cover Figures 8-13 in the paper. Instructions for these three experiments can be found in [nic-exp.md](https://github.com/Maphist0/hdiov-ae/blob/main/nic-exp.md).

## 2. Accelerator Virtualization Experiments

*Experiment (E4):* Accelerator virtualization experiments.

We create VDEVs for Intel QAT devices, start a virtual machine with the VDEV, and launch benchmarks inside the VM.
 
This experiment covers Figure 14-16 in the paper. The detailed setup guide can be found in [acc-exp.md](https://github.com/Maphist0/hdiov-ae/blob/main/acc-exp.md).

## 3. Reference
```
@inproceedings{hdiov-eurosys24,
  author       = {Zongpu Zhang and
                  Jiangtao Chen and
                  Banghao Ying and
                  Yahui Cao and
                  Lingyu Liu and
                  Jian Li and
                  Xin Zeng and
                  Junyuan Wang and
                  Weigang Li and
                  Haibing Guan},
  title        = {HD-IOV: SW-HW Co-designed I/O Virtualization with Scalability and Flexibility for Hyper-Density Cloud},
  booktitle    = {EuroSys},
  pages        = {},
  publisher    = {{ACM}},
  year         = {2024}
}
```
