/*# ----------------------------------------------------------------------------
#	test_fpi_with_led.c
#
#	Copyright 2022 Daniel Tisza
#	MIT License
#
#	Test controlling FPI module and LED module
#
#	cl test_fpi_with_led.c
#
# ----------------------------------------------------------------------------*/

#if 0
# For LED imports
import os
import platform
import sys

import serial
import serial.tools.list_ports as list_ports
from serial import Serial

# For FPI imports
import fpipy as fp

from spectracular.fpi_driver import detectFPIDevices, createFPIDevice

		
FPI_IDS = [
    # ( VID,   PID) (and the same in decimal)
    ('1FC9', '0083'), (8137, 131),
    ]
"""Known VID:PID pairs of FPI devices."""
FPI_HWIDS = [
    # Strings returned by read_hardware_id
	 'd02b012 af380065 5b5bbeab f50019c1'
]

fpi = createFPIDevice(detectFPIDevices(FPI_IDS, FPI_HWIDS)[0].device)
print(fpi)

print("_hw_id: " + str(fpi._hw_id))

print("_hw_info: [" + str(fpi._hw_info) + "]")

print("_eeprom: ")
print(fpi._eeprom)

# MFPI specific
print("_expected_settling_time: " + str(fpi._expected_settling_time))
print("_setpoint_cmd: " + str(fpi._setpoint_cmd))
print("_current_setpoint: " + str(fpi._current_setpoint))

# MFPI parseEeprom()
print("_is_AC: " + str(fpi._is_AC))
print("_name: " + str(fpi._name))
print("_eeprom_id: " + str(fpi._eeprom_id))
print("_dn_max: " + str(fpi._dn_max))
print("_dn_min: " + str(fpi._dn_min))

# MFPI getTemperature()
print("getTemperature(): " + str(fpi.getTemperature()))

#----------------------------------------- 
#  LED driver
#-----------------------------------------

# ledportstring = '/dev/ttyACM1'
# ledportstring = 'COM10'

# HP laptop when LED connected on right side USB port
ledportstring = 'COM7'

print('Trying to use ' + ledportstring + ' for LED control')
port = serial.Serial(ledportstring, 9600, timeout=0.5)

# MFPI setSetpoint()

# 3	72	1	52164	0	0	554.0473012	0	0	-0.167038819	0.897291038	-1.106291748	0	0	0	0	0	0	20.36692413	0	0
# 3	112	1	46815	0	0	600.3957949	0	0	0.63670834	0.421133211	-0.719467142	0	0	0	0	0	0	22.66214846	0	0
# 4	121	1	53506	0	0	695.9738452	0	0	0.746581945	0.746581945	0.746581945	0	0	0	0	0	0	30.93814177	0	0
# 6	190	1	44248	0	0	800.8814747	0	0	0.930350147	0.930350147	0.930350147	0	0	0	0	0	0	25.21518763	0	0
# 8	235	1	25324	0	0	900.9252753	0	0	2.326559343	2.326559343	2.326559343	0	0	0	0	0	0	24.2601732	0	0

# Turn off
print('')
print('LEDs turn off with 0x0')
port.flushOutput()
port.flushInput()
port.write(str.encode('L0x0\r\n'))

print("_current_setpoint: " + str(fpi._current_setpoint))
input("LEDs off, press to continue")

#C
print('')
print('LEDs for set C [3]')
#led.L(0b000000001000000001000000001) 40201
port.flushOutput()
port.flushInput()
port.write(str.encode('L0x40201\r\n'))
port.flushOutput()
port.flushInput()

print('')
print('fpi.setSetpoint(52164)')
fpi.setSetpoint(52164)
print("_current_setpoint: " + str(fpi._current_setpoint))

input("Examine image 1, press to continue")

print('')
print('fpi.setSetpoint(46815)')
fpi.setSetpoint(46815)
print("_current_setpoint: " + str(fpi._current_setpoint))

input("Examine image 2, press to continue")

#D
print('')
print('LEDs for set D [4]')
#led.L(0b000011110000011110000011110) 783C1E
port.flushOutput()
port.flushInput()
port.write(str.encode('L0x783C1E\r\n'))
port.flushOutput()
port.flushInput()

print('')
print('fpi.setSetpoint(53506)')
fpi.setSetpoint(53506)
print("_current_setpoint: " + str(fpi._current_setpoint))

input("Examine image 3, press to continue")

#F
print('')
print('LEDs on for set F [6]')
#led.L(0b001111000001111000001111000) 1E0F078
port.flushOutput()
port.flushInput()
port.write(str.encode('L0x1E0F078\r\n'))
port.flushOutput()
port.flushInput()

