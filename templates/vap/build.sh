#!/bin/bash

set -e

lxc profile copy default ap

# lxc profile device remove ap eth0
# lxc profile device add ap eth0 nic name=eth0 nictype=bridged parent=br0 hwaddr=be:ef:be:ef:00:40
lxc profile device add ap wlxf4ec38e886ad nic name=wlxf4ec38e886ad nictype=physical parent=wlxf4ec38e886ad

lxc launch images:alpine/edge ap -p ap
sleep 5

lxc exec ap -- apk update
lxc exec ap -- apk upgrade

lxc exec ap -- apk add hostapd bridge


lxc file push ./interfaces ap/etc/network/interfaces
lxc file push ./hostapd.conf ap/etc/hostapd/hostapd.conf

lxc exec ap -- rc-update add hostapd

lxc stop ap
lxc publish ap --alias apimg
lxc image export apimg ap
lxc image delete apimg
lxc delete ap