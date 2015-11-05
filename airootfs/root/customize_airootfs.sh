#!/bin/bash

##
# modified by bastelfreak
# based on work from Bluewind and foxxx0
##

# get our config
config='/root/config.sh'
if [ -x "$config" ]; then
  . /root/config.sh
else
  exit 1
fi

set -e -u

# get our config
. /root/config.sh

# english language and german keyboard layout
sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
echo 'KEYMAP=de' > /etc/vconsole.conf
locale-gen

ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

usermod -s /usr/bin/bash root
chmod 700 /root

if [ -n "$ISO_MIRROR" ]; then
  echo "Server = $ISO_MIRROR" > /etc/pacman.d/mirrorlist
fi

sed -i 's/#\(PermitRootLogin \).\+/\1yes/' /etc/ssh/sshd_config
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf

sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf

systemctl enable pacman-init.service choose-mirror.service systemd-networkd.service systemd-resolved.service sshd.service
systemctl set-default multi-user.target

# they are broken and nobody needs them
pacman -Rns --noconfirm openresolv netctl dhcpcd

# populate trust information
trust extract-compat

# add installimage NFS mounts
if [ -n "$ISO_NFSSERVER" ]; then
  echo "${ISO_NFSSERVER}:/srv/nfs/installimage /root/.installimage nfs ro 0 0" >> /etc/fstab
  echo "${ISO_NFSSERVER}:/srv/nfs/images /root/images nfs ro 0 0" >> /etc/fstab
  mkdir -p /root/{images,.installimage}
fi

# update package information
pacman -Syy
pkgfile --update

# remove config, could contain sensitive information and we don't want to ship it in the ISO
rm "$config"

# use the resolv.conf from systemd-resolved.service
umount /etc/resolv.conf
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