print('')
print('fpi.setSetpoint(44248)')
fpi.setSetpoint(44248)
print("_current_setpoint: " + str(fpi._current_setpoint))

input("Examine image 4, press to continue")

#H
print('')
print('LEDs on for set H [8]')
#led.L(0b111100000111100000111100000) 783C1E0
port.flushOutput()
port.flushInput()
port.write(str.encode('L0x783C1E0\r\n'))
port.flushOutput()
port.flushInput()

print('')
print('fpi.setSetpoint(25324)')
fpi.setSetpoint(25324)
print("_current_setpoint: " + str(fpi._current_setpoint))

input("Examine image 5, press to continue")


# Turn off
print('')
print('LEDs turn off with 0x0')
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

HANDLE		hCommLed;

HANDLE		hCommFpi;
char		szReceiveBuf[100];
int			isAC = 0;
int			isDC = 0;
long		dnMax;
long		dnMin;

/*
# 3	72	1	52164	0	0	554.0473012	0	0	-0.167038819	0.897291038	-1.106291748	0	0	0	0	0	0	20.36692413	0	0
# 3	112	1	46815	0	0	600.3957949	0	0	0.63670834	0.421133211	-0.719467142	0	0	0	0	0	0	22.66214846	0	0
# 4	121	1	53506	0	0	695.9738452	0	0	0.746581945	0.746581945	0.746581945	0	0	0	0	0	0	30.93814177	0	0
# 6	190	1	44248	0	0	800.8814747	0	0	0.930350147	0.930350147	0.930350147	0	0	0	0	0	0	25.21518763	0	0
# 8	235	1	25324	0	0	900.9252753	0	0	2.326559343	2.326559343	2.326559343	0	0	0	0	0	0	24.2601732	0	0
*/

#define SETPOINT_COUNT		5

int ledset[SETPOINT_COUNT] = {
	3,
	3,
	4,
	6,
	8,
};

long setpoint[SETPOINT_COUNT] = {
	52164,
	46815,
	53506,
	44248,
	25324,
};

void initLedSerial(
	void
);

void led_set(
	int						ledset
);

void initFpiSerial(
	void
);

void readFpiEeprom(
	void
);

void fpi_command(
	int						command
);

void fpi_setpoint(
	long					setpoint
);

/***************************************************************************//**
 *
 *	\brief		Main application entry point
 *
 * 	\param		
 * 
 *	\return		
 *
 *	\details	
 *
 * 	\note
 *	
 ******************************************************************************/
void main(
	int						argc,
	char *					argv[]
) {
	char					dummy;
	int						ii;

	/*
	 * Open LED serial port
	 */
	initLedSerial();

	/*
	 * Turn off
	 */
	printf("Turn LEDs off\r\n");
	printf("Press to active\r\n");
	scanf("%c", &dummy);
	led_set(0);	

	/*
	 * Open FPI serial port
	 */
	initFpiSerial();

	/*
	 * Write '!\r\n' and expect '!' in reply
	 */

	/*
	 * FPI get EEPROM
	 */
	readFpiEeprom();	

	/*
	 * FPI set setpoints
	 */
	for (ii=0;ii<SETPOINT_COUNT;ii++) {

		printf("Image settings for [%d]:\r\n", ii);

		printf("Set LED set: %d\r\n", ledset[ii]);
		printf("Set FPI setpoint: %d\r\n", setpoint[ii]);

		printf("Press to activate\r\n");
		scanf("%c", &dummy);

		led_set(ledset[ii]);
		fpi_setpoint(setpoint[ii]);
	}

	/*
	 * Turn off
	 */
	printf("Turn LEDs off\r\n");
	printf("Press to active\r\n");
	scanf("%c", &dummy);
	led_set(0);	

	/*
	 * Close serial ports
	 */
	CloseHandle(hCommLed);
	CloseHandle(hCommFpi);
}
/***************************************************************************//**
 *
 *	\brief		Initializes serial port for controlling FPI filter
 *
 * 	\param		
 * 
 *	\return		
 *
 *	\details	Initializes serial port for controlling FPI filter
 *
 * 	\note
 *	
 ******************************************************************************/
