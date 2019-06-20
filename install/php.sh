#!/bin/bash
source config.ini

echo "-------------------------------------------------------------"
echo "Install PHP"
echo "-------------------------------------------------------------"

if [[ $php_version == "7.0" ]]
then
  php_core="${php_core//php/php$php_version}"
  php_lib="${php_lib//php/php$php_version}"
  php_db="${php_db//php/php$php_version}"
  php_pkts="${php_pkts//php/php$php_version}"
  php_mcrypt="${php_mcrypt//php/php$php_version}"
fi

sudo apt-get install -y $php_core
sudo apt-get install -y $php_pear

if [ "$install_apache" = true ]; then
    sudo apt-get install -y $php_lib
fi

if [ "$install_mysql" = true ]; then
    sudo apt-get install -y $php_db
fi

sudo apt-get install -y $php_pkts

# in case of an errored version given by the user, we check the version
# at this stage, php cli has been successfully installed
installed_php_version=$(php -r 'echo substr(phpversion(),0,3);')
if [ $php_version != $installed_php_version ]
then
  echo 'CORRECTING PHP VERSION in config.ini'
  sudo sed -i "s/^php_version=[0-9].[0-9]/php_version=$installed_php_version/" config.ini
fi

sudo pecl channel-update pecl.php.net

if [ $php_version == "7.2" ]
then
  #DEPRECATED : mcrypt is no more maintained > should use sodium
  sudo apt install -y libmcrypt-dev
  #sudo pecl channel-update pecl.php.net
  sudo pecl install mcrypt-1.0.1
  # Add mcrypt to php mods available
  printf "extension=mcrypt.so" | sudo tee /etc/php/$php_version/mods-available/mcrypt.ini 1>&2
  sudo phpenmod mcrypt
else
  sudo apt-get install -y $php_mcrypt
fi
