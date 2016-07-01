#!/bin/bash
###############################################################################
# SCRIPT CONFIGURATION
################################################################################
# You may need to change the paths to the commands listed below, If you're
# using Debian, there's no need to change this (as of Debian 7 and probably
# forever).
readonly CMD_LOG="/usr/bin/logger -s -t $0"
readonly TMP_READ="/opt/scripts/dht11c_temp.py"
readonly HDTY_READ="/opt/scripts/dht11c_humidity.py"
# The Time-To-Sleep is the time (in seconds) the script will wait before
# starting over with the checks.
readonly tts='10'
# When only the secondary server is running, the script can get very spammy with
# your logs. The following value limits these messages to a multiple of the
# 'tts' value specified above. With the 'tts' default value of '10', an
# 'antiSpam_limit' value of '60' will limit these message to one every 10
# minutes.
readonly antiSpam_limit='60'
################################################################################
# AUXILIARY FUNCTIONS
################################################################################
# log <message>
# Writes <message> to the system log, using the script name as the tag.
function log()
{
    $CMD_LOG "$1"
    echo "$1" >> tempAmbientLog.log
}

timestamp() {
  date +"%T"
}

################################################################################
# SCRIPT EXECUTION
################################################################################
log "[INFO] Temperature Monitor started."
lastCheck=9
echo $$ > /tmp/tempMonitor.pid
while [ true ]
do
    temp=(`$TMP_READ`)
    humid=(`$HDTY_READ`)
    #echo $temp
    #echo $humid
    timestamp=$(date --rfc-3339=seconds)    
    if [ "$temp" -le 24 ]
    then
        if [ "$lastCheck" -gt 0 ]
        then
            log "AC Seems to be running just fine. $timestamp at temperature: $temp"
	    log "AC Seems to be running just fine. $timestamp at humidity: $humid"
	    lastCheck=0
        fi
    else
        if [ "$temp" -ge 26 ] && [ "$temp" -le 100 ]
        then
	        if [ "$lastCheck" -ne 1 ]
	        then
	            
		        log "[WARN] AC has gone down $timestamp at temperature: $temp!"
			log "[WARN] AC has gone down $timestamp at humidity: $humid!"
			lastCheck=1
	        fi
        fi
    fi
    if [ "$temp" -ge 30 ] && [ "$temp" -le 100 ]
    then
        log "[ALERT] AIR CONDITIONING FAILURE! TEMPERATURE: $temp at $timestamp!"
	mailx -s "[ALERT] AIR CONDITIONING FAILURE! TEMPERATURE: $humid at $timestamp!" < /dev/null "mail@derekdemuro.com"
    fi
    if [ "$humid" -ge 80 ] && [ "$humid" -le 100 ] && [ "$humid" -ge 0 ]
    then
        log "[ALERT] AIR CONDITIONING FAILURE! HUMIDITY AT OR GREATER THAN 80%: $humid at $timestamp!"
        mailx -s "[ALERT] AIR CONDITIONING FAILURE! HUMIDITY AT OR GREATER THAN 80%: $humid at $timestamp!" < /dev/null "mail@derekdemuro.com"
    fi

    sleep "$tts"
done