void initFpiSerial(
	void
) {
	DCB						dcb;
	BOOL					res;
	COMMTIMEOUTS			timeouts;
	char					fpiportstring[16];

	fpiportstring[0] = '\0';

	printf("Trying to use %s for FPI control", fpiportstring);

	hCommFpi = CreateFileA(
				"\\\\.\\COM4",
				GENERIC_READ | GENERIC_WRITE,
				0,
				NULL,
				OPEN_EXISTING,
				0,
				NULL
	);

	if (hCommFpi == INVALID_HANDLE_VALUE) {
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

	res = SetCommState(hCommFpi, &dcb);

	if (res == FALSE) {
		printf("SetCommState() for serial port failed!");
	}

	/*
	 * Set timeouts (if necessary)
	 */
	memset(&timeouts, 0, sizeof(timeouts));

	timeouts.ReadTotalTimeoutConstant = 500;
	timeouts.ReadTotalTimeoutMultiplier = 5;
	timeouts.ReadIntervalTimeout = 100;

	timeouts.WriteTotalTimeoutConstant = 500;
	timeouts.WriteTotalTimeoutMultiplier  = 50;

	res = SetCommTimeouts(hCommFpi, &timeouts);

	if (res == FALSE) {
		printf("SetCommTimeouts() for serial port failed!");
	}

	/*
	 * Clear TX, RX buffers
	 */
	PurgeComm(hCommFpi, PURGE_RXCLEAR | PURGE_TXCLEAR);
}
/***************************************************************************//**
 *
 *	\brief		Sets LED set
 *
 * 	\param		
 * 
 *	\return		
 *
 *	\details	Sends LED set command to LED module
 *
 * 	\note
 *	
 ******************************************************************************/
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
			hCommLed,
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

	res = FlushFileBuffers(hCommLed);

	if (res == FALSE) {
		printf("FlushFileBuffers() for serial port failed!");
	}
}
/***************************************************************************//**
 *
 *	\brief		Reads FPI filter EEPROM
 *
 * 	\param		
 * 
 *	\return		
 *
 *	\details	
 *
 * 	\note		Must be called before trying to set setpoint.
 *	
 ******************************************************************************/
void readFpiEeprom(
	void
) {
	char					dummy;
	int						iRes;

	printf("Read EEPROM [0]: %d\r\n", 0);
	printf("Press to activate\r\n");
	scanf("%c", &dummy);
	fpi_command(0);	
	printf("\r\n\r\nReceived response string:\r\n");
	printf("[0]=[%s]\r\n", szReceiveBuf);

	{
		char * pSecond;
		char * pThird;
		
		pSecond = strchr(szReceiveBuf, ',');

		if (pSecond != NULL) {

			pSecond++;

			printf("[acdc_name]=[%s]\r\n", pSecond);

			pThird = strchr(pSecond, '_');

			if (pThird != NULL) {

				*pThird = '\0';
				printf("[ACDC]=[%s]\r\n", pSecond);

				if (	pSecond[0] == 'A'
					&&	pSecond[1] == 'C'
				) {
					isAC = 1;

				} else if (
						pSecond[0] == 'D'
					&&	pSecond[1] == 'C'
				) {

					isDC = 1;
				}

				pThird++;
				printf("[name]=[%s]\r\n", pThird);
			}
		}
	}

	printf("Read EEPROM [13]: %d\r\n", 0);
	printf("Press to activate\r\n");
	scanf("%c", &dummy);
	fpi_command(13);
	printf("\r\n\r\nReceived response string:\r\n");
	printf("[13]=[%s]\r\n", szReceiveBuf);

	{
		char * pSecond;
		char * pThird;
		
		pSecond = strchr(szReceiveBuf, ',');

		if (pSecond != NULL) {

			pSecond++;

			printf("[dn_max_value]=[%s]\r\n", pSecond);

			iRes = sscanf(pSecond, "%d", &dnMax);

			if (iRes == 1) {
				printf("DN max: %d\r\n", dnMax);
			}
		}
	}
	
	printf("Read EEPROM [14]: %d\r\n", 0);
	printf("Press to activate\r\n");
	scanf("%c", &dummy);
	fpi_command(14);
	printf("\r\n\r\nReceived response string:\r\n");
	printf("[14]=[%s]\r\n", szReceiveBuf);
	
	{
		char * pSecond;
		char * pThird;
		
		pSecond = strchr(szReceiveBuf, ',');

		if (pSecond != NULL) {

			pSecond++;

			printf("[dn_min_value]=[%s]\r\n", pSecond);

			iRes = sscanf(pSecond, "%d", &dnMin);

			if (iRes == 1) {
				printf("DN min: %d\r\n", dnMin);
			}
		}
	}
}
/***************************************************************************//**
 *
 *	\brief		Sends command to FPI and reads response
 *
 * 	\param		
 * 
 *	\return		
 *
 *	\details	
 *
 * 	\note
 *	
 ******************************************************************************/
