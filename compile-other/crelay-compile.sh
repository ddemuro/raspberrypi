#!/bin/bash
###########################################
#Control Relay module USB with Crelay     #
###########################################
readonly libs='libftdi1 libftdi-dev libhidapi-libusb0 libhidapi-dev libusb-1.0-0 libusb-1.0-0-dev perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python libudev-dev libusb-1.0-0-dev libftdi1 libhidapi-libusb0 libusb-1.0-0 hidapi*'
readonly install_path='/opt/raspberrypi'
readonly gitrepo='https://git@github.com:ddemuro/crelay.git'

apt-get install $libs
cd $install_path/compile-other
git clone $gitrepo
cd crelay/src
make
chmod +x crelay
mv $install_path/crelay
./crelay -d
echo "Running daemon mode, enter with Raspberry PI IP: http://ip:8000"
