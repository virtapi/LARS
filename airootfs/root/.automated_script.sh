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

get_mac ()
{
  awk 'BEGIN {FS="="; RS=" ";} { if ($1 ~ /BOOTIF/) {gsub(/^[^-]+-/, "", $2); gsub(/-/, ":", $2); print tolower($2)}}' /proc/cmdline
}

get_interface_we_booted_from ()
{
  awk '/'"$1"'/ {sub(/:/, "", $2); print $2}' <<< "$(ip -oneline link show up)"
}

setup_ipv6 ()
{
  if [ -n "$IP6ADDR" ] && [ -n "$IP6GW" ] && [ -n "$IP6PRE" ]; then
    local mac=""
    local interface=""
    mac="$(get_mac)"
    interface="$(get_interface_we_booted_from "$mac")"
    ip -6 addr add "${IP6ADDR}/${IP6PRE}" dev "$interface"
    ip -6 route delete default
    ip -6 route add default via "$IP6GW" dev "$interface"
  fi
}

if [[ $(tty) == "/dev/tty1" ]]; then
  cmdline="$(cat /proc/cmdline)"
  # shellcheck disable=SC2163
  for i in $cmdline; do
    case "$i" in
      HASH=*) export "$i";;
      IP6ADDR=*) export "$i";;
      IP6GW=*) export "$i";;
      IP6PRE=*) export "$i";;
    esac;
  done

  setup_ipv6

  if [ -n "$HASH" ]; then
    grep -v "^root" /etc/shadow > /tmp/shadow.tmp
    GECOS="$(awk -F: '/^root/ {print $3":"$4":"$5":"$6":"$7":"$8":"}' /etc/shadow)"
    echo "root:${HASH}:${GECOS}" > /etc/shadow
    cat /tmp/shadow.tmp >> /etc/shadow
    rm /tmp/shadow.tmp
  fi
  automated_script
fi
