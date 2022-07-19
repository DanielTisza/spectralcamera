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
#include <windows.h>

HANDLE		hComm;

void led_set(
	int						ledset
);

void main(
	int						argc,
	char *					argv[]
) {
	DCB						dcb;
	BOOL					res;
	char					ledportstring[16];
	char					dummy;

	ledportstring[0] = '\0';

	printf("Trying to use %s for LED control", ledportstring);

	hComm = CreateFileA(
				"\\\\.\\COM4",
				GENERIC_READ | GENERIC_WRITE,
				0,
				NULL,
				OPEN_EXISTING,
				0,
				NULL
	);

	if (hComm == INVALID_HANDLE_VALUE) {
		printf("CreateFileA() for serial port failed!");
	}

	/*
	 * Setup DCB
	 */
	memset(&dcb, 0, sizeof(dcb));

	dcb.BaudRate = CBR_115200;
	dcb.ByteSize = 8;
	dcb.StopBits = ONESTOPBIT;
	dcb.Parity = NOPARITY;

	res = SetCommState(hComm, &dcb);

	if (res == FALSE) {
		printf("SetCommState() for serial port failed!");
	}

	/*
	 * Set timeouts (if necessary)
	 */

	/*
	 * Clear TX, RX buffers
	 */
	PurgeComm(hComm, PURGE_RXCLEAR | PURGE_TXCLEAR);

	/*
	 * Write to serial port
	 */

	/*
	 * Turn off
	 */
	printf("Turn LEDs off\r\n");
	printf("Press to active\r\n");
	scanf("%c", &dummy);
	led_set(0);	

	/*
	 * LED sets A to H
	 */
	printf("LEDs on for set A\r\n");
	printf("Press to activate\r\n");
	scanf("%c", &dummy);
	led_set(1);
	
	printf("LEDs on for set B\r\n");
	printf("Press to activate\r\n");
	scanf("%c", &dummy);
	led_set(2);
	
	printf("LEDs on for set C\r\n");
	printf("Press to activate\r\n");
	scanf("%c", &dummy);
	led_set(3);
	
	printf("LEDs on for set D\r\n");
	printf("Press to activate\r\n");
	scanf("%c", &dummy);
	led_set(4);
	
	printf("LEDs on for set E\r\n");
	printf("Press to activate\r\n");
	scanf("%c", &dummy);
	led_set(5);
	
	printf("LEDs on for set F\r\n");
	printf("Press to activate\r\n");
	scanf("%c", &dummy);
	led_set(6);
	
	printf("LEDs on for set G\r\n");
	printf("Press to activate\r\n");
	scanf("%c", &dummy);
	led_set(7);
	
	printf("LEDs on for set H\r\n");
	printf("Press to activate\r\n");
	scanf("%c", &dummy);
	led_set(8);
	
	/*
	 * Turn off
	 */
	printf("Turn LEDs off\r\n");
	printf("Press to activate\r\n");
	scanf("%c", &dummy);
	led_set(0);
	

	CloseHandle(hComm);
}

void led_set(
	int						ledset
) {
	BOOL					res;
	DWORD					writeCount;
	char *					szSendBuf;
	int						sendBytes;

	char					szLedSetNone[] = "L0x0\r\n";

	/*
	 * LED set A
	 *
	 * 111000000111000000111000000
     * Reverse for LED control:
     * 000000111000000111000000111
	 * => 0x1C0E07
	 */
	char					szLedSetA[] = "L0x1C0E07\r\n";

	/*
	 * LED set B
	 *
	 * 110000000110000000110000000
     * Reverse for LED control:
     * 000000011000000011000000011
	 * => 0xC0603
	 */
	char					szLedSetB[] = "L0xC0603\r\n";

	/*
	 * LED set C
	 *
	 * 100000000100000000100000000
     * Reverse for LED control:
     * 000000001000000001000000001
	 * => 0x40201
	 */
	char					szLedSetC[] = "L0x40201\r\n";

	/*
	 * LED set D
	 *
	 * 011110000011110000011110000
     * Reverse for LED control:
     * 000011110000011110000011110
	 * => 0x783C1E
	 */
	char					szLedSetD[] = "L0x783C1E\r\n";

	/*
	 * LED set E
	 *
	 * 001111000001111000001111000
     * Reverse for LED control:
     * 000111100000111100000111100
	 * => 0xF0783C
	 */
	char					szLedSetE[] = "L0xF0783C\r\n";

	/*
	 * LED set F
	 *
	 * 000111100000111100000111100
     * Reverse for LED control:
     * 001111000001111000001111000
	 * => 0x1E0F078
	 */
	char					szLedSetF[] = "L0x1E0F078\r\n";

	/*
	 * LED set G
	 *
	 * 000011110000011110000011110
     * Reverse for LED control:
     * 011110000011110000011110000
	 * => 0x3C1E0F0
	 */
	char					szLedSetG[] = "L0x3C1E0F0\r\n";

	/*
	 * LED set H
	 *
	 * 000001111000001111000001111
     * Reverse for LED control:
     * 111100000111100000111100000
	 * => 0x783C1E0
	 */
	char					szLedSetH[] = "L0x783C1E0\r\n";

	switch (ledset) {

		case 0:
			szSendBuf = szLedSetNone;
			sendBytes = strlen(szLedSetNone);
			break;

		case 1:
			szSendBuf = szLedSetA;
			sendBytes = strlen(szLedSetA);
			break;

		case 2:
			szSendBuf = szLedSetB;
			sendBytes = strlen(szLedSetB);
			break;

		case 3:
			szSendBuf = szLedSetC;
			sendBytes = strlen(szLedSetC);
			break;

		case 4:
			szSendBuf = szLedSetD;
			sendBytes = strlen(szLedSetD);
			break;

		case 5:
			szSendBuf = szLedSetE;
			sendBytes = strlen(szLedSetE);
			break;

		case 6:
			szSendBuf = szLedSetF;
			sendBytes = strlen(szLedSetF);
			break;

		case 7:
			szSendBuf = szLedSetG;
			sendBytes = strlen(szLedSetG);
			break;

		case 8:
			szSendBuf = szLedSetH;
			sendBytes = strlen(szLedSetH);
			break;

		default:
			break;
	}

	res = WriteFile(
			hComm,
			szSendBuf,
			sendBytes,
			&writeCount,
			NULL
	);

	if (res == FALSE) {
		printf("WriteFile() for serial port failed!");
	}

	printf("WriteFile() write count = %d\n\n", writeCount);

	if (sendBytes != writeCount) {
		printf("WriteFile() sendBytes != writeCount, write failed!");
	}

	res = FlushFileBuffers(hComm);

	if (res == FALSE) {
		printf("FlushFileBuffers() for serial port failed!");
	}
}