void fpi_command(
	int						command
) {
	BOOL					res;
	DWORD					writeCount;
	char *					szSendBuf;
	int						sendBytes;	
	int						receiveBytes = 100;
	DWORD					receiveCount;
	int						ii;

	char					szReadEeprom0[] = "R0\r\n";
	char					szReadEeprom13[] = "R13\r\n";
	char					szReadEeprom14[] = "R14\r\n";

	switch (command) {

		case 0:
			szSendBuf = szReadEeprom0;
			sendBytes = strlen(szReadEeprom0);
			break;

		case 13:
			szSendBuf = szReadEeprom13;
			sendBytes = strlen(szReadEeprom13);
			break;

		case 14:
			szSendBuf = szReadEeprom14;
			sendBytes = strlen(szReadEeprom14);
			break;

		default:
			break;
	}

	/*
	 * Write command
	 */
	res = WriteFile(
			hCommFpi,
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

	res = FlushFileBuffers(hCommFpi);

	if (res == FALSE) {
		printf("FlushFileBuffers() for serial port failed!");
	}

	/*
	 * Read response
	 */
	memset(szReceiveBuf, 0, sizeof(szReceiveBuf));

	res = ReadFile(
			hCommFpi,
			szReceiveBuf,
			receiveBytes,
			&receiveCount,
			NULL
	);

	if (res == FALSE) {
		printf("ReadFile() for serial port failed!");
	}

	printf("ReadFile() read count = %d\n\n", receiveCount);

	res = FlushFileBuffers(hCommFpi);

	if (res == FALSE) {
		printf("FlushFileBuffers() for serial port failed!");
	}

	/*
	 * Print received bytes
	 */
	printf("\r\n\r\nReceived bytes:\r\n");

	for (ii=0;ii<receiveCount;ii++) {

		printf("[%d]=0x%X ", ii, szReceiveBuf[ii]);
	}

	printf("\r\n");
}
/***************************************************************************//**
 *
 *	\brief		Sets FPI filter setpoint
 *
 * 	\param		
 * 
 *	\return		
 *
 *	\details	Sends setpoint command to FPI filter
 *
 * 	\note
 *	
 ******************************************************************************/
void fpi_setpoint(
	long					setpoint
) {
	BOOL					res;
	DWORD					writeCount;
	char 					szSendBuf[100];
	int						sendBytes;	
	int						ii;

	/*
	 * Validate setpoint against given range
	 */
	if (setpoint < dnMin || setpoint > dnMax) {
		printf("Setpoint %d out of range [%d, %d]!", setpoint, dnMin, dnMax);
		return;
	}

	/*
	 * AC setpoint command = 'a'
	 * DC setpoint command = 'd'
	 */
	if (isAC) {
		sprintf(szSendBuf, "a%d\r\n", setpoint);
	} else if (isDC) {
		sprintf(szSendBuf, "d%d\r\n", setpoint);
	} else {
		printf("Invalid control type! Should be AC or DC");
		return;
	}

	printf("Setpoint command: [%s]", szSendBuf);

	sendBytes = strlen(szSendBuf);
	printf("Setpoint command byte count: %d", sendBytes);

	/*
	 * Write command
	 */
	res = WriteFile(
			hCommFpi,
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

	res = FlushFileBuffers(hCommFpi);

	if (res == FALSE) {
		printf("FlushFileBuffers() for serial port failed!");
	}

	printf("\r\n");

}
/***************************************************************************//**
 *
 *	\brief		Initializes serial port for controlling LED module
 *
 * 	\param		
 * 
 *	\return		
 *
 *	\details	Initializes serial port for controlling LED module
 *
 * 	\note
 *	
 ******************************************************************************/
void initLedSerial(
	void
) {
	DCB						dcb;
	BOOL					res;
	char					ledportstring[16];
	char					dummy;

	ledportstring[0] = '\0';

	printf("Trying to use %s for LED control", ledportstring);

	hCommLed = CreateFileA(
				"\\\\.\\COM7",
				GENERIC_READ | GENERIC_WRITE,
				0,
				NULL,
				OPEN_EXISTING,
				0,
				NULL
	);

	if (hCommLed == INVALID_HANDLE_VALUE) {
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

	res = SetCommState(hCommLed, &dcb);

	if (res == FALSE) {
		printf("SetCommState() for serial port failed!");
	}

	/*
	 * Set timeouts (if necessary)
	 */

	/*
	 * Clear TX, RX buffers
	 */
	PurgeComm(hCommLed, PURGE_RXCLEAR | PURGE_TXCLEAR);
}
