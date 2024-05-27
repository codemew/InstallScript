sudo apt-get update
sudo apt-get upgrade
sudo apt install -y build-essential
sudo apt-get -y install libbluetooth-dev
sudo apt-get -y install libudev-dev
sudo apt-get -y install libpulse-dev
sudo apt-get -y install uuid-dev
sudo apt-get -y install libusb-1.0-0-dev
sudo apt-get -y install libxml++2.6-dev 
sudo apt-get -y install libzip-dev
sudo apt-get -y install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base
sudo apt install -y libssl-dev
sudo apt install -y libgtest-dev
sudo apt install -y ninja-build cmake git
sudo apt-get install -y wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt -y install apt-transport-https
sudo apt -y update
sudo apt -y install code
code --install-extension ms-vscode.cpptools-extension-pack
cd ~
git clone https://github.com/codemew/toolchains.git
cd ~/toolchains
sh initCode.sh
cd ~
mkdir MindteckProjects
cd MindteckProjects
git clone https://github.com/philips-internal/TempusPro-App.git
cd ~/MindteckProjects/TempusPro-App/Linux/Code/Source
code .
