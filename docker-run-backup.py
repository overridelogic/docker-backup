#!/usr/bin/python3

import sys
import docker

volume = sys.argv[1]

client = docker.from_env()
command = "/bin/sh -c 'cd /data && tar -zcf - {0}'".format(volume)
result = client.containers.run('busybox', command, **{
    'auto_remove': True,
    'volumes': {
        volume: { 'bind': '/data/{0}'.format(volume), 'mode': 'ro' },
    },
})

with open(1, 'wb') as fp:
    fp.write(result)
