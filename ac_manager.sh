#!/bin/bash
###############################################################################
# This script is to manage AC configuration
################################################################################
# You may need to change the paths to the commands listed below, If you're
# using Debian, there's no need to change this (as of Debian 7 and probably
# forever).
readonly CMD_LOG="/usr/bin/logger -s -t $0"
# The Time-To-Sleep is the time (in seconds) the script will wait before
# starting over with the checks.
readonly tts='10'
readonly ac_state='/opt/scripts/ac_on'
readonly ac_tmp='/opt/scripts/ac_tmp'
readonly max_temp=31
readonly min_temp=16
################################################################################
# AUXILIARY FUNCTIONS
################################################################################
# log <message>
# Writes <message> to the system log, using the script name as the tag.
function log()
{
    $CMD_LOG "$1"
    echo "$1" >> ac_actions.log
}

function ac_on()
{
  if [ ! -f $ac_state ]; then
    log "[INFO] Air conditioning started."
    echo "on" > $ac_state
    irsend SEND_ONCE ac KEY_POWER
  else
    log "[ERR] Air conditioning already on..."
  fi
}

function ac_off()
{
  log "[INFO] Air conditioning off."
  if [ -f $ac_state ];
  then
    irsend SEND_ONCE ac KEY_POWER
    rm $ac_state
    rm $ac_tmp
  else
    log "[ERR] Air conditioning already off..."
  fi
}

function temp_up()
{
  temp=$((cat $ac_tmp))
  irsend SEND_ONCE ac KEY_VOLUMEUP
  echo $(($temp + 1)) > $ac_tmp
}

function temp_down()
{
  temp=$((cat $ac_tmp))
  irsend SEND_ONCE ac KEY_VOLUMEDOWN
  echo $(($temp - 1)) > $ac_tmp
}

function set_temp()
{
  log "[INFO] Resetting temperature"
  t=$max_temp
  while [ $t -gt $min_temp ];
  do
    irsend SEND_ONCE ac KEY_VOLUMEDOWN
    sleep 1
    t=$(($t - 1))
  done
  if [ -f $ac_state ];
  then
    if [ -f $ac_tmp ];
    then
      temp=$((cat $ac_tmp))
      log "[INFO] Air conditioning temperature set to: $1, actual temperature set: $temp"
      if [ $temp -gt $1 ];
      then
        while [ $temp -gt $1 ];
        do
          irsend SEND_ONCE ac KEY_VOLUMEDOWN
          temp=$(($temp - 1))
        done
        echo $1 > ac_tmp
      else
        while [ $temp -lt $1 ];
        do
          irsend SEND_ONCE ac KEY_VOLUMEUP
          temp=$(($temp + 1))
        done
        echo $1 > ac_tmp
      fi
    else
      log "[INFO] Air conditioning temperature set to: $1"
      while [ $temp -lt $1 ];
      do
        irsend SEND_ONCE ac KEY_VOLUMEUP
        temp=$(($temp + 1))
      done
      echo $1 > ac_tmp
    fi
  else
    log "[ERR] Air conditioner is off!."
  fi
}

timestamp() {
  date +"%T"
}

################################################################################
# SCRIPT EXECUTION
################################################################################
echo "Welcome to air conditioner manager 1.1, select option"
PS3='Please enter your choice: '
options=("On" "Off" "LT" "UT" "ST" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "On")
        ac_on
            ;;
        "Off")
        ac_off
            ;;
        "LT")
        temp_down
            ;;
        "UT")
        temp_up
            ;;
        "ST")
        set_temp $1
            ;;
        "Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done

