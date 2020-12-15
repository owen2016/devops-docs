#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import logging

logging.basicConfig(level = logging.INFO,format = '%(asctime)s - %(levelname)s - %(message)s')

K8S_IMAGES_EXTERNAL_REPOSITRY = 'registry.cn-hangzhou.aliyuncs.com/k8sth/'
K8S_IMAGES = [
    'kube-apiserver-amd64:v1.11.1',
    'kube-controller-manager-amd64:v1.11.1',
    'kube-scheduler-amd64:v1.11.1',
    'kube-proxy-amd64:v1.11.1',
    'pause:3.1',
    'pause-amd64:3.1',
    'etcd-amd64:3.2.18',
    'coredns:1.1.3',
]

ISTIO_IMAGES = {
    'proxy_init:1.0.2': 'registry.cn-hangzhou.aliyuncs.com/repository_zhang/proxy_init:1.0.2',
    'proxyv2:1.0.2': 'registry.cn-hangzhou.aliyuncs.com/repository_zhang/proxyv2:1.0.2',
    'hyperkube:v1.7.6_coreos.0': 'quay.io/coreos/hyperkube:v1.7.6_coreos.0',
    'statsd-exporter:v0.6.0': 'docker.io/prom/statsd-exporter:v0.6.0',
    'galley:1.0.2': 'registry.cn-hangzhou.aliyuncs.com/repository_zhang/galley:1.0.2',
    'grafana:1.0.2': 'registry.cn-hangzhou.aliyuncs.com/repository_zhang/grafana:1.0.2',
    'mixer:1.0.2': 'registry.cn-hangzhou.aliyuncs.com/repository_zhang/mixer:1.0.2',
    'pilot:1.0.2': 'registry.cn-hangzhou.aliyuncs.com/repository_zhang/pilot:1.0.2',
    'prometheus:v2.3.1': 'docker.io/prom/prometheus:v2.3.1',
    'citadel:1.0.2': 'registry.cn-hangzhou.aliyuncs.com/repository_zhang/citadel:1.0.2',
    'servicegraph:1.0.2': 'registry.cn-hangzhou.aliyuncs.com/repository_zhang/servicegraph:1.0.2',
    'sidecar_injector:1.0.2': 'registry.cn-hangzhou.aliyuncs.com/repository_zhang/sidecar_injector:1.0.2',
    'all-in-one:1.5': 'docker.io/jaegertracing/all-in-one:1.5'
}

OTHER_IMAGE = {
    # calico
    'typha:v0.7.4': 'quay.io/calico/typha:v0.7.4',
    'node:v3.1.3': ' quay.io/calico/node:v3.1.3',
    'cni:v3.1.3': 'quay.io/calico/cni:v3.1.3',
    # efk
    'elasticsearch:6.2.4': 'registry.cn-hangzhou.aliyuncs.com/lolwen/elasticsearch:6.2.4',
    'alpine:3.6': 'registry.cn-hangzhou.aliyuncs.com/lolwen/alpine:3.6',
    'fluentd-elasticsearch:v2.2.0': 'registry.cn-hangzhou.aliyuncs.com/k8s-yun/fluentd-elasticsearch:v2.2.0',
    'kibana:6.2.4': 'registry.cn-hangzhou.aliyuncs.com/zhangbohan/kibana:6.2.4',
    # monitor
    'alertmanager:v0.15.0': 'quay.io/prometheus/alertmanager:v0.15.0',
    'grafana:5.1.0': 'grafana/grafana:5.1.0',
    'kube-rbac-proxy:v0.3.1': 'quay.io/coreos/kube-rbac-proxy:v0.3.1',
    'kube-state-metrics:v1.3.1': 'quay.io/coreos/kube-state-metrics:v1.3.1',
    'addon-resizer:1.0': 'quay.io/coreos/addon-resizer:1.0',
    'node-exporter:v0.15.2': 'quay.io/prometheus/node-exporter:v0.15.2',
    'prometheus-operator:v0.22.0': 'quay.io/coreos/prometheus-operator:v0.22.0',
    'configmap-reload:v0.0.1': 'quay.io/coreos/configmap-reload:v0.0.1',
    'prometheus-config-reloader:v0.22.0': 'quay.io/coreos/prometheus-config-reloader:v0.22.0',
    'prometheus:v2.3.1': 'quay.io/prometheus/prometheus:v2.3.1',
    'docker-apollo:1.2.0': 'idoop/docker-apollo:1.2.0',
    'naftis-ui:0.1.4-rc6': 'sevennt/naftis-ui:0.1.4-rc6',
    'naftis-api:0.1.4-rc6': 'sevennt/naftis-api:0.1.4-rc6',
    'bats:0.4.0': 'dduportal/bats:0.4.0',
    'mysql:5.7.14': 'mysql:5.7.14',
    'busybox:1.25.0': 'busybox:1.25.0'
}

HARBOR_DOMAIN = 'xxx'

HARBOR_PROJECT_NAME = 'xxxxx/'

def pullImage(image):
    pullCommand = 'docker pull %s' % image
    logging.info(pullCommand)
    os.system(pullCommand)

def saveImage(image, imageName):
    saveImageCommand = 'docker save -o ./%s.tar %s' % (imageName, image)
    logging.info(saveImageCommand)
    os.system(saveImageCommand)

def loadImage(imageFile):
    loadImageCommand = 'docker load -i %s' % (imageFile)
    logging.info(loadImageCommand)
    os.system(loadImageCommand)

def tagImage(originImage, tagImage):
    tagImageCommand = 'docker tag %s %s' % (originImage, tagImage)
    logging.info(tagImageCommand)
    os.system(tagImageCommand)

def pushImage(image):
    pushImageCommand = 'docker push %s' % (image)
    logging.info(pushImageCommand)
    os.system(pushImageCommand)

def pushImageToHarbor(originImage, pushedImage, imageName):
    isPushedImageCommand = 'docker image inspect %s' % (pushedImage)
    isPushedImageCommandResult = os.system(isPushedImageCommand)
    if (isPushedImageCommandResult == 0):
        pushImage(pushedImage)
    else:
        isOriginImageExistCommand = 'docker image inspect %s' % (originImage)
        isOriginImageExistCommandResult = os.system(isOriginImageExistCommand)
        if (isOriginImageExistCommandResult == 0):
            tagImage(originImage, pushedImage)
            pushImage(pushedImage)
        else:
            imageFile = './%s.tar' % (imageName)
            isImageFileExist = os.path.exists(imageFile)
            if (isImageFileExist):
                loadImage(imageFile)
            else:
                pullImage(originImage)
                tagImage(originImage, pushedImage)
                saveImage(pushedImage, imageName)
            pushImage(pushedImage)

def main():
    for image in K8S_IMAGES:
        k8sImage = K8S_IMAGES_EXTERNAL_REPOSITRY + image
        pushedImage = HARBOR_DOMAIN + HARBOR_PROJECT_NAME + image
        pushImageToHarbor(k8sImage, pushedImage, image)
    for imageName, originImage in ISTIO_IMAGES.items():
        pushedImage = HARBOR_DOMAIN + HARBOR_PROJECT_NAME + imageName
        pushImageToHarbor(originImage, pushedImage, imageName)
    for imageName, originImage in OTHER_IMAGE.items():
        pushedImage = HARBOR_DOMAIN + HARBOR_PROJECT_NAME + imageName
        pushImageToHarbor(originImage, pushedImage, imageName)

if __name__ == '__main__':
    main()