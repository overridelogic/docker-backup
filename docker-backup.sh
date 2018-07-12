#!/bin/bash

set -e
set -u
_DIR=`dirname $0`
_DIR=`realpath ${_DIR}`
_LIST_CMD="python3 ${_DIR}/docker-list-volumes.py"
_RUN_CMD="python3 ${_DIR}/docker-run-backup.py"
_TOGGLE_CMD="python3 ${_DIR}/docker-toggle-containers.py"
_ARGS="${VOLUMES:-$*}"

set -x
_TIMESTAMP=`date +'%Y%m%d%H%M'`
WORKDIR="${WORKDIR:-/data}"
PREFIX="${PREFIX:-volume_}"
EXCLUDE="${EXCLUDE:-}"
PAUSE="${PAUSE:-0}"
S3_BUCKET="${S3_BUCKET:-}"
S3_PREFIX="${S3_PREFIX:-/}"
S3_ENABLELATEST="${S3_ENABLELATEST:-1}"
set +x
S3_OPTS="${S3_OPTS:-}"

discoverVolumes() {
    DATA=`$_LIST_CMD`
    VOLUMES=""

    for volume in $DATA; do
        if [ "$EXCLUDE" == "" ] || [[ ! "$volume" =~ ${EXCLUDE} ]]; then
            if [ "$_ARGS" == "" ] || [[ " ${_ARGS} " =~ " ${volume} " ]]; then
    	        VOLUMES="${VOLUMES} ${volume}"
            fi
	fi
    done

    echo -e $VOLUMES
}

createBackup() {
    volume="$1"

    OUTPUT_BASE="${PREFIX}${volume}"
    OUTPUT_FILE="${OUTPUT_BASE}-${_TIMESTAMP}.tar.gz"
    OUTPUT_FULL="${WORKDIR}/${OUTPUT_FILE}"
    
    echo -n "Creating ${volume}... "
    $_RUN_CMD "${volume}" > "${OUTPUT_FULL}"

    echo -n "created... "

    SIZE=`du -h ${OUTPUT_FULL} | cut -f1`
    echo "done: ${SIZE}, ${OUTPUT_FILE}"
}

uploadBackup() {
    volume="$1"

    OUTPUT_BASE="${PREFIX}${volume}"
    OUTPUT_FILE="${OUTPUT_BASE}-${_TIMESTAMP}.tar.gz"
    OUTPUT_FULL="${WORKDIR}/${OUTPUT_FILE}"

    if [ "${S3_BUCKET}" != "" ]; then
        echo -n "Uploading to S3... "
        s3cmd put ${S3_OPTS} "${OUTPUT_FULL}" "s3://${S3_BUCKET}${S3_PREFIX}"

        if [ $S3_ENABLELATEST -gt 0 ]; then
            echo -n "updating tag... "
            s3cmd cp ${S3_OPTS} "s3://${S3_BUCKET}/${OUTPUT_FILE}" "s3://${S3_BUCKET}/${OUTPUT_BASE}-latest.tar.gz"
        fi

        echo "done."
    fi
}

VOLUMES="$(discoverVolumes)"
COUNT=`echo "${VOLUMES}" | wc -w`
echo "Found ${COUNT} volumes."

if [ $PAUSE -gt 0 ] && [ "$VOLUMES" != "" ]; then
    echo "Pausing containers."
    $_TOGGLE_CMD 0
fi

for volume in ${VOLUMES}; do
    createBackup "${volume}"
done

if [ $PAUSE -gt 0 ] && [ "$VOLUMES" != "" ]; then
    echo "Resuming containers."
    $_TOGGLE_CMD 1
fi

for volume in ${VOLUMES}; do
    uploadBackup "${volume}"
done

echo "Finished!"
