#!/bin/bash

# -----------------------------------------------------------------------------
# Script Name: SDK Installation and Device Setup Automation
# Author: Somnath Dutta Banik
# Date: 29th May 2024
# -----------------------------------------------------------------------------
# Description:
# This script automates the process of installing the necessary Software 
# Development Kits (SDKs) and setting up the development device for use.
# 
# The script performs the following tasks:
# 1. Downloads the required SDKs from specified sources.
# 2. Installs the SDKs on the host machine.
# 3. Configures environment variables and paths for the SDKs.
# 4. Sets up the development device, including necessary configurations
#    and permissions.
# 5. Verifies the installation and setup to ensure everything is configured 
#    correctly.
# 
# Usage:
# Run this script in a terminal with appropriate permissions (may require sudo).
# Example: sudo ./install_script.sh
# 
# Prerequisites:
# - Ensure you have an active internet connection for downloading SDKs.
# - Run the script with sufficient privileges to install software and 
#   configure the system.
# - Always ensure to run this application to run from SDK root directory
# 
# Notes:
# - Modify the script as needed to customize the SDK sources or device setup
#   steps specific to your development environment.
# - Always backup your system and important files before running automated
#   setup scripts.
# 
#	UPDATED 2nd June, 2024 - Linefeed fix for toolchains
# -----------------------------------------------------------------------------

SDKDIR=$PWD

check_checksum() {
    local md5="$1"
    local filename="$2"
    local calculated_md5

    calculated_md5=$(md5sum "$filename" | awk '{print $1}')

    if [ "$md5" = "$calculated_md5" ]; then
        echo "$filename: OK"
    else
        echo "$filename: FAILED"
        echo "SDK File(s) verification failed..."
		echo "Files Corrupted or sh file not inside the SDK folder."
        exit 1  # Abort script if checksum fails
    fi
}

verify_files() {
# Remove carriage returns from md5sum.txt if necessary
tr -d '\r' < md5sum.txt > md5sum_unix.txt

while IFS= read -r line; do
    md5=$(echo "$line" | awk '{print $1}')
    filename=$(echo "$line" | awk '{print $2}')

    check_checksum "$md5" "$filename"
done < md5sum_unix.txt
}

install_sdk() {
    echo "Extracting SDK files..."
    cat SDK.* > SDK.tar
    tar -xf SDK.tar
    cd ./SDK
    echo "Installing SDK..."
    ./fsl-imx-x11-glibc-x86_64-tempus-image-cortexa9hf-neon-toolchain-5.4-zeus.sh -y
    cd ..
    rm -rf SDK SDK.tar
}

install_dependencies() {
    echo "Installing dependencies..."
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt install -y build-essential libbluetooth-dev libudev-dev libpulse-dev uuid-dev \
                        libusb-1.0-0-dev libxml++2.6-dev libzip-dev \
                        libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
                        libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base \
                        libssl-dev libgtest-dev ninja-build cmake git snap wget gpg apt-transport-https
    #sudo snap install notepad-plus-plus
}

init_vsCode() {
	# install CPP extensions
	code --install-extension ms-vscode.cpptools-extension-pack
	code .		# open code to generate user profile
	sleep 3
	pkill -15 code
	sed -i "s/somnath/$USER/g" ~/toolchains/cmake_Cross_Compile_kit.json

	echo "{
		\"cmake.options.statusBarVisibility\": \"visible\",
		\"cmake.additionalKits\": [
		    \"/home/$USER/toolchains/cmake_Cross_Compile_kit.json\"
		]
	}" > ~/.config/Code/User/settings.json
}

install_vsCode() {
	echo "Installing Visual Studio code..."
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
	sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
	sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
	rm -f packages.microsoft.gpg
	sudo apt update -y
	sudo apt purge --remove code
	sudo snap remove code
	rm -rf /home/$USER/.vscode
	rm -rf /home/$USER/.config/Code
	sudo apt install code -y
}

