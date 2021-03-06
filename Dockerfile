FROM python:3-alpine
USER root
COPY docker-backup.sh /usr/local/bin
COPY docker-list-volumes.py /usr/local/bin
COPY docker-run-backup.py /usr/local/bin
COPY docker-toggle-containers.py /usr/local/bin
COPY docker-entrypoint.sh /
COPY LICENSE.md /
RUN /bin/sh -c ' \
apk add bash ; \
mkdir -p /data ; \
chmod +x /docker-entrypoint.sh ; \
chmod +x /usr/local/bin/docker-backup.sh ; \
chmod +x /usr/local/bin/docker-list-volumes.py ; \
chmod +x /usr/local/bin/docker-run-backup.py ; \
pip install s3cmd docker ; \
'
WORKDIR /data
CMD /docker-entrypoint.sh
VOLUME /data
