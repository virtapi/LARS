#!/bin/bash

##
# created by bastelfreak
# based on a script by Bluewind
##

config='config.sh'

if [ -x "$config" ]; then
  . config.sh
else
  exit 1
fi

# we need to place the set under the exit
# it would ignore it because it's in an if/fi statement
set -e
umask 022

cp config.sh airootfs/root/
rm -rf work
./build.sh -v
rm -rf work

unset -v latest
for file in out/archlinux-*.iso; do
	[[ $file -nt $latest ]] && latest=$file
done

rsync -tP "$latest" -e ssh "${DHCP_USER}@${DHCP_SERVER}:${DHCP_PATH}"
ssh "${DHCP_USER}@${DHCP_SERVER}" "${DHCP_EXTRACT} ${DHCP_PATH}${latest##*/}"