install_toolchain() {
jsonfile='[
  {
    "name": "CrossCompile_TempusSDK",
    "toolchainFile": "/home/somnath/toolchains/custom_toolchain.cmake",
    "isTrusted": true
  },
  {
    "name": "Ubuntu_Linux_x86_64-linux-gnu",
    "compilers": {
      "C": "/usr/bin/gcc",
      "CXX": "/usr/bin/g++"
    },
    "isTrusted": true
  }
]'

toolchain_file='
# Custom Toolchain File Created By Somnath Dutta Banik for CrossCompilation using TempusSDKs 09-Nov-2023 .
# Do not use /opt/fsl-imx-x11/5.4-zeus/sysroots/x86_64-pokysdk-linux/usr/share/cmake/OEToolchainConfig.cmake 
# otherwise it will break the CrossCompile Feature. 
#
# Must be used with a Custom [cmake_kit_file].json 
# Example cross compile kit file would be 
# [
#	  {
#	    "name": "CrossCompile_TempusSDK",
#	    "toolchainFile": "/home/somnath/CMAKE_Cache/custom_toolchain.cmake",
#	    "isTrusted": true
#	  }
#	]
#


set( CMAKE_SYSTEM_NAME Linux )

set(ENV{SDKTARGETSYSROOT} "/opt/fsl-imx-x11/5.4-zeus/sysroots/cortexa9hf-neon-poky-linux-gnueabi")
set(ENV{PATH} "/opt/fsl-imx-x11/5.4-zeus/sysroots/x86_64-pokysdk-linux/usr/bin:/opt/fsl-imx-x11/5.4-zeus/sysroots/x86_64-pokysdk-linux/usr/sbin:/opt/fsl-imx-x11/5.4-zeus/sysroots/x86_64-pokysdk-linux/bin:/opt/fsl-imx-x11/5.4-zeus/sysroots/x86_64-pokysdk-linux/sbin:/opt/fsl-imx-x11/5.4-zeus/sysroots/x86_64-pokysdk-linux/usr/bin/../x86_64-pokysdk-linux/bin:/opt/fsl-imx-x11/5.4-zeus/sysroots/x86_64-pokysdk-linux/usr/bin/arm-poky-linux-gnueabi:/opt/fsl-imx-x11/5.4-zeus/sysroots/x86_64-pokysdk-linux/usr/bin/arm-poky-linux-musl:$ENV{PATH}")
set(ENV{PKG_CONFIG_SYSROOT_DIR} "$ENV{SDKTARGETSYSROOT}")
set(ENV{PKG_CONFIG_PATH} "$ENV{SDKTARGETSYSROOT}/usr/lib/pkgconfig:$ENV{SDKTARGETSYSROOT}/usr/share/pkgconfig")
set(ENV{CONFIG_SITE} "/opt/fsl-imx-x11/5.4-zeus/site-config-cortexa9hf-neon-poky-linux-gnueabi")
set(ENV{OECORE_NATIVE_SYSROOT} "/opt/fsl-imx-x11/5.4-zeus/sysroots/x86_64-pokysdk-linux")
set(ENV{OECORE_TARGET_SYSROOT} "$ENV{SDKTARGETSYSROOT}")
set(ENV{OECORE_ACLOCAL_OPTS} "-I $ENV{OECORE_NATIVE_SYSROOT}/usr/share/aclocal")
set(ENV{OECORE_BASELIB} "lib")
set(ENV{OECORE_TARGET_ARCH} "arm")
set(ENV{OECORE_TARGET_OS} "linux-gnueabi")
set(ENV{CC} "arm-poky-linux-gnueabi-gcc  -mfpu=neon -mfloat-abi=hard -mcpu=cortex-a9 -fno-omit-frame-pointer -mapcs -mno-sched-prolog -fno-optimize-sibling-calls --sysroot=$ENV{SDKTARGETSYSROOT}")
set(ENV{CXX} "arm-poky-linux-gnueabi-g++  -mfpu=neon -mfloat-abi=hard -mcpu=cortex-a9 -fno-omit-frame-pointer -mapcs -mno-sched-prolog -fno-optimize-sibling-calls --sysroot=$ENV{SDKTARGETSYSROOT}")
set(ENV{CPP} "arm-poky-linux-gnueabi-gcc -E  -mfpu=neon -mfloat-abi=hard -mcpu=cortex-a9 -fno-omit-frame-pointer -mapcs -mno-sched-prolog -fno-optimize-sibling-calls --sysroot=$ENV{SDKTARGETSYSROOT}")
set(ENV{AS} "arm-poky-linux-gnueabi-as")
set(ENV{LD} "arm-poky-linux-gnueabi-ld  --sysroot=$ENV{SDKTARGETSYSROOT}")
set(ENV{GDB} "arm-poky-linux-gnueabi-gdb")
set(ENV{STRIP} "arm-poky-linux-gnueabi-strip")
set(ENV{RANLIB} "arm-poky-linux-gnueabi-ranlib")
set(ENV{OBJCOPY} "arm-poky-linux-gnueabi-objcopy")
set(ENV{OBJDUMP} "arm-poky-linux-gnueabi-objdump")
set(ENV{READELF} "arm-poky-linux-gnueabi-readelf")
set(ENV{AR} "arm-poky-linux-gnueabi-ar")
set(ENV{NM} "arm-poky-linux-gnueabi-nm")
set(ENV{M4} "m4")
set(ENV{TARGET_PREFIX} "arm-poky-linux-gnueabi-")
set(ENV{CONFIGURE_FLAGS} "--target=arm-poky-linux-gnueabi --host=arm-poky-linux-gnueabi --build=x86_64-linux --with-libtool-sysroot=$ENV{SDKTARGETSYSROOT}")
set(ENV{CFLAGS} " -O2 -pipe -g -feliminate-unused-debug-types ")
set(ENV{CXXFLAGS} " -O2 -pipe -g -feliminate-unused-debug-types ")
set(ENV{LDFLAGS} "-Wl,-O1 -Wl,--hash-style=gnu -Wl,--as-needed")
set(ENV{CPPFLAGS} "")
set(ENV{KCFLAGS} "--sysroot=$ENV{SDKTARGETSYSROOT}")
set(ENV{OECORE_DISTRO_VERSION} "5.4-zeus")
set(ENV{OECORE_SDK_VERSION} "5.4-zeus")
set(ENV{ARCH} "arm")
set(ENV{CROSS_COMPILE} "arm-poky-linux-gnueabi-")

