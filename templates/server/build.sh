#!/bin/bash

set -e


lxc launch images:ubuntu/bionic server
sleep 5
lxc exec server -- bash -c "apt update && DEBIAN_FRONTEND=noninteractive apt-get -y install git libev4 libssl1.1 python3-pip curl -y"
lxc exec server -- bash -c "curl -Lo /tmp/zenoh.deb https://github.com/eclipse-fog05/fog05/releases/download/v0.1.0/libzenoh-0.3.0-ubuntu-amd64.deb"
lxc exec server -- bash -c "apt install /tmp/zenoh.deb -y"
lxc exec server -- bash -c "pip3 install flask zenoh==0.3.0 yaks==0.3.0.post1 flask-cors"
lxc exec server -- bash -c "cd /root && git clone https://github.com/atolab/teleop_yaks"
lxc file push ./teleop.service server/lib/systemd/system/teleop.service
lxc exec server -- bash -c "cp /root/teleop_yaks/teleop_server.py /usr/local/bin/teleop_server.py && rm -rf /root/teleop_yaks && chmod +x /usr/local/bin/teleop_server.py"
lxc exec server -- bash -c "systemctl enable teleop"


lxc stop server
lxc publish server --alias serverimg
lxc image export serverimg server
lxc image delete serverimg
lxc delete server