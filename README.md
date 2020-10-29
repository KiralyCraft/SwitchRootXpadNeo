# SwitchRootXpadNeo
An installer for xpadneo on L4T for the Switch (3.2.0). This repository contains a snapshot of necessary files at the time of writing, and the commit d55e6d42ecb53f3ebe91e7a43574c35e79146dfd of xpadneo. It will compile the generic distribution hid module and load it. It will also write the appropriate configuration files for the workaround required for kernels <= 4.16. The L4T build runs on kernel 4.9.140, which needs said workaround in order to function correctly.

The driver may install itself under /lib/modules/4.9.140 instead of /lib/modules/4.9.140+. If it does so, copy it to the correct modules folder, keeping paths the same, and reboot.

Remember to disable ERTM to pair Xbox One controllers!
See this: https://gist.github.com/2E0PGS/0166ffec16b1d86acb4ebeea6871b54e