#change added for QT5	16-DEC-2023
# Add the toolchain bin directory to the PATH
set(PATH "$ENV{OECORE_NATIVE_SYSROOT}/usr/bin" CACHE INTERNAL "Path to toolchain binaries")
set(PATH "${PATH};$ENV{PATH}")
set(ENV{PATH} "${PATH}")
# Set other variables
set(OE_QMAKE_CFLAGS "$ENV{CFLAGS}")
set(OE_QMAKE_CXXFLAGS "$ENV{CXXFLAGS}")
set(OE_QMAKE_LDFLAGS "$ENV{LDFLAGS}")
set(OE_QMAKE_CC "$ENV{CC}")
set(OE_QMAKE_CXX "$ENV{CXX}")
set(OE_QMAKE_LINK "$ENV{CXX}")
set(OE_QMAKE_AR "$ENV{AR}")
set(OE_QMAKE_STRIP "$ENV{STRIP}")
set(QT_CONF_PATH "$ENV{OECORE_NATIVE_SYSROOT}/usr/bin/qt.conf")
set(OE_QMAKE_LIBDIR_QT "$ENV{OE_QMAKE_LIBDIR_QT}")
set(OE_QMAKE_INCDIR_QT "$ENV{OE_QMAKE_INCDIR_QT}")
set(OE_QMAKE_MOC "$ENV{OECORE_NATIVE_SYSROOT}/usr/bin/moc")
set(OE_QMAKE_UIC "$ENV{OECORE_NATIVE_SYSROOT}/usr/bin/uic")
set(OE_QMAKE_RCC "$ENV{OECORE_NATIVE_SYSROOT}/usr/bin/rcc")
set(OE_QMAKE_QDBUSCPP2XML "$ENV{OECORE_NATIVE_SYSROOT}/usr/bin/qdbuscpp2xml")
set(OE_QMAKE_QDBUSXML2CPP "$ENV{OECORE_NATIVE_SYSROOT}/usr/bin/qdbusxml2cpp")
set(OE_QMAKE_QT_CONFIG "$ENV{OE_QMAKE_QT_CONFIG}")
set(OE_QMAKE_PATH_HOST_BINS "$ENV{OECORE_NATIVE_SYSROOT}/usr/bin")	
set(OE_QMAKE_PATH_EXTERNAL_HOST_BINS "$ENV{OECORE_NATIVE_SYSROOT}/usr/bin")
set(QMAKESPEC "$ENV{QT_INSTALL_LIBS}/mkspecs/linux-oe-g++")

