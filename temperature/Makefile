#
# File:   Makefile
# Author: Derek Demuro
#

# -O3
#Performs O2 optimizations and enables more aggressive loop transformations such
# as Fusion, Block-Unroll-and-Jam, and collapsing IF stateents. The O3
#optimizations may not cause higher performance unless loop and memory access
#transformations take place. The optimizations may slow down code in some cases
#compared to O2 optimizations. The O3 option is recommended for applications
#that have loops that heavily use floating-point calculations and process large
#data sets.


CXX_SOURCE=dht_sensor_app.cpp
CXX_EXECUTABLE=dht_sensor
CXX_FLAGS=-g -Wall -Wextra -Ofast -lwiringPi
R_FLAGS=-std=c++11 -lwiringPi
LD_FLAGS=-std=c++11 -lwiringPi
CC=g++

#------------------------------------------------------------------------------

#Build Target
all: $(CXX_EXECUTABLE)

#Executable
$(CXX_EXECUTABLE): $(CXX_SOURCE)
	$(CC) $(CXX_SOURCE) -o$(CXX_EXECUTABLE) $(R_FLAGS) $(CXX_FLAGS)
	strip $(CXX_EXECUTABLE)

#Remove script
clean:
	rm -f $(CXX_EXECUTABLE)
