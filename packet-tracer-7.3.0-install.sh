#! /bin/bash

PTFileCheck() {
	if [ ! $(ls | grep PacketTracer*.deb | head -n 1) ]; then
		printf "\nERROR: Packet Tracer install file was not found. Please place it in the folder with this installer before trying again.\n"
	   exit
	fi
}

getDeps() {
	for ((i=0; i<${#mirrors[*]}; i++)); do
		echo "Grabbing ${mirrors[i]} ..."
		wget -q ${mirrors[i]}
	done
}

installDeps() {
	if [ $(ls ./  | grep "$1") ]; then
		echo "installing $1 ..."
		ls ./ | grep $1 | xargs -I "PACKAGE" apt-get -qy --allow-downgrades install ./"PACKAGE" >> /dev/null
	else
		if [ ! $(ls /bin | grep $1) ]; then
			echo "installing $1 ..."
			apt-get -qy install $1 >> /dev/null
		fi
	fi
}

installPT() {
	printf "\n\nInstalling Packet Tracer 7.3.0 ...\n"
	dpkg -i $(ls | grep PacketTracer*.deb | head -n 1)
}

cleanUp() {
	printf "\nCleaning up after install ...\n"
	for ((i=0; i<${#deps[*]}; i++)); do
		if [ $(ls ./  | grep ${deps[i]}) ]; then
			echo "Removing ${deps[i]} ..."
			rm $(ls ./  | grep ${deps[i]})
		fi
	done
}

checkInstalled() {
	if [ $(ls /opt/pt/ | grep packettracer) ]; then
		printf "\nInstallation should now be complete. Enjoy using Packet Tracer 7.3.0!\n"
	else
		printf "\nSomething went wrong during the installation and the program was not installed.\n"
	fi
}

<< COMMENT
Below is where you can place additional dependencies.
Be sure to use the correct name of the package and if
it needs to be downloaded from an outside source, place
it's download link in the "mirrors" array.

Thank you Cisco for forcing me to create a tool that will let
people use your product on GNU/Linux operating systems.
COMMENT

deps=(
	wget
	libnss3
	libxslt1
	libqt5webkit5
	libdouble-conversion1
	qt-at-spi
	libjpeg-turbo8
	libicu60
	libssl1.0.0
)

mirrors=(
	http://mirrors.kernel.org/ubuntu/pool/main/d/double-conversion/libdouble-conversion1_2.0.1-4ubuntu1_amd64.deb
	http://mirrors.kernel.org/ubuntu/pool/main/q/qt-at-spi/qt-at-spi_0.4.0-3_amd64.deb
	http://security.ubuntu.com/ubuntu/pool/main/libj/libjpeg-turbo/libjpeg-turbo8_1.4.2-0ubuntu3.3_amd64.deb
	http://mirrors.kernel.org/ubuntu/pool/main/i/icu/libicu60_60.2-3ubuntu3_amd64.deb
	http://security.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.0.0_1.0.2g-1ubuntu4.15_amd64.deb
)

if [ `whoami` != root ]; then
    echo "Please run this script as root or using sudo."
    exit
fi

printf "
##################################################
#                                                #
#  Welcome to the Packet Tracer 7.3.0 Installer  #
#                                                #
##################################################\n"

printf "\nPlease visit the following link and download Packet Tracer for Linux:
\n          https://www.netacad.com/         \n
Place it in the folder where you are running this installer before continuing.\n"
printf "\nAre you ready to continue? "
read -p "[Y/N] " readyToInstall

case $readyToInstall in
   [yY]* )
	   PTFileCheck
	   getDeps
		 for ((i=0; i<${#deps[*]}; i++)); do
			 installDeps ${deps[i]}
		 done
	   installPT
	   cleanUp
	   checkInstalled
		 ;;
   [nN]* ) exit;;
   * ) exit;;
esac
