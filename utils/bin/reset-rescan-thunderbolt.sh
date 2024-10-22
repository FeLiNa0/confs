#!/bin/sh
set -ex

echo ">>>> Listing PCI devices"
lspci | grep thunderbolt -i

PCI_ID=0000:07:00.00
echo ">>>> Removing a thunderbolt device and rescanning for new PCI devices"
echo "1" | tee "/sys/bus/pci/devices/$PCI_ID/remove"
echo "1" | tee /sys/bus/pci/rescan