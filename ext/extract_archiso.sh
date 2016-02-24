#!/bin/bash

##
# written by bastelfreak
# inspiried by Bluewind
##
# requires p7zip
##
# requires a ISO file, extract it so we can use it easily via PXE
##

set -e

umask 022
if [ -z "${1}" ]; then
  exit 1
fi

iso="$(readlink -f "$1")"

cd /var/www/archrescue/

rm -rf /var/www/archrescue/arch
7z x "${iso}"

rm -rf EFI isolinux loader "[BOOT]"
find . -type d -exec chmod 755 {} +
find . -type f -exec chmod 644 {} +
