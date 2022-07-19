/* ----------------------------------------------------------------------------
#	test_leds_direct2.c
#
#	Copyright 2021 Daniel Tisza
#	MIT License
#
#	Test setting all LED sets lightings from A to H
#
#	cl test_leds_direct2.c
#
# ----------------------------------------------------------------------------*/

#if 0

import os
import platform
import sys

import serial
import serial.tools.list_ports as list_ports
from serial import Serial

#----------------------------------------- 
#  LED driver
#-----------------------------------------

ledportstring = '/dev/ttyACM1'
# ledportstring = 'COM10'

print('Trying to use ' + ledportstring + ' for LED control')
port = serial.Serial(ledportstring, 9600, timeout=0.5)

#A
print('LEDs on for set A')
input("Press to activate")
# led.L(0b000000111000000111000000111) 1C0E07
port.flushOutput()
port.flushInput()
port.write(str.encode('L0x1C0E07\r\n'))
port.flushOutput()
port.flushInput()

#B
print('LEDs on for set B')
input("Press to activate")
#led.L(0b000000011000000011000000011) C0603
port.flushOutput()
port.flushInput()
port.write(str.encode('L0xC0603\r\n'))
port.flushOutput()
port.flushInput()

#C
print('LEDs on for set C')
input("Press to activate")
#led.L(0b000000001000000001000000001) 40201
port.flushOutput()
port.flushInput()
port.write(str.encode('L0x40201\r\n'))
port.flushOutput()
port.flushInput()

#D
print('LEDs on for set D')
input("Press to activate")
#led.L(0b000011110000011110000011110) 783C1E
port.flushOutput()
port.flushInput()
port.write(str.encode('L0x783C1E\r\n'))
port.flushOutput()
port.flushInput()

#E
print('LEDs on for set E')
input("Press to activate")
#led.L(0b000111100000111100000111100) F0783C
port.flushOutput()
port.flushInput()
port.write(str.encode('L0xF0783C\r\n'))
port.flushOutput()
port.flushInput()

#F
print('LEDs on for set F')
input("Press to activate")
#led.L(0b001111000001111000001111000) 1E0F078
port.flushOutput()
port.flushInput()
port.write(str.encode('L0x1E0F078\r\n'))
port.flushOutput()
port.flushInput()

#G
print('LEDs on for set G')
input("Press to activate")
#led.L(0b011110000011110000011110000) 3C1E0F0
port.flushOutput()
port.flushInput()
port.write(str.encode('L0x3C1E0F0\r\n'))
port.flushOutput()
port.flushInput()

#H
print('LEDs on for set H')
input("Press to activate")
#led.L(0b111100000111100000111100000) 783C1E0
port.flushOutput()
port.flushInput()
port.write(str.encode('L0x783C1E0\r\n'))
port.flushOutput()
port.flushInput()

# Turn off
print('Turn off with 0x0')
input("Press any key")
port.flushOutput()
port.flushInput()
port.write(str.encode('L0x0\r\n'))

#endif

//#include <iostream>
//using namespace std;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <math.h>


void main(int argc, char* argv[]) {

	char		ledportstring[16];

	ledportstring[0] = '\0';

	printf("Trying to use %s for LED control", ledportstring);

	
}