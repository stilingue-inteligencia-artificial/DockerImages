#!/bin/bash
cat /etc/os-release
set -xe
if [ -f /etc/debian_version ] ; then
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    if [ "$INSTALL_DOCKER" = "true" ]; then
        curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
        apt-get update
        apt-get install -y docker-ce docker-ce-cli containerd.io
    fi
elif [ -f /etc/redhat-release ] ; then
    #Expecting oraclelinux 8 on some maven images
    microdnf install -y curl git
    if [ "$INSTALL_DOCKER" = "true" ]; then
        microdnf install -y dnf dnf-utils
        dnf clean all
        dnf repolist
        dnf update -y --releasever=8
        dnf install -y dnf-utils zip unzip
        dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
        dnf install -y docker-ce --nobest
        rm -r /var/cache/dnf
        dnf clean all
    fi
fi

if [ "$INSTALL_GCLOUD" = "true" ]; then
    curl -O "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-$CLOUD_SDK_VERSION-linux-x86_64.tar.gz"
    tar -xzf "google-cloud-sdk-$CLOUD_SDK_VERSION-linux-x86_64.tar.gz" -C /opt/
    /opt/google-cloud-sdk/install.sh -q --path-update true --additional-components beta
    # Gcloud emulators need project id to be set even if it doesn't exist or is unreachable
    /opt/google-cloud-sdk/bin/gcloud config set project fake-project-id
    if [ "$INSTALL_GCLOUD_EMULATOR" = "true" ]; then
        /opt/google-cloud-sdk/bin/gcloud components install -q cloud-datastore-emulator cloud-firestore-emulator pubsub-emulator
    fi
    ln -s /opt/google-cloud-sdk/bin/* /usr/local/bin/
fi
