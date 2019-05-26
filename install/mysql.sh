#!/bin/bash
source config.ini

echo "-------------------------------------------------------------"
echo "Setup the Mariadb server (MYSQL)"
echo "-------------------------------------------------------------"
if [ "$platform" = "ubuntu" ]
then
  sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
  sudo add-apt-repository 'deb [arch=amd64] http://mirror.zol.co.zw/mariadb/repo/10.3/ubuntu bionic main'
fi

sudo apt-get install -y mariadb-server mysql-client

# Secure mysql
echo "- Secure MYSQL"
sudo mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'); DELETE FROM mysql.user WHERE User=''; DROP DATABASE IF EXISTS test; DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'; FLUSH PRIVILEGES;"
# Create the emoncms database using utf8 character decoding:
echo "- Create $mysql_database database"
sudo mysql -e "CREATE DATABASE $mysql_database DEFAULT CHARACTER SET utf8;"
# Add emoncms database, set user permissions
echo "- Add user:$mysql_user and assign to database:$mysql_database"
sudo mysql -e "CREATE USER '$mysql_user'@'localhost' IDENTIFIED BY '$mysql_password'; GRANT ALL ON $mysql_database.* TO '$mysql_user'@'localhost'; flush privileges;"
