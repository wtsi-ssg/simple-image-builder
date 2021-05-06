#!/bin/bash

install()
{
apt-get update
apt-get install -y \
    build-essential \
    libssl-dev \
    uuid-dev \
    libgpgme11-dev \
    squashfs-tools \
    libseccomp-dev \
    wget \
    pkg-config \
    git \
    cryptsetup

# Install go
export VERSION=1.14.12 OS=linux ARCH=amd64 && \  # Replace the values as needed
  wget https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz && \ # Downloads the required Go package
  sudo tar -C /usr/local -xzf go$VERSION.$OS-$ARCH.tar.gz && \ # Extracts the archive
  rm go$VERSION.$OS-$ARCH.tar.gz   

cd /root
# Down load singularity
export VERSION=3.7.0 && # adjust this as necessary \
    wget https://github.com/hpcng/singularity/releases/download/v${VERSION}/singularity-${VERSION}.tar.gz && \
    tar -xzf singularity-${VERSION}.tar.gz && \
    cd singularity

export PATH=/usr/local/go/bin:$PATH

./mconfig && \
    make -C builddir && \
    make -C builddir install
}

if [ -z "$CONTAINER" ] ; then
	echo "Skipping as CONTAINER not defined"
	exit 0
fi

PLATFORM=$(python2 -mplatform | sed -e 's/.*focal.*/focal/i' -e 's/.*centos.*/centos/i' -e 's/.*xenial.*/xenial/i' -e 's/.*bionic.*/bionic/i')
case ${PLATFORM} in
        bionic)
                install
                ;;
esac

