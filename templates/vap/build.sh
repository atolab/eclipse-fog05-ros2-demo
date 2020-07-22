#!/bin/bash

set -e


lxc launch images:alpine/edge ap
sleep 5

lxc exec ap -- apk update
lxc exec ap -- apk upgrade

lxc exec ap -- apk add hostapd bridge


lxc file push ../templates/interfaces ap/etc/network/interfaces
lxc file push ../templates/hostapd.conf ap/etc/hostapd/hostapd.conf

lxc exec ap -- rc-update add hostapd

lxc restart ap