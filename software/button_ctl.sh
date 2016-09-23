#!/usr/bin/env bash
#https://www.cl.cam.ac.uk/projects/raspberrypi/tutorials/robot/buttons_and_switches/
#https://www.raspberrypi.org/forums/viewtopic.php?f=63&t=136193
# post: what worked was no physical resistors. Also pull_down in rpi works for shit
# so we changed the schematic with gnd on button input, and a rpi internal pullup
# on gpio which is connected to button output directly

EDGE=3
INNER=2
PAUSE=$EDGE
RESET=$INNER

STATEFILE="/home/pi/state.txt"
CURRENTSTATE=$(cat $STATEFILE)

button() {
  pin=$1
  gpio -g mode $pin in # make sure pin is configured as an input
  sleep 0.2
  gpio -g mode $pin up # enable pull-up resistor
  # gpio -g mode $pin down

  while :; do
      gpio -g wfi $pin falling # wait for a falling-edge
    #   gpio -g wfi $pin rising # wait for a falling-edge
    echo $pin
    sleep 0.6 # debounce
  done
}

while :; do
  read numbut
  CURSTATE=$(cat $STATEFILE)
  if [ $numbut -eq $PAUSE ]; then
    echo Button PAUSE was pressed
    if [ "$CURSTATE" == "GO" ]; then
        echo "PAUSE" > $STATEFILE
    else
        echo "GO" > $STATEFILE
    fi
  elif [ $numbut -eq $RESET ]; then
    echo Button RESET was pressed
    echo "RESET" > $STATEFILE
  fi
done < <( button $PAUSE & button $RESET & )
