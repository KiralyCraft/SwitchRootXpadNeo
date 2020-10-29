#!/bin/bash

#PREPARING THE KERNEL SOURCES

KERNEL_DIR=$(pwd)"/kernel_r32/kernel-4.9"
CURPWD=$(pwd)

#Handle Standard Kernel Bits
echo "Extracting and Patching L4T-Switch 4.9"
mkdir -p kernel_r32
mv ./l4t-kernel-4.9 $KERNEL_DIR
cd $KERNEL_DIR
#put patch files for kernel repo after this line
cd $CURPWD
echo "Done"

#Handle Nvidia Kernel bits
echo "Extracting Nvidia Kernel Stuff"
mkdir -p ./kernel_r32/nvidia
mv ./l4t-kernel-nvidia*/* ./kernel_r32/nvidia
rm -r ./l4t-kernel-nvidia*
echo "Done"

#Handle Switchroot DTS files
echo "Extracting DTS stuff"
mkdir -p ./kernel_r32/hardware/nvidia/platform/t210/icosa
cd l4t-platform-t210-switch
cd $CURPWD
mv ./l4t-platform-t210-switch*/* ./kernel_r32/hardware/nvidia/platform/t210/icosa/
rm -r ./l4t-platform-t210-switch*
echo "Done"

#Extract and place nvidia bits
echo "Extracting Nvidia GPU Kernel Bits"
mkdir -p ./kernel_r32/nvgpu
mkdir linux-nvgpu
tar -xf "./linux-nvgpu-r32.2.2.tar.gz" -C linux-nvgpu --strip 1
rm "./linux-nvgpu-r32.2.2.tar.gz"
mv ./linux-nvgpu/* ./kernel_r32/nvgpu
rm -r linux-nvgpu
echo "Done"

echo "Extracting Tegra SOC Data"
mkdir -p ./kernel_r32/hardware/nvidia/soc/tegra/
mkdir soc-tegra
tar -xf "./soc-tegra-rel32.2.2.tar.gz" -C soc-tegra --strip 1
rm "./soc-tegra-rel32.2.2.tar.gz"
mv ./soc-tegra/* ./kernel_r32/hardware/nvidia/soc/tegra/
rm -r soc-tegra
echo "Done"

echo "Extracting T210 SOC Data"
mkdir -p ./kernel_r32/hardware/nvidia/soc/t210/
mkdir soc-tegra-t210
tar -xf "soc-tegra-t210-rel32.2.2.tar.gz" -C soc-tegra-t210 --strip 1
rm "soc-tegra-t210-rel32.2.2.tar.gz"
mv ./soc-tegra-t210/* ./kernel_r32/hardware/nvidia/soc/t210/
rm -r soc-tegra-t210
echo "Done"

echo "Extracting Tegra Common Platform Data"
mkdir -p ./kernel_r32/hardware/nvidia/platform/tegra/common/
mkdir platform-tegra-common
tar -xf "platform-tegra-common-rel32.2.2.tar.gz" -C platform-tegra-common --strip 1
rm "platform-tegra-common-rel32.2.2.tar.gz"
mv ./platform-tegra-common/* ./kernel_r32/hardware/nvidia/platform/tegra/common/
rm -r platform-tegra-common
echo "Done"

echo "Extracting T210 Common Platform Data"
mkdir -p ./kernel_r32/hardware/nvidia/platform/t210/common/
mkdir common-t210
tar -xf "platform-tegra-t210-common-rel32.2.2.tar.gz" -C common-t210 --strip 1
rm "platform-tegra-t210-common-rel32.2.2.tar.gz"
mv ./common-t210/* ./kernel_r32/hardware/nvidia/platform/t210/common/
rm -r common-t210
echo "Done"

echo "Preparing Source and Creating Defconfig"
cd $KERNEL_DIR
cp arch/arm64/configs/tegra_linux_defconfig .config


#PREPARE THE KERNEL
make olddefconfig
make prepare
ARCH=arm64 make -j5 tegra-dtstree="../hardware/nvidia"


cd ..
git clone https://github.com/atar-axis/xpadneo.git
cd xpadneo
git checkout d55e6d42ecb53f3ebe91e7a43574c35e79146dfd
cd hid-xpadneo

#Patch xpadneo generic installer
echo "$(tail -n +2 Makefile)" > Makefile
( echo "KERNEL_SOURCE_DIR := $KERNEL_DIR" && cat Makefile ) > Makefile2 && mv Makefile2 Makefile
make -j4

depmod
sudo rmmod hid-xpadneo || true

sudo cp ./etc-udev-rules.d/98-xpadneo.rules /etc/udev/rules.d/
sudo cp ./etc-modprobe.d/xpadneo.conf /etc/modprobe.d/
modprobe hid-xpadneo