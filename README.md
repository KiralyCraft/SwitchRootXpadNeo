# SwitchRootXpadNeo
An installer for xpadneo on L4T for the Switch (3.2.0). This repository contains a snapshot of necessary files at the time of writing, and the commit d55e6d42ecb53f3ebe91e7a43574c35e79146dfd of xpadneo. It will compile the generic distribution hid module and load it. It will also write the appropriate configuration files for the workaround required for kernels <= 4.16. The L4T build runs on kernel 4.9.140, which needs said workaround in order to function correctly.

The driver may install itself under /lib/modules/4.9.140 instead of /lib/modules/4.9.140+. If it does so, copy it to the correct modules folder, keeping paths the same, and reboot.

Remember to disable ERTM to pair Xbox One controllers!
See this: https://gist.github.com/2E0PGS/0166ffec16b1d86acb4ebeea6871b54e

Inspired by: https://gitlab.com/switchroot/kernel/l4t-kernel-build-scripts/tree/test

# This is too complicated, what can I do?

Note, this has only been tested on Bionic, though it should work on whatever has kernel 4.9.140.
Run this:

```
cd /lib/modules/4.9.140+/kernel/drivers/hid && sudo wget https://cdn.discordapp.com/attachments/697929296903143494/781616346156367892/hid-xpadneo.ko
cd /etc/modprobe.d/ && sudo wget https://raw.githubusercontent.com/atar-axis/xpadneo/master/hid-xpadneo/etc-modprobe.d/xpadneo.conf
cd /etc/udev/rules.d/ && sudo wget https://raw.githubusercontent.com/atar-axis/xpadneo/master/hid-xpadneo/etc-udev-rules.d/98-xpadneo.rules
sudo depmod
sudo modprobe hid-xpadneo
```
