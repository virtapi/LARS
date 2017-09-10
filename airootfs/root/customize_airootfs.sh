#!/bin/bash

##
# modified by bastelfreak
# based on work from Bluewind and foxxx0
##

# get our config
config='/root/config_build.sh'
if [ -n "$config" ] && [ -e "$config" ]; then
  # source and remove config, could contain sensitive information and we don't want to ship it in the ISO
  # shellcheck disable=SC1090
  . "${config}"
  rm "${config}"
else
  echo "Error: ${config} file isn't available"
  exit 1
fi

set -e -u

# english language and german keyboard layout
sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
echo 'KEYMAP=de' > /etc/vconsole.conf
locale-gen

ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

usermod -s /bin/bash root
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

# add our aur repo
echo '
[aur]
SigLevel = Optional TrustAll
Include = /etc/pacman.d/mirrorlist
' >> /etc/pacman.conf

# update package information
pacman -Syy
pkgfile --update

# set rootpassword to our hash or to none
if [ -z "$ISO_ROOTHASH" ]; then
	ISO_ROOTHASH='*'
fi
grep -v "^root" /etc/shadow > /tmp/shadow.tmp
GECOS="$(awk -F: '/^root/ {print $3":"$4":"$5":"$6":"$7":"$8":"}' /etc/shadow)"
echo "root:${ISO_ROOTHASH}:${GECOS}" > /etc/shadow
cat /tmp/shadow.tmp >> /etc/shadow
rm /tmp/shadow.tmp

# use the resolv.conf from systemd-resolved.service
if [ -L /etc/resolv.conf ]; then
  umount /etc/resolv.conf
fi

# setup sysctl foo to prevent RA
# this results in 4?! gateways configured
mkdir -p /etc/sysctl.d/
echo '
net.ipv4.icmp_echo_ignore_broadcasts=1
# ipv6 settings (no autoconfiguration)
net.ipv6.conf.default.autoconf=0
net.ipv6.conf.default.accept_dad=0
net.ipv6.conf.default.accept_ra=0
net.ipv6.conf.default.accept_ra_defrtr=0
net.ipv6.conf.default.accept_ra_rtr_pref=0
net.ipv6.conf.default.accept_ra_pinfo=0
net.ipv6.conf.default.accept_source_route=0
net.ipv6.conf.default.accept_redirects=0
net.ipv6.conf.default.forwarding=0
net.ipv6.conf.all.autoconf=0
net.ipv6.conf.all.accept_dad=0
net.ipv6.conf.all.accept_ra=0
net.ipv6.conf.all.accept_ra_defrtr=0
net.ipv6.conf.all.accept_ra_rtr_pref=0
net.ipv6.conf.all.accept_ra_pinfo=0
net.ipv6.conf.all.accept_source_route=0
net.ipv6.conf.all.accept_redirects=0
net.ipv6.conf.all.forwarding=0
' >> /etc/sysctl.d/99-ipv6.conf

touch /etc/sysctl.conf
