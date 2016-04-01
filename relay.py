import RPi.GPIO as GPIO ## Import GPIO library
#GPIO.setmode(GPIO.BOARD) ## Use board pin numbering
GPIO.setmode(GPIO.BCM) 
gpio = [2,3,4,17,27,22,10,9,11,5,6,13,19,26,14,15,18,23,24,25,8,7,12,16,20,21]
for i in gpio:                         # loop through leds flashing each for 0.1s  
    GPIO.setup(i, GPIO.OUT, initial=0) # sets i to output and 0V, off   
    GPIO.output(i, 1)    # sets port on 
