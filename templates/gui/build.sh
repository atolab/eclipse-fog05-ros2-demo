#!/bin/bash

set -e


lxc launch images:alpine/edge gui
sleep 5

lxc exec gui -- apk update
lxc exec gui -- apk add nginx git
lxc exec gui -- rc-update add nginx
lxc exec gui -- sh -c "cd /root && git clone https://github.com/atolab/teleop_yaks"
lxc exec gui -- sh -c "cp -r /root/teleop_yaks/gui/* /var/www/localhost/htdocs/"
lxc exec gui -- sh -c "rm -rf /root/teleop_yaks"

lxc file push ./interfaces gui/etc/network/interfaces
lxc file push ./resolv.conf gui/etc/resolv.conf
lxc file push ./default.conf gui/etc/nginx/conf.d/default.conf

lxc stop gui
lxc publish gui --alias guiimg
lxc image export guiimg gui
lxc image delete guiimg
lxc delete gui