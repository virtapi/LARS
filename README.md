# LARS - Live Arch Rescue System

LARS is an [Arch Linux](https://www.archlinux.org/) based live system intended to be booted via PXE. The main focus is on running [installimage](https://github.com/virtapi/installimage) to provision virtual and physical machines.

---

## Contents
+ [How to use](#how-to-use)
+ [Configuration](#configuration)

---

## How to use
You check out this project on your local computer, modify the config to your needs and create the ISO. It will than be copied to your DHCP server where the ISO will be extracted.
* Copy extract_archiso to your DHCP server
* Copy config.sh.example to config.sh
* Copy airootfs/root/customize_airootfs.sh.example to airootfs/root/customize_airootfs.sh
* Update the variables to your needs (see [configuration](#configuration))
* run rebuild_and_copy.sh

---

## Configuration
Every configuration option for the deployment is listed in `config.sh`:
* DHCP_SERVER - FQDN/IP of your DHCP/Image Server
* DHCP_USER - ssh user to copy the images
* DHCP_PATH - where to place the created ISO
* DHCP_EXTRACT - where is the extract_archiso.sh located on the DHCP server

Everything that we configure inside of the iso is configured in airootfs/root/customize_airootfs.sh, important points are:
* we point to an internal mirror
* add NFS mount points for installimage
* use systemd-networkd for dhcp instead of dhcpcd
