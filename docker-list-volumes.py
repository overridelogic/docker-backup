#!/usr/bin/python3

import docker

client = docker.from_env()
volumes = client.volumes.list(filters={
    'dangling': 'false',
})

for volume in volumes:
    print(volume.name)
