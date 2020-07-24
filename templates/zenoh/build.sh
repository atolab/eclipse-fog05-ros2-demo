#!/bin/bash

set -e


lxc launch images:ubuntu/bionic zenoh
sleep 5
lxc exec zenoh -- bash -c "apt update && DEBIAN_FRONTEND=noninteractive apt-get -y install libev4 libssl1.1 curl -y"
lxc exec zenoh -- bash -c " curl -Lo /tmp/zenohd.deb https://github.com/eclipse-fog05/fog05/releases/download/v0.2.0/zenoh_0.3.0-1_ubuntu.18.04_amd64.deb"
lxc exec zenoh -- bash -c "apt install /tmp/zenohd.deb -y"

lxc file push ./10-lxc.yaml zenoh/etc/netplan/10-lxc.yaml

lxc stop zenoh
lxc publish zenoh --alias zenohimg
lxc image export zenohimg zenoh
lxc image delete zenohimg
lxc delete zenoh