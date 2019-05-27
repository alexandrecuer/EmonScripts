# --------------------------------------------------------------------------------
# RaspberryPi Strech Build Script
# Emoncms, Emoncms Modules, EmonHub & dependencies
#
# Tested with: Raspbian Strech
# Date: 19 March 2019
#
# Status: Work in Progress
# --------------------------------------------------------------------------------

# Review splitting this up into seperate scripts
# - emoncms installer
# - emonhub installer
# Format as documentation

#!/bin/bash
source config.ini

echo "-------------------------------------------------------------"
echo "EmonSD Install"
echo "-------------------------------------------------------------"

if [ "$apt_get_upgrade_and_clean" = true ]; then
    echo "apt-get update"
    sudo apt-get update -y
    echo "-------------------------------------------------------------"
    echo "apt-get upgrade"
    sudo apt-get upgrade -y
    echo "-------------------------------------------------------------"
    echo "apt-get dist-upgrade"
    sudo apt-get dist-upgrade -y
    echo "-------------------------------------------------------------"
    echo "apt-get clean"
    sudo apt-get clean

    # Needed on stock raspbian lite 19th March 2019
    sudo apt --fix-broken install
fi

echo "-------------------------------------------------------------"
sudo apt-get install -y git build-essential python-pip python-dev gettext
echo "-------------------------------------------------------------"

echo "Machine is $platform"
echo "emonSD_pi_env value is $emonSD_pi_env"
echo "php version going to be installed is $php_version"
echo "php packets are $php_core $php_lib $php_db $php_pkts"
echo "emoncms git is ${git_repo[emoncms_core]}"
echo "The following packages will be installed :"
(echo "NAME GIT_URL"
for module in ${!git_repo[@]}; do
  echo "$module ${git_repo[$module]}"
done) | column -t

echo "If all is fine, press any key to continue"
while [ true ] ; do
read -t 3 -n 1
if [ $? = 0 ] ; then
break;
fi
done


if [ "$install_apache" = true ]; then $usrdir/EmonScripts/install/apache.sh; fi
if [ "$install_mysql" = true ]; then $usrdir/EmonScripts/install/mysql.sh; fi
if [ "$install_php" = true ]; then $usrdir/EmonScripts/install/php.sh; fi
if [ "$install_redis" = true ]; then $usrdir/EmonScripts/install/redis.sh; fi
if [ "$install_mosquitto" = true ]; then $usrdir/EmonScripts/install/mosquitto.sh; fi
if [ "$install_emoncms_core" = true ]; then $usrdir/EmonScripts/install/emoncms_core.sh; fi
if [ "$install_emoncms_modules" = true ]; then $usrdir/EmonScripts/install/emoncms_modules.sh; fi
if [ "$install_emonhub" = true ]; then $usrdir/EmonScripts/install/emonhub.sh; fi

if [ "$emonSD_pi_env" = "1" ]; then
    if [ "$install_firmware" = true ]; then $usrdir/EmonScripts/install/firmware.sh; fi
    if [ "$install_emonpilcd" = true ]; then $usrdir/EmonScripts/install/emonpilcd.sh; fi
    if [ "$install_wifiap" = true ]; then $usrdir/EmonScripts/install/wifiap.sh; fi
    if [ "$install_emonsd" = true ]; then $usrdir/EmonScripts/install/emonsd.sh; fi

    # Enable service-runner update
    # update checks for image type and only runs with a valid image name file in the boot partition
    sudo touch /boot/emonSD-30Oct18
    exit 0
    # Reboot to complete
    sudo reboot
fi
