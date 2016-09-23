#!/usr/bin/env bash
#/home/pi/testseg.sh
#sleep 10
/home/pi/testseg.sh
sleep 2

#/home/pi/message.sh
/home/pi/countup.sh &
/home/pi/button_ctl.sh &

/home/pi/wifi_hostapd.sh start &

python /home/pi/server.py &
