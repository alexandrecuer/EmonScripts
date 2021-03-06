#!/bin/bash
source load_config.sh

echo "-------------------------------------------------------------"
echo "EmonPi Firmware Update"
echo "-------------------------------------------------------------"

sudo systemctl stop emonhub

echo "Start ATmega328 serial upload using avrdude with latest.hex"

echo "Discrete Sampling"

echo "avrdude -c arduino -p ATMEGA328P -P /dev/ttyAMA0 -b 115200 -U flash:w:$openenergymonitor_dir/emonpi/firmware/compiled/latest.hex"

avrdude -c arduino -p ATMEGA328P -P /dev/ttyAMA0 -b 115200 -U flash:w:$openenergymonitor_dir/emonpi/firmware/compiled/latest.hex

sudo systemctl start emonhub

echo "-------------------------------------------------------------"
echo "EmonPi LCD Update"
echo "-------------------------------------------------------------"
cd $openenergymonitor_dir/emonpi
git pull
if [ -f $openenergymonitor_dir/emonpi/lcd/install.sh ]; then
    $openenergymonitor_dir/emonpi/lcd/./install.sh
fi
