#!/bin/bash

set -e

lxc profile copy default ap

lxc profile device remove ap eth0
lxc profile device add ap eth0 nic name=eth0 nictype=bridged parent=br0 hwaddr=be:ef:be:ef:00:40
lxc profile device add ap wlan1 nic name=wlan1 nictype=physical parent=wlan1

lxc launch images:alpine/edge ap -p ap
sleep 5

lxc exec ap -- apk update
lxc exec ap -- apk upgrade

lxc exec ap -- apk add hostapd bridge


lxc file push ../templates/interfaces ap/etc/network/interfaces
lxc file push ../templates/hostapd.conf ap/etc/hostapd/hostapd.conf

lxc exec ap -- rc-update add hostapd

lxc restart ap
# lxc stop ap
# lxc publish ap --alias apimg
# lxc image export apimg ap
# lxc image delete apimg
# lxc delete ap
