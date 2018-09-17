#!/bin/bash
################################################################################
# Original Author:   crombiecrunch
# Fork Author: manfromafar
# Current Author: Tanariel
# Web:     
#
# Program:
#   Install yiimp on Ubuntu 16.04 running Nginx, MariaDB, and php7.x
# 
# 
################################################################################
output() {
    printf "\E[0;33;40m"
    echo $1
    printf "\E[0m"
}

displayErr() {
    echo
    echo $1;
    echo
    exit 1;
}

    output " "
    output "Make sure you double check before hitting enter! Only one shot at these!"
    output " "
    read -e -p "Enter time zone (e.g. America/New_York) : " TIME
    read -e -p "Enter your block notify password  (required) : " blckntifypass
    read -e -p "Server name (no http:// just stratum-us.example.com) : " server_name
    read -e -p "Set stratum to AutoExchange? i.e. mine any coinf with BTC address? [y/N] : " BTC
    read -e -p "Enter the sql server ip address : " MYSQLIP
    read -e -p "Enter the sql server database : " MYSQLDB
    read -e -p "Enter the sql stratum username : " MYSQLUSER
    read -e -p "Enter the sql stratum password : " MYSQLPASS
    
    output " "
    output "Updating system and installing required packages."
    output " "
    sleep 3
    
    
    # update package and upgrade Ubuntu
    sudo apt-get -y update 
    sudo apt-get -y upgrade
    sudo apt-get -y autoremove
    
    output " "
    output "Switching to Aptitude"
    output " "
    sleep 3
    
    sudo apt-get -y install aptitude
    
    output " "
    output "Installing Mariadb Server."
    output " "
    sleep 3
    
    
    # create random password
    export DEBIAN_FRONTEND="noninteractive"
    sudo aptitude -y install mariadb-server
    
    output " "
    output "Installing needed files"
    output " "
    sleep 3

    sudo phpenmod mcrypt
    sudo phpenmod mbstring
    sudo aptitude -y install libgmp3-dev
    sudo aptitude -y install libmysqlclient-dev
    sudo aptitude -y install libcurl4-gnutls-dev
    sudo aptitude -y install libkrb5-dev
    sudo aptitude -y install libldap2-dev
    sudo aptitude -y install libidn11-dev
    sudo aptitude -y install gnutls-dev
    sudo aptitude -y install librtmp-dev
    sudo aptitude -y install sendmail
    sudo aptitude -y install mutt
    sudo aptitude -y install git screen
    sudo aptitude -y install pwgen -y


    #Installing Package to compile crypto currency
    output " "
    output "Installing Package to compile crypto currency"
    output " "
    sleep 3
    
    sudo aptitude -y install software-properties-common build-essential
    sudo aptitude -y install libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils git cmake libboost-all-dev zlib1g-dev libz-dev libseccomp-dev libcap-dev libminiupnpc-dev
    sudo aptitude -y install libminiupnpc10 libzmq5
    sudo aptitude -y install libcanberra-gtk-module libqrencode-dev libzmq3-dev
    sudo aptitude -y install libqt5gui5 libqt5core5a libqt5webkit5-dev libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler
    sudo add-apt-repository -y ppa:bitcoin/bitcoin
    sudo apt-get -y update
    sudo apt-get install -y libdb4.8-dev libdb4.8++-dev libdb5.3 libdb5.3++
	
    output " "
    output " "
    output " "
    output "Grabbing yiimp fron Github, building files and setting file structure."
    output " "
    sleep 3

    #Generating Random Password for stratum
    cd ~
    git clone https://github.com/tanariel/yiimp.git
    cd $HOME/yiimp/blocknotify
    sudo sed -i 's/tu8tu5/'$blckntifypass'/' blocknotify.cpp
    sudo make
    cd $HOME/yiimp/stratum/iniparser
    sudo make
    cd $HOME/yiimp/stratum
    if [[ ("$BTC" == "y" || "$BTC" == "Y") ]]; then
    sudo sed -i 's/CFLAGS += -DNO_EXCHANGE/#CFLAGS += -DNO_EXCHANGE/' $HOME/yiimp/stratum/Makefile
    sudo make
    fi
    sudo make
    cd $HOME/yiimp
    sudo mkdir -p /var/stratum
    cd $HOME/yiimp/stratum
    sudo cp -a config.sample/. /var/stratum/config
    sudo cp -r stratum /var/stratum
    sudo cp -r run.sh /var/stratum
    cd $HOME/yiimp
    sudo cp -r $HOME/yiimp/bin/. /bin/
    sudo cp -r $HOME/yiimp/blocknotify/blocknotify /usr/bin/
    sudo cp -r $HOME/yiimp/blocknotify/blocknotify /var/stratum/
    sudo mkdir -p /etc/yiimp
    sudo mkdir -p /$HOME/backup/
    #fixing yiimp
    sed -i "s|ROOTDIR=/data/yiimp|ROOTDIR=/var|g" /bin/yiimp
    #fixing run.sh
    sudo rm -r /var/stratum/config/run.sh
	echo '
#!/bin/bash
ulimit -n 10240
ulimit -u 10240
cd /var/stratum
while true; do
        ./stratum /var/stratum/config/$1
        sleep 2
done
exec bash
' | sudo -E tee /var/stratum/config/run.sh >/dev/null 2>&1
sudo chmod +x /var/stratum/config/run.sh


    output " "
    output "Update default timezone."
    output " "
    
    # check if link file
    sudo [ -L /etc/localtime ] &&  sudo unlink /etc/localtime
    
    # update time zone
    sudo ln -sf /usr/share/zoneinfo/$TIME /etc/localtime
    sudo aptitude -y install ntpdate
    
    # write time to clock.
    sudo hwclock -w

output " "
output "Updating stratum config files with database connection info."
output " "
sleep 3

cd /var/stratum/config
sudo sed -i 's/password = tu8tu5/password = '$blckntifypass'/g' *.conf
sudo sed -i 's/server = yaamp.com/server = '$server_name'/g' *.conf
sudo sed -i 's/host = yaampdb/host = '$MYSQLIP'/g' *.conf
sudo sed -i 's/database = yaamp/database = '$MYSQLDB'/g' *.conf
sudo sed -i 's/username = root/username = '$MYSQLUSER'/g' *.conf
sudo sed -i 's/password = patofpaq/password = '$MYSQLPASS'/g' *.conf
cd ~

output " "
output "Final Directory permissions"
output " "
sleep 3

whoami=`whoami`
sudo mkdir /root/backup/
sudo chown -R www-data:www-data /var/stratum
sudo chmod -R 775 /var/stratum
sudo mv $HOME/yiimp/ $HOME/yiimp-install-only-do-not-run-commands-from-this-folder

output " "
output " "
output " "
output " "
output "Whew that was fun, just some reminders. This install performed only stratum servers installation."
output " "
output "Please make sure to update and launch the stratum screen file."
output " "
output " "
