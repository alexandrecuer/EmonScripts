# --------------------------------------------------------------------------------
# RaspberryPi Strech Build Script
# Emoncms, Emoncms Modules, EmonHub & dependencies
#
# Tested with: Raspbian Strech, Ubuntu18.04LTS, dietpi
# Date: 19 March 2019
#
# Status: Work in Progress
# --------------------------------------------------------------------------------

# Review splitting this up into seperate scripts
# - emoncms installer
# - emonhub installer
# Format as documentation

#!/bin/bash

#user basic interaction
#waiting for $3 chars injected in $2 var
function wait_until_key_pressed {
  printf "$1"
  while [ true ] ; do
    #read -t 3 -n $3 $2
    read -n $3 $2
    if [ $? = 0 ] ; then
      break;
    fi
    # 2 is CRL-C
    if [ $? = 2 ] ; then
      exit;
    fi
  done
}

# CHECK IF BASICS ARE ON BOARD
basics=( lsb-release git bsdmainutils )
for i in ${!basics[*]} ; do
    if [[ $(dpkg -l | grep ${basics[$i]} ) ]]
    then
      echo "${basics[$i]} package : already installed"
    else
      sudo apt-get install ${basics[$i]}
    fi
done

wait_until_key_pressed "basic packages ready - press any key to continue or ctrl-C to abort\n" "" 1

message="Do yu want to install specific scripts for the raspberry platform ?\n"
message+="0=noinstall 1=install\n"
wait_until_key_pressed "$message" user_emonSD_pi_env 1
if [[ $user_emonSD_pi_env == 1 || $user_emonSD_pi_env == 0 ]]
then
  printf "\nmodyfing config.ini with emonSD_pi_env=$user_emonSD_pi_env"
  sudo sed -i "s/^emonSD_pi_env=[0-9]/emonSD_pi_env=$user_emonSD_pi_env/" config.ini
fi

message="\nwhich php version do yu want to install ?\n"
message+="7.0 for raspberry or debian\n7.2 for ubuntu18.04\n"
wait_until_key_pressed "$message" user_php_version 3
if [[ "$user_php_version" == [0-9].[0-9] ]]
then
  printf "\nmodyfing config.ini with php_version=$user_php_version"
  sudo sed -i "s/^php_version=[0-9].[0-9]/php_version=$user_php_version/" config.ini
fi

source config.ini
echo "Machine is $os"
echo "emonSD_pi_env value is $emonSD_pi_env"
echo "php version going to be installed is $php_version"
echo "php packets are $php_core $php_lib $php_db $php_pear $php_pkts $php_mcrypt"
echo "emoncms git is ${git_repo[emoncms_core]}"
echo "The following packages will be installed :"
(echo "NAME GIT_URL GIT_BRANCH"
for module in ${!git_repo[@]}; do
  echo "$module ${git_repo[$module]} ${git_branch[$module]}"
done) | column -t

wait_until_key_pressed "press any key to continue or ctrl-C to abort\n" "" 1

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

if [ "$install_apache" = true ]; then $usrdir/EmonScripts/install/apache.sh; fi
if [ "$install_mysql" = true ]; then $usrdir/EmonScripts/install/mysql.sh; fi
if [ "$install_php" = true ]; then $usrdir/EmonScripts/install/php.sh; fi
if [ "$install_redis" = true ]; then $usrdir/EmonScripts/install/redis.sh; fi
if [ "$install_mosquitto" = true ]; then $usrdir/EmonScripts/install/mosquitto.sh; fi
if [ "$install_emoncms_core" = true ]; then $usrdir/EmonScripts/install/emoncms_core.sh; fi
if [ "$install_emoncms_modules" = true ]; then $usrdir/EmonScripts/install/emoncms_modules.sh; fi
if [ "$install_emonhub" = true ]; then $usrdir/EmonScripts/install/emonhub.sh; fi

if [ $emonSD_pi_env == 0 ]
then
  printf "you are not on a raspberry - to finish the install, run sudo systemctl edit service-runner.service\n"
  printf "this will open a blank file. Add inside the following two lines, assuming you will run the service-runner as root: \n"
  printf "[Service]\n"
  printf "User=\n"
  printf "then do sudo systemctl daemon-reload\n"
  printf "and sudo systemctl restart service-runner.service\n"
fi

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
