/*# ----------------------------------------------------------------------------
#	test_fpi_module2.c
#
#	Copyright 2022 Daniel Tisza
#	MIT License
#
#	Test controlling FPI module
#
#	cl test_fpi_module2.c
#
# ----------------------------------------------------------------------------*/

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
int			isAC = 0;
int			isDC = 0;
long		dnMax;
long		dnMin;

/*
# 3	72	1	52164	0	0	554.0473012	0	0	-0.167038819	0.897291038	-1.106291748	0	0	0	0	0	0	20.36692413	0	0
# 3	112	1	46815	0	0	600.3957949	0	0	0.63670834	0.421133211	-0.719467142	0	0	0	0	0	0	22.66214846	0	0
# 4	121	1	53506	0	0	695.9738452	0	0	0.746581945	0.746581945	0.746581945	0	0	0	0	0	0	30.93814177	0	0
# 6	190	1	44248	0	0	800.8814747	0	0	0.930350147	0.930350147	0.930350147	0	0	0	0	0	0	25.21518763	0	0
*/

#define SETPOINT_COUNT		4

int ledset[SETPOINT_COUNT] = {
	3,
	3,
	4,
	6,
};

long setpoint[SETPOINT_COUNT] = {
	52164,
	46815,
	53506,
	44248,
};

void initFpiSerial(
	void
);

void readHardwareId(
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
	char					fpiportstring[16];
	char					dummy;
	int						ii;

	fpiportstring[0] = '\0';

	printf("Trying to use %s for FPI control", fpiportstring);

	/*
	 * Open FPI serial port
	 */
	initFpiSerial();

	/*
	 * Write '!\r\n' and expect '!' in reply
	 */

	/*
	 * Read hardware id
	 */
	readHardwareId();

	/*
	 * FPI get EEPROM
	 */
	readFpiEeprom();	

	/*
	 * FPI set setpoints
	 */
	for (ii=0;ii<SETPOINT_COUNT;ii++) {

		printf("Set FPI setpoint: %d\r\n", setpoint[ii]);
		printf("Press to activate\r\n");
		scanf("%c", &dummy);
		fpi_setpoint(setpoint[ii]);
	}

	CloseHandle(hComm);
}
/***************************************************************************//**
 *
 *	\brief		Initializes serial port for controlling FPI filter
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
void initFpiSerial(
	void
) {
	DCB						dcb;
	BOOL					res;
	COMMTIMEOUTS			timeouts;

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
void readHardwareId(
	void
) {
	char					dummy;

	printf("Read hardware id\r\n");
	printf("Press to activate\r\n");
	scanf("%c", &dummy);

	fpi_command(10000);	
	
	printf("\r\n\r\nReceived response string:\r\n");
	printf("[%s]\r\n", szReceiveBuf);

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
	char					szReadHardwareId[] = "!!\r\n";

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

		case 10000:
			szSendBuf = szReadHardwareId;
			sendBytes = strlen(szReadHardwareId);
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

	printf("\r\n");

}

