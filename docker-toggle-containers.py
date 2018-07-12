#!/usr/bin/python3

import os
import sys
import docker

try:
    flag = sys.argv[1] != "0"
except:
    flag = True

client = docker.from_env()
containers = client.containers.list()

for container in containers:
    if container.id == os.getenv('HOSTNAME') or container.name == os.getenv('HOSTNAME'):
        continue

    if flag:
        try:
            container.unpause()
        except Exception as ex:
            if 'is not paused' not in str(ex):
                raise
    else:
        try:
            container.pause()
        except Exception as ex:
            if 'is already paused' not in str(ex):
                raise
