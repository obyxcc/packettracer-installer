#! /bin/bash

PTFileCheck() {
	if [ ! $(ls | grep PacketTracer*.deb | head -n 1) ]; then
		printf "\nERROR: Packet Tracer install file was not found. Please place it in the folder with this installer before trying again.\n"
	   exit
	fi
}

getDeps() {
	for ((i=0; i<${#deps[*]}; i++)); do
		if [ $(echo ${deps[i]} | grep "deb") ]; then
			echo "Grabbing ${deps[i]} ..."
			for ((x=0; x<${#mirrors[*]}; x++)); do
				echo ${mirrors[x]} | grep ${deps[i]} | xargs -I "LINK" wget -q "LINK"
			done
		else
			installDeps ${deps[i]}
		fi
	done
}

installDeps() {
	if [ $(echo $1 | grep "deb") ]; then
		echo "installing $1..."
		ls ./ | grep $1 | xargs -I "PACKAGE" apt-get -qy --allow-downgrades install ./"PACKAGE" >> /dev/null
	else
		if [ ! $(ls /bin | grep $1) ]; then
			echo "installing $1..."
			apt-get -qy install $1 >> /dev/null
		fi
	fi
}

checkSum() {
	for ((i=0; i<${#deps[*]}; i++)); do
		if [ $(echo ${deps[i]} | grep "deb") ]; then
			echo "Checking file integrity of ${deps[i]} ..."
			if [ $(shasum ${deps[i]} | shasum -c | grep -o "OK") ]; then
				installDeps ${deps[i]}
			else
			   echo "The checksum of ${deps[i]} did not match. The file may have been compromised or corrupted."
			   printf "\nWould you like to continue with this installation? "
			   read -p "[Y/N] " continueInvalid
			   case $continueInvalid in
				   [yY]* ) installDeps ${deps[i]}
					   break;;
				   [nN]* ) rm ${deps[i]}
					   exit;;
				   * ) exit;;
			   esac
			fi
		fi
	done
}

installPT() {
	printf "\n\nInstalling Packet Tracer 7.3.0 ...\n"
	dpkg -i $(ls | grep PacketTracer*.deb | head -n 1)
}

cleanUp() {
	printf "\nCleaning up after install ...\n"
	for ((i=0; i<${#deps[*]}; i++)); do
		if [ $(echo ${deps[i]} | grep "deb") ]; then
			echo "Removing ${deps[i]} ..."
			rm ${deps[i]}
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

deps=(
	wget
	libdouble-conversion1_2.0.1-4ubuntu1_amd64.deb
	qt-at-spi_0.4.0-3_amd64.deb
)

mirrors=(
	http://mirrors.kernel.org/ubuntu/pool/main/d/double-conversion/libdouble-conversion1_2.0.1-4ubuntu1_amd64.deb
	http://mirrors.kernel.org/ubuntu/pool/main/q/qt-at-spi/qt-at-spi_0.4.0-3_amd64.deb
)

if [ `whoami` != root ]; then
    echo "Please run this script as root or using sudo"
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
	   checkSum
	   installPT
	   cleanUp
	   checkInstalled
	;;
   [nN]* ) exit;;
   * ) exit;;
esac
