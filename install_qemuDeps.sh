#!/bin/bash

# Backend
sudo apt install -y python3-venv
sudo apt install -y flex
sudo apt install -y bison

# Crypto
sudo apt install -y libgcrypt20-dev
sudo apt install -y libgnutls28-dev
sudo apt install -y libnettle8-dev

# User interface
sudo apt install -y libsdl2-dev
sudo apt install -y libsdl2-image-dev
sudo apt install -y libgtk-3-dev
sudo apt install -y libpixman-1-dev
sudo apt install -y libvte-2.91-dev
sudo apt install -y libvncserver-dev
sudo apt install -y libspice-server-dev
sudo apt install -y libncurses5-dev
sudo apt install -y libbrlapi-dev



# Audio backends
sudo apt install -y libasound2-dev
sudo apt install -y libpipewire-0.3-dev
sudo apt install -y libjack-jackd2-dev
sudo apt install -y pipewire
sudo apt install -y pipewire-audio-client-libraries
sudo apt install -y pipewire-audio-client-libraries-doc
sudo apt install -y pipewire-bin
sudo apt install -y pipewire-doc
sudo apt install -y pipewire-jack
sudo apt install -y pipewire-tests


# Network backends
sudo apt install -y libslirp-dev
sudo apt install -y libvde-dev
sudo apt install -y libtasn1-6-dev
sudo apt install -y libpam0g-dev
sudo apt install -y libcurl4-openssl-dev
sudo apt install -y libaio-dev
sudo apt install -y libibverbs-dev
sudo apt install -y libcap-ng-dev
sudo apt install -y librados-dev
sudo apt install -y libpcsclite-dev
sudo apt install -y libu2f-host-dev
sudo apt install -y libssh-dev
sudo apt install -y liblzo2-dev
sudo apt install -y libsnappy-dev
sudo apt install -y libbz2-dev
sudo apt install -y libzstd-dev
sudo apt install -y libcapstone-dev
sudo apt install -y libpmem-dev
sudo apt install -y libdaxctl-dev
sudo apt install -y libnfs-dev
sudo apt install -y libiscsi-dev
sudo apt install -y libglusterfs-dev
sudo apt install -y libseccomp-dev
sudo apt install -y libepoxy-dev
sudo apt install -y libfuse-dev

# Dependencies
sudo apt install -y libtspi-dev
sudo apt install -y libccid
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients

git clone https://github.com/lzfse/lzfse.git
cd lzfse
sudo make && make install
cd -

git clone https://gitlab.com/qemu-project/qemu.git
cd qemu
git submodule init
git submodule update --recursive
./configure
make
cd build
sudo cp qemu-arm /usr/bin/
echo "alias emulate=\"qemu-arm -L /opt/fsl-imx-x11/5.4-zeus/sysroots/cortexa9hf-neon-poky-linux-gnueabi\""  >> ~/.bashrc

