#!/usr/bin/python
import os, re
import sys
import math
import time
import subprocess
import smtplib
 
#from email.mime.image import MIMEImage
from email import encoders
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email.MIMEText import MIMEText

################# EMAIL    ###############
SMTP_SERVER = 'smtp.gmail.com'
SMTP_PORT = 587
SENDER = '###########'
PASSWORD = "############"
RECIPIENT = "##############"
##########################################
################## GENERAL ###############
DEFINED_LOCATION_NAME = "ALARMA HELADERA"
DEFINED_TIME_SLEEP = 5
DEFINED_TIME_SLEEP_ERROR = 20

DEFINED_HIGH_ALARM_TEMP = 35
DEFINED_LOW_ALARM_TEMP = -30

DEFINED_HIGH_ALARM_HUMID = 80
DEFINED_LOW_ALARM_HUMID = 10

def main():
    while(True):
        (status, out, err) = execute(["/opt/scripts/dht11/dht11c", "-MJ"])
        print "Status %s  Out %s Error %s" % (status, out, err)
        while out != "Error":
            mesaure = out.split(" ")
            humidity = math.fabs(float(mesaure[0]))
            temp = math.fabs(float(mesaure[1]))
            if temp >= DEFINED_HIGH_ALARM_TEMP or temp <= DEFINED_LOW_ALARM_TEMP:
                subj = "Alarma desde %s, temperatura fuera de rangos designados. Temp: %s" % (DEFINED_LOCATION_NAME, temp)
                msg = "Alarma lanzada desde %s, temperatura detectada fuera de rango... Temperatura actual: %s, Humedad: %s" % (DEFINED_LOCATION_NAME, temp, humidity)
                sendmail(RECIPIENT, subj, msg)
                time.sleep(DEFINED_TIME_SLEEP_ERROR * 60)
            if humidity >= DEFINED_HIGH_ALARM_HUMID or humidity <= DEFINED_LOW_ALARM_HUMID:
                subj = "Alarma desde %s, humedad fuera de rangos designados. Humedad: %s" % (DEFINED_LOCATION_NAME, humidity)
                msg = "Alarma lanzada desde %s, humedad detectada fuera de rango... Temperatura actual: %s, Humedad: %s" % (DEFINED_LOCATION_NAME, temp, humidity)
                sendmail(RECIPIENT, subj, msg)
            print " Humedad actual: %s, Temperatura actual: %s" % (humidity, temp)
            time.sleep(DEFINED_TIME_SLEEP * 60)
        print "Exiting"
    return None


def execute(command, stdinpipe=None):
    child = subprocess.Popen(command,
        shell=False,
        stdin=stdinpipe,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        close_fds=True)
    out, err = child.communicate(input)
    status = child.returncode
    return status, out, err

def sendmail(recipient, subject, message, afile=None):
    msg = MIMEMultipart()
    msg['Subject'] = subject
    msg['To'] = recipient
    msg['From'] = SENDER
    
    
    part = MIMEText('text', "plain")
    part.set_payload(message)
    msg.attach(part)
    
    session = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
 
    session.ehlo()
    session.starttls()
    session.ehlo
    
    session.login(SENDER, PASSWORD)

    if afile is not None:
        fp = open(afile, 'rb')
        msgq = MIMEBase('audio', 'audio')
        msgq.set_payload(fp.read())
        fp.close()
        # Encode the payload using Base64
        encoders.encode_base64(msgq)
        # Set the filename parameter
        filename = afile
        msgq.add_header('Content-Disposition', 'attachment', filename = filename)
        msg.attach(msgq)
    # Now send or store the message
    qwertyuiop = msg.as_string()



    session.sendmail(SENDER, recipient, qwertyuiop)
    
    session.quit()
    os.system('notify-send "Email sent"')
 
if __name__ == '__main__':
    #python send.py "receiver@gmail.com" "My Topic" "My text" "My attachment.jpg"
    main()
