#!/bin/bash

script_cmdline ()
{
    local param
    for param in $(< /proc/cmdline); do
        case "${param}" in
            script=*) echo "${param#*=}" ; return 0 ;;
        esac
    done
}

automated_script ()
{
    local script rt
    script="$(script_cmdline)"
    if [[ -n "${script}" && ! -x /tmp/startup_script ]]; then
        if [[ "${script}" =~ ^http:// || "${script}" =~ ^ftp:// ]]; then
            wget "${script}" --retry-connrefused -q -O /tmp/startup_script >/dev/null
            rt=$?
        else
            cp "${script}" /tmp/startup_script
            rt=$?
        fi
        if [[ ${rt} -eq 0 ]]; then
            chmod +x /tmp/startup_script
            /tmp/startup_script
        fi
    fi
}

if [[ $(tty) == "/dev/tty1" ]]; then
  cmdline="$(cat /proc/cmdline)"
  for i in $cmdline; do case "$i" in HASH=*) export "$i";; esac; done
  if [ -n "$HASH" ]; then
    grep -v "^root" /etc/shadow > /tmp/shadow.tmp
    GECOS="$(awk -F: '/^root/ {print $3":"$4":"$5":"$6":"$7":"$8":"}' /etc/shadow)"
    echo "root:${HASH}:${GECOS}" > /etc/shadow
    cat /tmp/shadow.tmp >> /etc/shadow
    rm /tmp/shadow.tmp
  fi
  automated_script
fi
