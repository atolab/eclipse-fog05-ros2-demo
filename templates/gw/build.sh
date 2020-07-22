#!/bin/bash

set -e

sudo ip link add br0 type bridge
sudo ip link up dev br0

lxc launch images:alpine/edge gw

lxc exec gw -- apk update
lxc exec gw -- apk add dnsmasq awall

lxc file push ./interfaces gw/etc/network/interfaces
lxc file push ./demo.conf gw/etc/dnsmasq.d/
lxc file push ./dnsmasq.hosts gw/etc/dnsmasq.hosts
lxc file push ./demo.json gw/etc/awall/optional/

lxc exec gw -- awall enable demo
lxc exec gw -- sh -c "yes | awall activate"

lxc exec gw -- rc-update add iptables
lxc exec gw -- rc-update add dnsmasq

lxc restart gw