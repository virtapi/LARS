# LARS - Live Arch Rescue System

LARS is an [Arch Linux](https://www.archlinux.org/) based live system intended to be booted via PXE. The main focus is on running [installimage](https://github.com/virtapi/installimage) to provision virtual and physical machines.

---

## Contents
+ [How to use](#how-to-use)
+ [Configuration](#configuration)

---

## How to use
You check out this project on your local computer, modify the config to your needs and create the ISO. It will than be copied to your DHCP server where the ISO will be extracted.
* Copy `extract_archiso.sh` to your DHCP server
* Copy `config_build.sh.example` to `config_build.sh`
* Copy `config_live.sh.example` to `config_live.sh`
* Update the variables to your needs (see[configuration](#configuration))
* run `rebuild_and_copy.sh`

---

## Configuration
Every configuration option for the deployment is listed in `config_build.sh` which is used during the build process from [rebuild_and_copy](https://github.com/virtapi/LARS/blob/master/rebuild_and_copy.sh) (outside of the ISO) and from [customize_airootfs.sh](https://github.com/virtapi/LARS/blob/master/airootfs/root/customize_airootfs.sh) (inside the ISO chroot). It will be  temporarily copied into the build directory and deleted afterwards. The copy won't be included in the ISO (so you could place sensitive information here)!
* DHCP_SERVER - FQDN/IP of your DHCP/Image Server
* DHCP_USER - ssh user to copy the images
* DHCP_PATH - where to place the created ISO
* DHCP_EXTRACT - where is the extract_archiso.sh located on the DHCP server
* ISO_MIRROR - URL to an arch mirror that will be written to the pacman config
* ISO_NFSSERVER - NFS server that serves the installimage itself and images

Everything that we configure inside of the iso is configured in airootfs/root/customize_airootfs.sh, important points are (there should be no need to modify this file!):
* we point to an internal mirror if available
* add NFS mount points for installimage if NFS server is available
* use systemd-networkd with dhcp instead of dhcpcd
