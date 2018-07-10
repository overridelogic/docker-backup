#!/usr/bin/python3

import docker

client = docker.from_env()
volumes = client.volumes.list(filters={
    'dangling': 'false',
})

for volume in volumes:
    if len(volume.name) == 64:
        continue
    print(volume.name)
