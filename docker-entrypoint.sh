#!/bin/sh

set -e
set -u

SCHEDULE="${SCHEDULE:-}"
VOLUMES="${VOLUMES:-}"
LOGLEVEL="${LOGLEVEL:-8}"

if [ "$SCHEDULE" == "" ]; then
    echo "Running once."
    /usr/local/bin/docker-backup.sh $VOLUMES
else
    echo "Schedule set to run: ${SCHEDULE}"
    echo "${SCHEDULE} /usr/local/bin/docker-backup.sh ${VOLUMES}" >> /etc/crontabs/root
    crond -f -l ${LOGLEVEL}
fi
