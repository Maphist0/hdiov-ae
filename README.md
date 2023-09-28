# HD-IOV: SW-HW Co-designed I/O Virtualization with Scalability and Flexibility for Hyper-Density Cloud

This page holds the artifact evaluation for paper "HD-IOV" to be published in EuroSys'24.

HD-IOV is a software-hardware co-designed I/O virtualization solution. HD-IOV decouples virtualization and resource management logic from hardware devices to software, reducing device complexity and enabling more flexible hardware resource management. DMA transactions and interrupts are sent directly to guest VMs without VM exits. Isolation is achieved by leveraging an existing PCIe feature, PASID, allowing IOMMU to enforce queue pair level isolation. 

Our experiments show that HD-IOV achieves similar performance as SR-IOV for both network and accelerator devices. Furthermore, HD-IOV supports maximally 2.96x higher device count with 2.9x faster median device initialization time.

## A few notes

1. HD-IOV is a rename of Intel Scalable I/O Virtualization (SIOV)* due to annoymous paper submission rules. We'll use HD-IOV in the following texts.
2. To deploy HD-IOV, you'll need at least one physical server with Intel 4th generation Xeon Scalable Processors (code name: [Sapphire Rapids, SPR](https://ark.intel.com/content/www/us/en/ark/products/codename/126212/products-formerly-sapphire-rapids.html)).
    1. To deploy HD-IOV for network virtualization experiments, you'll need at least one Intel Ethernet Network Adapter E810 network card.
    2. To deploy HD-IOV for accelerator virtualization experiments, SPR CPUs should have provided the hardware you need**: Intel Quick-Assist Technology (QAT) hardware version 2.0. Legacy QAT PCIe cards (hardware versions 1.7) DO NOT support HD-IOV, e.g., Intel QuickAssist Adapter 8960/8970 are unsupported.
3. Since HD-IOV depends on PASID, please make sure your IOMMU has the "scalable mode" (SM) and this mode has been enabled. Most SPR platforms should support SM, however, SM is probably disabled by default.

\* [Link to: Intel SIOV specification](https://cdrdv2-public.intel.com/671403/intel-scalable-io-virtualization-technical-specification.pdf)

\*\* A few SPR CPU models do not have QAT support. Please check Intel ARK to make sure your current CPU has QAT devices.
