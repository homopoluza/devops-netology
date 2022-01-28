#!/usr/bin/env python3

import socket as s
import json
import yaml

servers = {'drive.google.com': '0.0.0.0', 'mail.google.com': '0.0.0.0', 'google.com': '0.0.0.0'}

i = 0
while i < 10:
    for host in servers:
        ip = s.gethostbyname(host)
        if ip != servers[host]:
            print('[ERROR] ' + host + ' IP mismatch: ' + servers[host] + ' ' + ip)
            servers[host] = ip
            with open ('data.json', 'w') as js:
                json.dump(servers, js)
            with open ('data.yaml', 'w') as ym:
                yaml.dump(servers, ym)
            
    i += 1