#!/bin/bash
source config.ini

echo "-------------------------------------------------------------"
echo "Install PHP"
echo "-------------------------------------------------------------"

sudo apt-get install -y $php_core

if [ "$install_apache" = true ]; then
    sudo apt-get install -y $php_lib
fi

if [ "$install_mysql" = true ]; then
    sudo apt-get install -y $php_db
fi

sudo apt-get install -y $php_pkts

sudo pecl channel-update pecl.php.net

if [ "$platform" = "ubuntu" ]
then
  sudo apt install -y libmcrypt-dev
  #sudo pecl channel-update pecl.php.net
  sudo pecl install mcrypt-1.0.1
  # Add mcrypt to php mods available
  printf "extension=mcrypt.so" | sudo tee /etc/php/$php_version/mods-available/mcrypt.ini 1>&2
  sudo phpenmod mcrypt
else
  sudo apt-get install -y $php_mcrypt
fi
