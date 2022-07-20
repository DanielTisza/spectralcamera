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
int			isAC = 0;
int			isDC = 0;
long		dnMax;
long		dnMin;

/*
ledset	index	Npeaks	SP1	SP2	SP3	PeakWL1	PeakWL2	PeakWL3	Sinv11	Sinv12	Sinv13	Sinv21	Sinv22	Sinv23	Sinv31	Sinv32	Sinv33	FWHM1	FWHM2	FWHM3
0	0	2	44748	0	0	505.914289	614.2813052	0	-0.398411474	1.259903596	1.025911637	0.752656263	-0.099247137	0.020958335	0	0	0	14.26460175	22.90707427	0
0	1	2	38137	0	0	529.6967931	648.7050781	0	-0.213236666	0.675034929	0.47800432	1.096529239	-0.196707289	0.090149999	0	0	0	19.31133749	22.91851783	0
0	2	1	51545	0	0	559.946926	0	0	0.679889519	1.419721666	-4.845915769	0	0	0	0	0	0	22.17152035	0	0
0	3	1	48253	0	0	590.5393079	0	0	0.744158985	0.88514816	-1.525211353	0	0	0	0	0	0	19.27394234	0	0
0	4	2	43666	0	0	509.0977574	620.8469159	0	-0.278237594	0.95500646	0.689725545	0.799175554	-0.12899134	0.070664975	0	0	0	17.24490964	22.21616876	0
0	5	2	32410	0	0	547.9435618	670.419621	0	-0.033097435	1.002178578	-1.246062	0.941021878	-0.658921908	2.815570398	0	0	0	17.5773986	22.00005834	0
0	6	1	52670	0	0	709.6242043	0	0	0.761968164	0.761968164	0.761968164	0	0	0	0	0	0	27.34661845	0	0
0	7	1	50362	0	0	740.2281587	0	0	0.810986945	0.810986945	0.810986945	0	0	0	0	0	0	28.68050028	0	0
*/

long setpoint[8] = {
	44748,
	38137,
	51545,
	48253,
	43666,
	32410,
	52670,
	50362,
};

void fpi_command(
	int						command
);

void fpi_setpoint(
	long					setpoint
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
	int						iRes;
	int						ii;

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
	 * FPI open
	 * Write '!\r\n' and expect '!' in reply
	 */


	/*
	 * FPI get EEPROM
	 */
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

	/*
	 * FPI set setpoints
	 */
	for (ii=0;ii<8;ii++) {

		printf("Set FPI setpoint: %d\r\n", setpoint[ii]);
		printf("Press to activate\r\n");
		scanf("%c", &dummy);
		fpi_setpoint(setpoint[ii]);
	}

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

