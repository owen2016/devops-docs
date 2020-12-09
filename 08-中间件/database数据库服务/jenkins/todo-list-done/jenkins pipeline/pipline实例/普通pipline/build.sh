#!/bin/bash
set -e

JOB="${JOB:-""}"
ENV="${ENV:-"dev"}"
SERVICES="${SERVICES:-"mc-eureka mc-config mc-gateway mc-auth mc-upms/mc-upms-biz mc-news/mc-news-biz mc-basic/mc-basic-biz mc-post/mc-post-biz mc-msg/mc-msg-biz mc-trans/mc-trans-biz mc-quotation/mc-quotation-biz"}"
HARBOR="${HARBOR:-"harbor.augcloud.com"}"

if [ "${JOB}" == "mc-platform" ]; then
    mvn clean install -Dmaven.test.skip=true
    docker-compose build --build-arg "env=${ENV}"

    for service in ${SERVICES[@]}; do
        MODULE_NAME=`echo "${service}" | awk -F "/" '{print $1}'`
        IMAGE_NAME=${HARBOR}/augops/${MODULE_NAME}
        echo "=============================================="
        echo "tag image: ${MODULE_NAME} to ${IMAGE_NAME}"
        echo "=============================================="
        docker tag ${MODULE_NAME} ${IMAGE_NAME}
    done

    for service in ${SERVICES[@]}; do
        MODULE_NAME=`echo "${service}" | awk -F "/" '{print $1}'`
        IMAGE_NAME=${HARBOR}/augops/${MODULE_NAME}
        echo "=============================================="
        echo "uplad image: ${IMAGE_NAME}"
        echo "=============================================="
        docker push ${IMAGE_NAME}
    done
fi