#!/bin/bash
set -e
SERVICE_USER="user"
SERVICE_IP="172.20.249.5"
JOB="${JOB:-""}"
SERVICES="${SERVICES:-"mc-eureka mc-config mc-gateway mc-auth mc-upms/mc-upms-biz mc-news/mc-news-biz mc-basic/mc-basic-biz mc-post/mc-post-biz mc-msg/mc-msg-biz mc-trans/mc-trans-biz mc-quotation/mc-quotation-biz"}"
HARBOR="${HARBOR:-"harbor.augcloud.com"}"

ssh ${SERVICE_USER}@${SERVICE_IP} << eeooff
    if [ "${JOB}" == "mc-platform" ]; then
        for service in ${SERVICES[@]}; do
            MODULE_NAME=`echo "${service}" | awk -F "/" '{print $1}'`
            IMAGE_NAME=${HARBOR}/augops/${MODULE_NAME}
            echo "=============================================="
            echo "pull image: ${IMAGE_NAME}"
            echo "=============================================="
            docker pull ${IMAGE_NAME}

            echo "=============================================="
            echo "tag image: ${IMAGE_NAME} to ${MODULE_NAME}"
            echo "=============================================="
            docker tag ${IMAGE_NAME} ${MODULE_NAME}
        done

        docker-compose up -d
    fi
exit
eeooff