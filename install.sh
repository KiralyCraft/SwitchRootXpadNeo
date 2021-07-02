#!/bin/bash
set -e

# Build variables
export KBUILD_BUILD_USER=${KBUILD_BUILD_USER:-"user"}
export KBUILD_BUILD_HOST=${KBUILD_BUILD_HOST:-"custombuild"}
export ARCH=${ARCH:-"arm64"}
if [[ `uname -m` != aarch64 ]]; then
	export CROSS_COMPILE=${CROSS_COMPILE:-"aarch64-linux-gnu-"}
fi
export CPUS=${CPUS:-$(($(getconf _NPROCESSORS_ONLN) - 1))}
export KERNEL_VER=${KERNEL_VER:-"linux-3.3.1"}

# Retrieve last argument as output directory
CWD="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
KERNEL_DIR="${CWD}/kernel"

create_update_modules() {
	find "$1" -type d -exec chmod 755 {} \;
	find "$1" -type f -exec chmod 644 {} \;
	find "$1" -name "*.sh" -type f -exec chmod 755 {} \;
	fakeroot chown -R root:root "$1"
	tar -C "$1" -czvpf "$2" .
}

Prepare() {
	if [[ -z `ls -A ${KERNEL_DIR}/kernel-4.9` ]]; then
		git clone -b "${KERNEL_VER}" https://gitlab.com/l4t-community/l4t-kernel-4.9 "${KERNEL_DIR}/kernel-4.9" --depth 1
	fi
}

Build() {
	echo "Preparing Source and Creating Defconfig"

	cd "${KERNEL_DIR}/kernel-4.9"
	
	# Copy kernel defconfig
	cp arch/arm64/configs/tegra_linux_defconfig .config

	# Prepare Linux sources
	make olddefconfig
	make prepare
	make modules_prepare
	
	
	cd $CWD
	git clone https://github.com/atar-axis/xpadneo.git
	cd xpadneo
	git checkout d55e6d42ecb53f3ebe91e7a43574c35e79146dfd
	cd hid-xpadneo

	#Patch xpadneo generic installer
	echo "$(tail -n +2 Makefile)" > Makefile
	( echo "KERNEL_SOURCE_DIR := ${KERNEL_DIR}/kernel-4.9" && cat Makefile ) > Makefile2 && mv Makefile2 Makefile
	sudo make modules && sudo make modules_install


	depmod
	sudo rmmod hid-xpadneo || true

	sudo cp ./etc-udev-rules.d/98-xpadneo.rules /etc/udev/rules.d/
	sudo cp ./etc-modprobe.d/xpadneo.conf /etc/modprobe.d/
	modprobe hid-xpadneo
	
	if lsmod | grep -i hid_xpadneo -q; then
        echo "All good, seems to be working!"
	else
        echo "Something didn't go right!"
    fi
}


Prepare
Build
