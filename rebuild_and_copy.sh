#!/bin/bash

##
# created by bastelfreak
# based on a script by Bluewind
##

. config.sh
set -e
umask 022

rm -rf work
./build.sh -v
rm -rf work

unset -v latest
for file in out/archlinux-*.iso; do
	[[ $file -nt $latest ]] && latest=$file
done

rsync -tP "$latest" -e ssh "${DHCP_USER}@${DHCP_SERVER}:${DHCP_PATH}"
ssh "${DHCP_USER}@${DHCP_SERVER}" "${DHCP_EXTRACT} ${DHCP_PATH}${latest##*/}"
