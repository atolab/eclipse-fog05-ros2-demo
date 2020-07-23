import os
from fog05 import FIMAPI
from fog05_sdk.interfaces.FDU import FDU
import sys
import time
import json


DESC_FOLDER = './descriptors'


descs = {
    'gw':'gw.json',
    'ap':'vap.json',
    'zenoh':'zenoh.json',
    'server':'teleop-server.json',
    'gui':'gui.json',
}

net_desc = ['vnet.json']

def read_file(filepath):
    with open(filepath, 'r') as f:
        data = f.read()
    return data


def read(fname):
    return open(fname).read()


def main(ip):
    a = FIMAPI(ip)

    fdus = {}
    nets = []

    print('Current Eclipse fog05 Infrastructure:')

    nodes = a.node.list()
    for nid in nodes:
        info = a.node.info(nid)
        print('ID: {} Hostname: {}'.format(nid, info['name']))


    input('Press enter to instantiate the demo')

    for d in net_desc:
        path_d = os.path.join(DESC_FOLDER,d)
        netd = json.loads(read(path_d))
        a.network.add_network(netd)
        nets.append(netd['uuid'])
        time.sleep(1)




    for name in descs:
        d = descs[name]
        print('Instantiating {}'.format(name))
        path_d = os.path.join(DESC_FOLDER,d)
        data = json.loads(read(path_d))
        fdu_d = FDU(data)
        fduinfo = a.fdu.onboard(fdu_d)
        fdu_id = fduinfo.get_uuid()
        print ('fdu_id : {}'.format(fdu_id))
        inst_info = a.fdu.define(fdu_id)
        iid = inst_info.get_uuid()
        a.fdu.configure(iid)
        time.sleep(1)
        if name == 'server':
            a.fdu.start(iid, "ZENOH=172.16.123.20")
        else:
            a.fdu.start(iid)
        print ('iid : {}'.format(iid))
        print('Instantiated: {}'.format(name))
        fdus.update({fdu_id: iid})
        time.sleep(2)

    print('Instantiated:')
    print(json.dumps(fdus, indent=2))
    print('Bye!')



if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage {} <zenoh ip:port>")
        exit(-1)
    main(sys.argv[1])