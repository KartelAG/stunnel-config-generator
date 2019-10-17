#!/usr/bin/env python

import sys
import configparser

# APP_PORT - application port to protect
APP_PORT = "3333"

# STUNNEL_PORT - port for server stunnel instance
STUNNEL_SERVER_PORT = "10001"

iptables_str = ""
iptables_file = open("out/iptables-rules.txt", "w")

external_ip = sys.argv[1]
if (len(sys.argv) == 3):
    internal_ip = sys.argv[2]
else:
    internal_ip = external_ip

serverlist_file = open("serverlist.txt", "r")
serverlist_file_reader = serverlist_file.readlines()

servers = dict()

for serverlist in serverlist_file_reader:
    str = (serverlist.replace("\n", "")).split(" ")
    servers[str[0]] = str


config = configparser.ConfigParser()

config['server'] = {}
config['server']['accept'] = internal_ip + ':' + STUNNEL_SERVER_PORT
config['server']['connect'] = '0.0.0.0:' + APP_PORT
config['server']['verify'] = '2'
config['server']['cert'] = 'server.cer'

for i in servers.values():
    if (i[0] != external_ip):
        config[i[0]] = {}
        config[i[0]]['client'] = 'yes'
        config[i[0]]['accept'] = internal_ip + ":" + i[1]
        config[i[0]]['connect'] = i[0] + ":" + STUNNEL_SERVER_PORT
        config[i[0]]['cert'] = 'client.cer'
        config[i[0]]['verify'] = '2'
        iptables_str = iptables_str + 'iptables -t nat -A OUTPUT -d ' + i[0] + '/32 -p tcp -m tcp --dport ' + APP_PORT + \
            ' -m comment --comment "stunnel rule" -j DNAT --to-destination ' + \
            internal_ip + ':' + i[1] + "\n"

with open('out/stunnel.conf', 'w') as cf:
    config.write(cf)

iptables_file.write(iptables_str)

iptables_file.close()
serverlist_file.close()
cf.close()
