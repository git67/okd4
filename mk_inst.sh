#!/bin/bash 

set -euo pipefail

PXE_OKD4_DIR="/var/lib/tftpboot/okd4"
WEB_DIR="/var/www/html"
WWW_OKD4_DIR="${WEB_DIR}/okd4/"

BASE_DIR="/data/okd4"
SRC_DIR="${BASE_DIR}/src"
INST_DIR="${BASE_DIR}/install"
LOCAL_DIR="${BASE_DIR}/local"
INSTALL_CONFIG="${LOCAL_DIR}/install-config.yaml"

OPENSHIFT_URI="https://github.com/openshift/okd/releases/download"

CLIENT="${OPENSHIFT_URI}/4.7.0-0.okd-2021-02-25-144700/openshift-client-linux-4.7.0-0.okd-2021-02-25-144700.tar.gz"
INSTALLER="${OPENSHIFT_URI}/4.7.0-0.okd-2021-02-25-144700/openshift-install-linux-4.7.0-0.okd-2021-02-25-144700.tar.gz"

FCOS_RELEASE="33.20210201.3.0"
FCOS_URI="https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/${FCOS_RELEASE}/x86_64"

KERNEL="${FCOS_URI}/fedora-coreos-${FCOS_RELEASE}-live-kernel-x86_64"
INITRAMFS="${FCOS_URI}/fedora-coreos-${FCOS_RELEASE}-live-initramfs.x86_64.img"
ROOT_FS="${FCOS_URI}/fedora-coreos-${FCOS_RELEASE}-live-rootfs.x86_64.img"

RAW="${FCOS_URI}/fedora-coreos-${FCOS_RELEASE}-metal.x86_64.raw.xz"
RAW_SIG="${FCOS_URI}/fedora-coreos-${FCOS_RELEASE}-metal.x86_64.raw.xz.sig"

if [ -d ${SRC_DIR} ]; then
    rm -rf ${SRC_DIR}

    mkdir -p ${SRC_DIR} ${PXE_OKD4_DIR} ${WWW_OKD4_DIR}

    cd ${SRC_DIR}

    wget -q ${CLIENT}
    tar zxf $(echo ${CLIENT}| awk -F/ '{print $NF}')

    wget -q ${INSTALLER}
    tar zxf $(echo ${INSTALLER}| awk -F/ '{print $NF}')

    wget -q ${KERNEL}
    cp $(echo ${KERNEL}| awk -F/ '{print $NF}') ${PXE_OKD4_DIR}/cos-kernel

    wget -q ${INITRAMFS}
    cp $(echo ${INITRAMFS}| awk -F/ '{print $NF}') ${PXE_OKD4_DIR}/cos-initramfs

    wget -q ${ROOT_FS}
    cp $(echo ${ROOT_FS}| awk -F/ '{print $NF}') ${PXE_OKD4_DIR}/cos-live-rootfs

    wget -q ${RAW}
    cp $(echo ${RAW}| awk -F/ '{print $NF}') ${WWW_OKD4_DIR}/cos.raw.xz

    wget -q ${RAW_SIG}
    cp $(echo ${RAW_SIG}| awk -F/ '{print $NF}') ${WWW_OKD4_DIR}/cos.raw.xz.sig

    chown -R apache:apache ${WEB_DIR}
    chmod -R 755 ${WEB_DIR}

    cp openshift-install kubectl oc /usr/local/bin/
fi

if [ -f ${INSTALL_CONFIG} ]; then
    rm -rf ${INST_DIR}
    mkdir -p ${INST_DIR} 
    cd ${BASE_DIR}

    cp ${INSTALL_CONFIG} ${INST_DIR}/

    openshift-install create manifests --dir=${INST_DIR}/
    sed -i 's/mastersSchedulable: true/mastersSchedulable: False/' ${INST_DIR}/manifests/cluster-scheduler-02-config.yml
    openshift-install create ignition-configs --dir=${INST_DIR}/

    cp -R ${INST_DIR}/auth/ ${LOCAL_DIR}/

    cd ${INST_DIR}

    cp -R * ${WWW_OKD4_DIR}/

    chown -R apache:apache ${WEB_DIR}
    chmod -R 755 ${WEB_DIR}
fi
