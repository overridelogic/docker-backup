#!/bin/sh

set -e
set -u
_DIR=`dirname $0`
_DIR=`realpath ${_DIR}`
_LIST_CMD="python3 ${_DIR}/docker-list-volumes.py"
_RUN_CMD="python3 ${_DIR}/docker-run-backup.py"
_ARGS="${VOLUMES:-$*}"

set -x
WORKDIR="${WORKDIR:-/data}"
S3_BUCKET="${S3_BUCKET:-}"
S3_PREFIX="${S3_PREFIX:-/}"
S3_ENABLELATEST="${S3_ENABLELATEST:-1}"
S3_OPTS="${S3_OPTS:-}"

_HOST=`hostname -s`
_TIMESTAMP=`date +'%Y%m%d%H%M'`
set +x

discoverVolumes() {
    DATA=`$_LIST_CMD`
    VOLUMES=""

    if [ "$_ARGS" == "" ]; then
        VOLUMES="$DATA"
    else
        for volume in "$DATA"; do
            if [[ " ${_ARGS} " =~ " ${volume} " ]]; then
                VOLUMES="${VOLUMES} ${volume}"
            fi
        done
    fi

    echo -e $VOLUMES
}

createBackup() {
    volume="$1"

    OUTPUT_BASE="${_HOST}_${volume}"
    OUTPUT_FILE="${OUTPUT_BASE}-${_TIMESTAMP}.tar.gz"
    OUTPUT_FULL="${WORKDIR}/${OUTPUT_FILE}"
    
    echo -n "Creating ${volume}... "
    $_RUN_CMD "${volume}" > "${OUTPUT_FULL}"

    echo -n "created... "

    if [ "${S3_BUCKET}" != "" ]; then
        echo -n "uploading... "
        s3cmd put ${S3_OPTS} "${OUTPUT_FULL}" "s3://${S3_BUCKET}${S3_PREFIX}"

        if [ $S3_ENABLELATEST -gt 0 ]; then
            echo -n "updating tag... "
            s3cmd cp ${S3_OPTS} "s3://${S3_BUCKET}/${OUTPUT_FILE}" "s3://${S3_BUCKET}/${OUTPUT_BASE}-latest.tar.gz"
        fi
    fi

    SIZE=`du -h ${OUTPUT_FULL} | cut -f1`
    echo "done: ${SIZE}, ${OUTPUT_FILE}"
}

VOLUMES="$(discoverVolumes)"
COUNT=`echo "${VOLUMES}" | wc -w`
echo "Found ${COUNT} volumes."

for volume in ${VOLUMES}; do
    createBackup "${volume}"
done

echo "Finished!"
