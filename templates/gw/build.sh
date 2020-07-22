#!/bin/bash

set -e

sudo ip link add br0 type bridge
sudo ip link up dev br0

lxc profile copy default gw

lxc profile device add gw eth1 nic nictype=bridged parent=br0 hwaddr=be:ef:be:ef:00:00

lxc launch images:alpine/edge gw -p gw
sleep 5

lxc exec gw -- apk update

lxc exec gw -- apk add dnsmasq awalllx

lxc file push ./interfaces gw/etc/network/interfaces
lxc file push ./demo.conf gw/etc/dnsmasq.d/
lxc file push ./dnsmasq.hosts gw/etc/dnsmasq.hosts
lxc file push ./demo.json gw/etc/awall/optional/

lxc exec gw -- awall enable demo
lxc exec gw -- sh -c "yes | awall activate"

lxc exec gw -- rc-update add iptables
lxc exec gw -- rc-update add dnsmasq


lxc stop gw
lxc publish gw --alias gwimg
lxc image export gwimg gw
lxc image delete gwimg
lxc delete gw
