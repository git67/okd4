#!/bin/bash 
#
# ident "@(#)<mk_inst.sh> <0.1.0>"
#
# desc          : <Vorbereitung OKD Setup"
# version       : <0.1.0>
# dev           : <heiko.stein@etomer.com>

set -euo pipefail
PATH="${PATH}:/:/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/bin"

PXE_OKD4_DIR="/var/lib/tftpboot/okd4"
WEB_DIR="/var/www/html"
WWW_OKD4_DIR="${WEB_DIR}/okd4"

BASE_DIR="/data/okd4"
BACKUP_DIR="${BASE_DIR}/backup"
SRC_DIR="${BASE_DIR}/src"
INST_DIR="${BASE_DIR}/install"
LOCAL_DIR="${BASE_DIR}/local"
INSTALL_CONFIG="${LOCAL_DIR}/install-config.yaml"

OPENSHIFT_URI="https://github.com/openshift/okd/releases/download"
#OKD_RELEASE="4.7.0-0.okd-2021-07-03-190901"
OKD_RELEASE="4.12.0-0.okd-2023-02-18-033438"

CLIENT="${OPENSHIFT_URI}/${OKD_RELEASE}/openshift-client-linux-${OKD_RELEASE}.tar.gz"
INSTALLER="${OPENSHIFT_URI}/${OKD_RELEASE}/openshift-install-linux-${OKD_RELEASE}.tar.gz"

#FCOS_RELEASE="33.20210201.3.0"
# https://getfedora.org/de/coreos/download?tab=metal_virtualized&stream=stable
FCOS_RELEASE="37.20230122.3.0"
FCOS_URI="https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/${FCOS_RELEASE}/x86_64"

KERNEL="${FCOS_URI}/fedora-coreos-${FCOS_RELEASE}-live-kernel-x86_64"
INITRAMFS="${FCOS_URI}/fedora-coreos-${FCOS_RELEASE}-live-initramfs.x86_64.img"
ROOT_FS="${FCOS_URI}/fedora-coreos-${FCOS_RELEASE}-live-rootfs.x86_64.img"

RAW="${FCOS_URI}/fedora-coreos-${FCOS_RELEASE}-metal.x86_64.raw.xz"
RAW_SIG="${FCOS_URI}/fedora-coreos-${FCOS_RELEASE}-metal.x86_64.raw.xz.sig"

_build_env()
{
printf "%s\n" "_build_env"
[ -d ${INST_DIR} ] && rm -rf ${BACKUP_DIR}/* 
[ -d ${INST_DIR} ] && mv -f ${INST_DIR} ${BACKUP_DIR}
[ -d ${SRC_DIR} ] && mv -f ${SRC_DIR} ${BACKUP_DIR}
mkdir -p ${SRC_DIR} ${PXE_OKD4_DIR} ${WWW_OKD4_DIR} ${INST_DIR}
}

_download_and_copy()
{
printf "%s\n" "_download_and_copy"
cd ${SRC_DIR}

printf "\t%s\n" "${CLIENT}"
wget -q ${CLIENT}
tar zxf $(echo ${CLIENT}| awk -F/ '{print $NF}')

printf "\t%s\n" "${INSTALLER}"
wget -q ${INSTALLER}
tar zxf $(echo ${INSTALLER}| awk -F/ '{print $NF}')

printf "\t%s\n" "${KERNEL}"
wget -q ${KERNEL}
cp $(echo ${KERNEL}| awk -F/ '{print $NF}') ${PXE_OKD4_DIR}/cos-kernel

printf "\t%s\n" "${INITRAMFS}"
wget -q ${INITRAMFS}
cp $(echo ${INITRAMFS}| awk -F/ '{print $NF}') ${PXE_OKD4_DIR}/cos-initramfs

printf "\t%s\n" "${ROOT_FS}"
wget -q ${ROOT_FS}
cp $(echo ${ROOT_FS}| awk -F/ '{print $NF}') ${PXE_OKD4_DIR}/cos-live-rootfs

printf "\t%s\n" "${RAW}"
wget -q ${RAW}
cp $(echo ${RAW}| awk -F/ '{print $NF}') ${WWW_OKD4_DIR}/cos.raw.xz

printf "\t%s\n" "${RAW_SIG}"
wget -q ${RAW_SIG}
cp $(echo ${RAW_SIG}| awk -F/ '{print $NF}') ${WWW_OKD4_DIR}/cos.raw.xz.sig

chown -R apache:apache ${WEB_DIR}
chmod -R 755 ${WEB_DIR}

cp openshift-install kubectl oc /usr/local/bin/
}

_mk_install()
{
printf "%s\n" "_mk_install"
if [ -f ${INSTALL_CONFIG} ]; then
    cd ${BASE_DIR}

    cp ${INSTALL_CONFIG} ${INST_DIR}/

    printf "\t%s\n" "openshift-install create manifests --dir=${INST_DIR}/"
    openshift-install create manifests --dir=${INST_DIR}/
    sed -i 's/mastersSchedulable: true/mastersSchedulable: False/' ${INST_DIR}/manifests/cluster-scheduler-02-config.yml


    printf "\t%s\n" "openshift-install create ignition-configs --dir=${INST_DIR}/"
    openshift-install create ignition-configs --dir=${INST_DIR}/

    printf "\t%s\n" "cp -R ${INST_DIR}/auth/ ${LOCAL_DIR}/"
    cp -R ${INST_DIR}/auth/ ${LOCAL_DIR}/

    cd ${INST_DIR}

    printf "\t%s\n" "cp -R * ${WWW_OKD4_DIR}/"
    cp -R * ${WWW_OKD4_DIR}/

    chown -R apache:apache ${WEB_DIR}
    chmod -R 755 ${WEB_DIR}
fi
}

# main

_build_env

_download_and_copy

_mk_install