# Set OPENSSL_CONF variable
set(OPENSSL_CONF "$ENV{OECORE_NATIVE_SYSROOT}/usr/lib/ssl-1.1/openssl.cnf" CACHE INTERNAL "Path to OpenSSL configuration file")


#end change for QT5	16-DEC-2023


set( CMAKE_C_FLAGS $ENV{CFLAGS} CACHE STRING "" FORCE )
set( CMAKE_CXX_FLAGS $ENV{CXXFLAGS}  CACHE STRING "" FORCE )
set( CMAKE_ASM_FLAGS ${CMAKE_C_FLAGS} CACHE STRING "" FORCE )
set( CMAKE_LDFLAGS_FLAGS ${CMAKE_CXX_FLAGS} CACHE STRING "" FORCE )
set( CMAKE_SYSROOT $ENV{OECORE_TARGET_SYSROOT} )

set( CMAKE_FIND_ROOT_PATH $ENV{OECORE_TARGET_SYSROOT} )
set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY )

set(CMAKE_FIND_LIBRARY_CUSTOM_LIB_SUFFIX "$ENV{OE_CMAKE_FIND_LIBRARY_CUSTOM_LIB_SUFFIX}")

# Set CMAKE_SYSTEM_PROCESSOR from the sysroot name (assuming processor-distro-os).
if ($ENV{SDKTARGETSYSROOT} MATCHES "/sysroots/([a-zA-Z0-9_-]+)-.+-.+")
  set(CMAKE_SYSTEM_PROCESSOR ${CMAKE_MATCH_1})
endif()

'



cd ~
mkdir toolchains
cd toolchains
cat << EOF > cmake_Cross_Compile_kit.json
$jsonfile
EOF
cat << EOF > custom_toolchain.cmake
$toolchain_file 
EOF
cd -
}

get_codebase() {
    sudo apt install -y git
    git config --global credential.helper store
	read -p "Enter username (default: Mindteck-Somnath): " username
    username=${username:-Mindteck-Somnath}

    # Prompt the user for passkey without showing it on the screen
    echo -n "Enter passkey (default: default_passkey): "
    stty -echo
    read passkey
    stty echo
    echo

    passkey=${passkey:-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}

    # Generate .git-credentials file
    cat << EOF > .git-credentials
https://${username}:${passkey}@github.com
EOF
    mv .git-credentials ~/.git-credentials

    echo "Git credentials generated in .git-credentials file."
	cd ~
	mkdir MindteckProjects
	cd MindteckProjects
	git clone https://github.com/philips-internal/TempusPro-App.git
	rm -f ~/.git-credentials ~/.gitconfig
	cd $SDKDIR
}

open_codebase() {
	echo "Opening Installed Codebase..."
	sleep 3
	cd ~/MindteckProjects/TempusPro-App/Linux/Code/Source
	code .
	echo "Installation Completed..."
	echo "Find your codebase at location /home/$USER/MindteckProjects/"
}


verify_files
get_codebase
install_sdk
install_dependencies
install_toolchain
install_vsCode
init_vsCode
open_codebase

