# LARS - Live Arch Rescue System

LARS is an [Arch Linux](https://www.archlinux.org/) based live system intended to be booted via PXE. The main focus is on running [installimage](https://github.com/virtapi/installimage) to provision virtual and physical machines.

---

## Contents
+ [Project Overview](#project-overview)
+ [How to use](#how-to-use)
+ [Configuration](#configuration)
+ [Using the installimage](#using-the-installimage)

---

## Project Overview
We've got a small diagram showing the different projects in the VirtAPI [namespace](https://github.com/virtapi/repositories):
![virtapi-overview](https://rawgit.com/virtapi/LARS/master/virtapi-overview.svg)

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
Every configuration option for the deployment is listed in our two config files.
`config_build.sh` is used during the build process from [rebuild_and_copy](https://github.com/virtapi/LARS/blob/master/rebuild_and_copy.sh) (outside of the ISO) and from [customize_airootfs.sh](https://github.com/virtapi/LARS/blob/master/airootfs/root/customize_airootfs.sh) (inside the ISO chroot). It will be  temporarily copied into the build directory and deleted afterwards. The copy won't be included in the ISO (so you could place sensitive information here)!
* DHCP_SERVER - FQDN/IP of your DHCP/Image Server
* DHCP_USER - ssh user to copy the images
* DHCP_PATH - where to place the created ISO
* DHCP_EXTRACT - where is the extract_archiso.sh located on the DHCP server
* ISO_MIRROR - URL to an arch mirror that will be written to the pacman config
* ISO_NFSSERVER - NFS server that serves the installimage itself and images

`config_live.sh` is used from [start_installimage](https://github.com/virtapi/LARS/blob/master/scripts/start_installimage) during the usage of the ISO itself. This config file helps the script to find the correct place for installimage configs. This config file is visible to every customer that uses the rescue system so take care about the data you put into it.
* CONFIG_PROTO - protocol for connection to the installimage server
* CONFIG_SERVER - IP/FQDN for connection to the installimage server
* CONFIG_PATH - URL subdir
* CONFIG_FILE - the file itself

Everything that we configure inside of the iso is configured in airootfs/root/customize_airootfs.sh, important points are (there should be no need to modify this file!):
* we point to an internal mirror if available
* add NFS mount points for installimage if NFS server is available
* use systemd-networkd with dhcp instead of dhcpcd

---

## Using the installimage
You can start the installimage with the [start_installimage](https://github.com/virtapi/LARS/blob/master/scripts/start_installimage) script. This will source the `config_live.sh` file and try to download a normal installimage autoconfig file, if this fails it tries to download a json hash which will be converted into the needed format. After that, the installimage starts in a screen session and reboots if everything worked well. You can do a fully automated installatio if you attach `script=/usr/local/bin/start_installimage` to the PXE kernel cmdline.
