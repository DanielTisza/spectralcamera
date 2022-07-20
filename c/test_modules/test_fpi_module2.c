/*# ----------------------------------------------------------------------------
#	test_fpi_module2.c
#
#	Copyright 2021 Daniel Tisza
#	MIT License
#
#	Test controlling FPI module
#
#	cl test_fpi_module2.c
#
# ----------------------------------------------------------------------------*/

#if 0
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

# MFPI setSetpoint()

# 3	72	1	52164	0	0	554.0473012	0	0	-0.167038819	0.897291038	-1.106291748	0	0	0	0	0	0	20.36692413	0	0
# 3	112	1	46815	0	0	600.3957949	0	0	0.63670834	0.421133211	-0.719467142	0	0	0	0	0	0	22.66214846	0	0
# 4	121	1	53506	0	0	695.9738452	0	0	0.746581945	0.746581945	0.746581945	0	0	0	0	0	0	30.93814177	0	0
# 6	190	1	44248	0	0	800.8814747	0	0	0.930350147	0.930350147	0.930350147	0	0	0	0	0	0	25.21518763	0	0

print("_current_setpoint: " + str(fpi._current_setpoint))

fpi.setSetpoint(52164)
print("_current_setpoint: " + str(fpi._current_setpoint))

fpi.setSetpoint(46815)
print("_current_setpoint: " + str(fpi._current_setpoint))

fpi.setSetpoint(53506)
print("_current_setpoint: " + str(fpi._current_setpoint))

fpi.setSetpoint(44248)
print("_current_setpoint: " + str(fpi._current_setpoint))

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
char		szReceiveBuf[100];

void fpi_command(
	int						command
);

void main(
	int						argc,
	char *					argv[]
) {
	DCB						dcb;
	BOOL					res;
	COMMTIMEOUTS			timeouts;
	char					fpiportstring[16];
	char					dummy;

	fpiportstring[0] = '\0';

	printf("Trying to use %s for FPI control", fpiportstring);

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
	memset(&timeouts, 0, sizeof(timeouts));

	timeouts.ReadTotalTimeoutConstant = 500;
	timeouts.ReadTotalTimeoutMultiplier = 5;
	timeouts.ReadIntervalTimeout = 100;

	timeouts.WriteTotalTimeoutConstant = 500;
	timeouts.WriteTotalTimeoutMultiplier  = 50;

	res = SetCommTimeouts(hComm, &timeouts);

	if (res == FALSE) {
		printf("SetCommTimeouts() for serial port failed!");
	}

	/*
	 * Clear TX, RX buffers
	 */
	PurgeComm(hComm, PURGE_RXCLEAR | PURGE_TXCLEAR);

	/*
	 * Write to serial port
	 */

	/*
	 * FPI open
	 * Write '!\r\n' and expect '!' in reply
	 */


	/*
	 * FPI get EEPROM
	 */


	/*
	 * Turn off
	 */
	printf("Set FPI setpoint: %d\r\n", 0);
	printf("Press to active\r\n");
	scanf("%c", &dummy);
	fpi_command(0);	
	printf("\r\n\r\nReceived response string:\r\n");
	printf("[0]=[%s]\r\n", szReceiveBuf);


	printf("Set FPI setpoint: %d\r\n", 0);
	printf("Press to active\r\n");
	scanf("%c", &dummy);
	fpi_command(13);
	printf("\r\n\r\nReceived response string:\r\n");
	printf("[13]=[%s]\r\n", szReceiveBuf);
	
	printf("Set FPI setpoint: %d\r\n", 0);
	printf("Press to active\r\n");
	scanf("%c", &dummy);
	fpi_command(14);
	printf("\r\n\r\nReceived response string:\r\n");
	printf("[14]=[%s]\r\n", szReceiveBuf);
	

	CloseHandle(hComm);
}

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

	/*
	 * Read response
	 */
	memset(szReceiveBuf, 0, sizeof(szReceiveBuf));
	
	res = ReadFile(
			hComm,
			szReceiveBuf,
			receiveBytes,
			&receiveCount,
			NULL
	);

	if (res == FALSE) {
		printf("ReadFile() for serial port failed!");
	}

	printf("ReadFile() read count = %d\n\n", receiveCount);

	res = FlushFileBuffers(hComm);

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

