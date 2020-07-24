#!/bin/bash

set -e


lxc launch images:ubuntu/bionic gui
sleep 5

lxc exec gui -- apt update
lxc exec gui -- apt install add nginx git -y
lxc exec gui -- systemctl enablne nginx
lxc exec gui -- bash -c "cd /root && git clone https://github.com/atolab/teleop_yaks"
lxc exec gui -- bash -c "cp -r /root/teleop_yaks/gui/* /var/www/html/"
lxc exec gui -- bash -c "rm -rf /root/teleop_yaks"

lxc file push ./10-lxc.yaml gui/etc/netplan/10-lxc.yaml

lxc stop gui
lxc publish gui --alias guiimg
lxc image export guiimg gui
lxc image delete guiimg
lxc delete gui