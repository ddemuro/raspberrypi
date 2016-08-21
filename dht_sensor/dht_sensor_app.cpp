/*
 *  dht11.c:
 *      Simple test program to test the wiringPi functions
 *      DHT11 test
 */

#include <wiringPi.h>

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/xattr.h>
#include <string>
#include <iostream>
#include <fstream>

#define MAXTIMINGS      85
#define PARAM_ASSIGN_ERROR 22
int dht11_dat[5] = { 0, 0, 0, 0, 0 };

void read_dht11_dat(int DHTPIN, bool MACHINE_READABLE, bool SKIP, bool DEBUG, int DHVER)
{
    uint8_t laststate       = HIGH;
    uint8_t counter         = 0;
    uint8_t j               = 0, i;
    float   f; /* fahrenheit */

    dht11_dat[0] = dht11_dat[1] = dht11_dat[2] = dht11_dat[3] = dht11_dat[4] = 0;

    /* pull pin down for 18 milliseconds */
    pinMode( DHTPIN, OUTPUT );
    digitalWrite( DHTPIN, LOW );
    delay( 18 );
    /* then pull it up for 40 microseconds */
    digitalWrite( DHTPIN, HIGH );
    delayMicroseconds( 40 );
    /* prepare to read the pin */
    pinMode( DHTPIN, INPUT );

    /* detect change and read data */
    for ( i = 0; i < MAXTIMINGS; i++ )
    {
        counter = 0;
        while ( digitalRead( DHTPIN ) == laststate )
        {
            counter++;
            delayMicroseconds( 1 );
            if ( counter == 255 )
            {
                    break;
            }
        }
        laststate = digitalRead( DHTPIN );

        // Print stream of data to terminal.
        if (DEBUG){
            printf("%d ", laststate);
        }

        if ( counter == 255 )
            break;

        /* ignore first 3 transitions */
        if ( (i >= 4) && (i % 2 == 0) )
        {
            /* shove each bit into the storage bytes */
            dht11_dat[j / 8] <<= 1;
            if ( counter > 16 )
                    dht11_dat[j / 8] |= 1;
            j++;
        }
    }

    // Depending the version how we print out the data.
    switch(DHVER){
      case 11:
        dht11_print();
      case 22:
        dht22_print();
      default:
        dht22_print();
    }

}

void dht11_print(){
  /*
  * check we read 40 bits (8bit x 5 ) + verify checksum in the last byte
  */
  if ( (j >= 40) &&
          (dht11_dat[4] == ( (dht11_dat[0] + dht11_dat[1] + dht11_dat[2] + dht11_dat[3]) & 0xFF) ) )
  {
      f = dht11_dat[2] * 9. / 5. + 32;
      if(MACHINE_READABLE){
          printf( "%d.%d %d.%d\n",
                  dht11_dat[0], dht11_dat[1], dht11_dat[2], dht11_dat[3], f );
      }else{
          printf( "Humidity = %d.%d %% Temperature = %d.%d *C (%.1f *F)\n",
                  dht11_dat[0], dht11_dat[1], dht11_dat[2], dht11_dat[3], f );
      }
  }else if(!SKIP) {
      if(MACHINE_READABLE){
          printf("Error \n");
      }else{
          printf("Error reading data from sensor, skipping...\n");
      }
  }
}

void dht22_print(){
  // check we read 40 bits (8bit x 5 ) + verify checksum in the last byte
  if ((j >= 40) &&
      (dht22_dat[4] == ((dht22_dat[0] + dht22_dat[1] + dht22_dat[2] + dht22_dat[3]) & 0xFF)) ) {
        float t, h;
        h = (float)dht22_dat[0] * 256 + (float)dht22_dat[1];
        h /= 10;
        t = (float)(dht22_dat[2] & 0x7F)* 256 + (float)dht22_dat[3];
        t /= 10.0;
        if ((dht22_dat[2] & 0x80) != 0)  t *= -1;
    if(MACHINE_READABLE){
        printf("%.2f %% %.2f\n", h, t );
    }else{
        printf("Humidity = %.2f %% Temperature = %.2f *C \n", h, t );
    }
  }
  else if(!SKIP) {
      if(MACHINE_READABLE){
          printf("Error \n");
      }else{
          printf("Error reading data from sensor, skipping...\n");
      }
  }
}

int main( int argc, char *argv[] )
{
    int interval = 1000;
    int opt;
    bool skip = false;
    bool machineReadable = false;
    bool justOne = false;
    bool debug = false;
    int dataPin = 7;
    int version = 11;
    while ((opt = getopt(argc, argv, "MDJI:P:s:V")) != -1) {
        switch (opt) {
            case 'I':
                interval = atoi(optarg) * 1000;
                break;
            case 'M':
                machineReadable = true;
                break;
            case 'P':
                dataPin = atoi(optarg);
                break;
            case 'J':
                justOne = true;
                break;
            case 'D':
                debug = true;
                break;
            case 'V':
              version = atoi(optarg);
              break;
	    case 's':
		skip = true;
		break;
            case ':':
                /* missing option argument */
                fprintf(stderr, "%s: option '-%c' requires an argument\n",
                        argv[0], optopt);
                exit(PARAM_ASSIGN_ERROR);
                break;
            case '?':
            default:
                printf( "Raspberry Pi wiringPi DHT11 Temperature test program\n" );
                printf( "I number is the interval to run [Seconds].\n" );
                printf( "M flag to set machine readable which is [Humidity Temperature]\n" );
                printf( "P number is the data pin to use, default is 7\n" );
                printf( "J is just one value pair, for scripting mainly...\n" );
                printf( "D Will print everything in the pin out...\n" );
                printf( "V Sensor version, default 11...\n" );
        }
    }

    if ( wiringPiSetup() == -1 )
        exit( 1 );

    if ( justOne ){
        read_dht11_dat(dataPin, machineReadable, skip, debug, version);
    }else{
        while ( 1 )
        {
            read_dht11_dat(dataPin, machineReadable, skip, debug, version);
            delay(interval); /* wait 1sec to refresh */
        }
    }
    return(0);
}