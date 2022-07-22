/*-----------------------------------------------------------
-- capturedrmledfpi.cpp
--
-- Capture image, display it using libdrm
-- with RGB888 pixel format, control LED lighting,
-- and control FPI filter
--
-- Inspired by SingleCapture.cpp
-- Inspired by https://waynewolf.github.io/code/post/kms-pageflip.c
--
-- g++ capturedrmledfpi.cpp -I/opt/mvIMPACT_Acquire -L/opt/mvIMPACT_Acquire/lib/armhf -l mvDeviceManager -I/usr/include/libdrm -l drm -o capturedrmledfpi
--
-- Copyright: Daniel Tisza, 2022, GPLv3 or later
-----------------------------------------------------------*/

/*
 * This must be defined before includes
 */
#define _FILE_OFFSET_BITS 64

/*------------------------------------------------------------------------------
 * Includes
 *----------------------------------------------------------------------------*/

#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
//#include <termios.h>
#include <fcntl.h>
#include <errno.h>
//#include <math.h>
#include <xf86drm.h>
#include <xf86drmMode.h>
#include <sys/mman.h>

#include <apps/Common/exampleHelper.h>
#include <mvIMPACT_CPP/mvIMPACT_acquire.h>
#include <mvIMPACT_CPP/mvIMPACT_acquire_GenICam.h>
#include <mvIMPACT_CPP/mvIMPACT_acquire_helper.h>


/*------------------------------------------------------------------------------
 * Definitions
 *----------------------------------------------------------------------------*/

using namespace mvIMPACT::acquire;
using namespace std;

/*
 * Display modes
 */
#if 1
int					selectedMode = 0;
uint32_t			displayWidth = 1920;
uint32_t			displayHeight = 1080;
#endif

#if 0
int					selectedMode = 1;
uint32_t			displayWidth = 1680;
uint32_t			displayHeight = 1050;
#endif

#if 0
int					selectedMode = 3;
uint32_t			displayWidth = 1280;
uint32_t			displayHeight = 1024;
#endif

#define SETPOINT_COUNT		6

/*------------------------------------------------------------------------------
 * Global variables
 *----------------------------------------------------------------------------*/

int 							fdDrm;
drmModeRes *					resources;
drmModeConnector *				connector;
struct drm_mode_create_dumb		creq;
drmModeCrtcPtr					orig_crtc;
void *							pMap;

int			fdLed;

/* FPI */
int			fdFpi;
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

int ledset[SETPOINT_COUNT] = {
	0,
	3,
	3,
	4,
	6,
	8,
};

long setpoint[SETPOINT_COUNT] = {
	52164, /* leds off */
	52164,
	46815,
	53506,
	44248,
	25324,
};

/*------------------------------------------------------------------------------
 * Function declarations
 *----------------------------------------------------------------------------*/

/* Display */
void initDrmDisplay(void);
void closeDrmDisplay(void);

/* Camera */
void takeImageAndDraw(
	Device *				pDev,
	FunctionInterface		fi,
	uint8_t *				pBuf
);

/* FPI */
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

/* LED */
void initLedSerial(
	void
);

void led_set(
	long					ledset
);

/***************************************************************************//**
 *
 *	\brief		Main application entry point
 *
 * 	\param		
 * 
 *	\return		
 *
 *	\details	Main application entry point
 *
 * 	\note
 *	
 ******************************************************************************/
int main(
	void
) {
	int						fd;
	DeviceManager			devMgr;
	Device *				pDev;
	int						running;

	/*
	 * Open camera device
	 */
	pDev = getDeviceFromUserInput(devMgr);

    if (!pDev) {

        cout << "Unable to continue! Press [ENTER] to end the application" << endl;
        cin.get();
        return 1;
    }

    try
    {
        pDev->open();
    }
    catch( const ImpactAcquireException& e )
    {
        // this e.g. might happen if the same device is already opened in another process...
        cout << "An error occurred while opening the device(error code: " << e.getErrorCode() << ")." << endl
             << "Press [ENTER] to end the application" << endl;
        cin.get();
        return 1;
    }

    /*
     * Settings
     * 
     * mvIMPACT::acquire::GenICam::AcquisitionControl
     */
    mvIMPACT::acquire::GenICam::AcquisitionControl ac(pDev);
    mvIMPACT::acquire::GenICam::ImageFormatControl ifc(pDev);
    mvIMPACT::acquire::ImageProcessing imgp(pDev);
    mvIMPACT::acquire::GenICam::AnalogControl anlgc(pDev);

    cout    << "ac.exposureAuto: " << ac.exposureAuto.readS() << endl;
    ac.exposureAuto.writeS("Off");
    cout    << "ac.exposureAuto: " << ac.exposureAuto.readS() << endl;


    cout    << "ifc.pixelFormat: " << ifc.pixelFormat.readS() << endl;
    //"BayerGB12"
    //"RGB8"
    ifc.pixelFormat.writeS("RGB8");
    cout    << "ifc.pixelFormat: " << ifc.pixelFormat.readS() << endl;


    cout    << "ifc.pixelColorFilter: " << ifc.pixelColorFilter.readS() << endl;
    //"BayerRG" ?
    cout    << "ifc.pixelColorFilter: " << ifc.pixelColorFilter.readS() << endl;


    cout    << "imgp.colorProcessing: " << imgp.colorProcessing.readS() << endl;
    imgp.colorProcessing.writeS("Raw");
    cout    << "imgp.colorProcessing: " << imgp.colorProcessing.readS() << endl;


    cout    << "anlgc.balanceWhiteAuto: " << anlgc.balanceWhiteAuto.readS() << endl;
    anlgc.balanceWhiteAuto.writeS("Off");
    cout    << "anlgc.balanceWhiteAuto: " << anlgc.balanceWhiteAuto.readS() << endl;


    cout    << "anlgc.gamma: " << anlgc.gamma.readS() << endl;
    anlgc.gamma.writeS("1");
    cout    << "anlgc.gamma: " << anlgc.gamma.readS() << endl;


    cout    << "anlgc.gain: " << anlgc.gain.readS() << endl;
    anlgc.gain.writeS("1.9382002601");
    cout    << "anlgc.gain: " << anlgc.gain.readS() << endl;


    cout    << "anlgc.gainAuto: " << anlgc.gainAuto.readS() << endl;
    anlgc.gainAuto.writeS("Off");
    cout    << "anlgc.gainAuto: " << anlgc.gainAuto.readS() << endl;


    cout    << "ac.exposureTime: " << ac.exposureTime.readS() << endl;
    ac.exposureTime.writeS("60000");
    cout    << "ac.exposureTime: " << ac.exposureTime.readS() << endl;

	FunctionInterface fi(pDev);
	
	/*
	 * Initialize display
	 */
	initDrmDisplay();

	/*
	 * Initialize LED module
	 */
	initLedSerial();

	/*
	 * Initialize FPI module
	 */
	initFpiSerial();

	/*
	 * FPI get EEPROM
	 */
	readFpiEeprom();	

	/*
	 * Enter loop taking images
	 */
	running = 1;

	while (running) {

		/*
		 * Take image and draw to display
		 */
		cout << endl;
		cout << "Taking image" << endl;
		
		takeImageAndDraw(pDev, fi, (uint8_t *)pMap);

		/*
		 * Loop handling user commands
		 */
		while (running) {

			char	userCmd[100];
			char *	szRes;

			cout << "Press ENTER key to take new image" << endl;
			cout << "'q' and ENTER key to end application" << endl;
			cout << "'c 1' and ENTER key to set configuration 1-N" << endl;
			cout << "'e 60000' and ENTER key to set camera exposure to 60000 us" << endl;
			cout << ">>";

			szRes = fgets(userCmd, 100 , stdin);

			if (szRes != NULL) {

				printf("User command: %s\r\n", userCmd);

				if (userCmd[0] == 'q') {

					printf("Exiting program\r\n");
					running = 0;
					break;

				} else if (userCmd[0] == ' ') {
					break;

				} else if (userCmd[0] == '\n') {
					break;

				} else if (
						userCmd[0] == 'c'
					||	userCmd[0] == 'e'
				) {

					long		userNum;

					/*
					 * Try parse user given number
					 */
					sscanf(&userCmd[1], "%ld", &userNum);

					/*
					 * Change configuration for LED, FPI
					 */
					if (userCmd[0] == 'c') {

						
						if (	userNum >= 0
							&&	userNum < SETPOINT_COUNT
						) {
							cout << "--- Changing to setpoint: [" << userNum << "] ---" << endl;

							cout << "Setting LED set: " << ledset[userNum] << endl;
							led_set(ledset[userNum]);

							cout << "Setting FPI setpoint: " << setpoint[userNum] << endl;
							fpi_setpoint(setpoint[userNum]);
						}

					/*
					 * Change camera exposure time
					 */
					} else if (userCmd[0] == 'e') {

						if (userNum > 0 && userNum < 4294967296) {

							char			szExpTime[16];

							cout << "--- Changing exposure time: [" << userNum << "] ---" << endl;
							sprintf(szExpTime, "%ld", userNum);
							ac.exposureTime.writeS(szExpTime);
							cout    << "ac.exposureTime: " << ac.exposureTime.readS() << endl;
						}
					}

					break;
				}

			}
		}
	}

	/*
	 * Turn off LEDs
	 */
	printf("Turn LEDs off\r\n");
	led_set(0);

	/*
	 * Close
	 */
	closeDrmDisplay();
	close(fdLed);
	close(fdFpi);

    return 0;
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
	struct termios			portSettings;

	fdFpi = open("/dev/ttyACM0", O_RDWR | O_NOCTTY);

	if (fdFpi < 0) {
		printf("Failed opening FPI serial port!\r\n");
	} else {
		printf("Opened FPI serial port!\r\n");
	}

	tcgetattr(fdFpi, &portSettings);

	cfsetispeed(&portSettings, B115200);
	cfsetospeed(&portSettings, B115200);

	cfmakeraw(&portSettings);

	/*
	 * 8 data
	 * no parity
	 * 1 stop bit
	 */
	portSettings.c_cflag &= ~CSIZE;
	portSettings.c_cflag |= CS8;
	
	portSettings.c_cflag &= ~CSTOPB;
	
	portSettings.c_cflag |= CREAD;

	portSettings.c_cflag &= ~PARENB;

	portSettings.c_cflag |= CLOCAL;

	portSettings.c_cflag &= ~CRTSCTS;


	tcsetattr(fdFpi, TCSANOW, &portSettings);
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

			iRes = sscanf(pSecond, "%ld", &dnMax);

			if (iRes == 1) {
				printf("DN max: %ld\r\n", dnMax);
			}
		}
	}
	
	printf("Read EEPROM [14]: %d\r\n", 0);
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

			iRes = sscanf(pSecond, "%ld", &dnMin);

			if (iRes == 1) {
				printf("DN min: %ld\r\n", dnMin);
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
 *	\details	Sends command to FPI and reads response
 *
 * 	\note
 *	
 ******************************************************************************/
void fpi_command(
	int						command
) {
	ssize_t					writeCount;
	char *					szSendBuf;
	int						sendBytes;	
	int						receiveBytes = 100;
	ssize_t					receiveCount;
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
	writeCount = write(
		fdFpi,
		szSendBuf,
		(size_t)sendBytes
	);

	if (writeCount == -1) {
		printf("write() for serial port failed!");
	}

	printf("write() write count = %d\n\n", writeCount);

	if (sendBytes != writeCount) {
		printf("write() sendBytes != writeCount, write failed!");
	}

	fsync(fdFpi);

	/*
	 * Read response
	 */
	memset(szReceiveBuf, 0, sizeof(szReceiveBuf));

	receiveCount = read(
		fdFpi,
		szReceiveBuf,
		receiveBytes
	);

	if (receiveCount == -1) {
		printf("read() for serial port failed!");
	}

	printf("read() read count = %d\n\n", receiveCount);

	fsync(fdFpi);

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
	ssize_t					writeCount;
	char 					szSendBuf[100];
	int						sendBytes;	
	int						ii;

	/*
	 * Validate setpoint against given range
	 */
	if (	setpoint < dnMin 
		||	setpoint > dnMax
	) {
		printf("Setpoint %ld out of range [%ld, %ld]!\r\n", setpoint, dnMin, dnMax);
		return;
	}

	/*
	 * AC setpoint command = 'a'
	 * DC setpoint command = 'd'
	 */
	if (isAC) {

		sprintf(szSendBuf, "a%ld\r\n", setpoint);

	} else if (isDC) {

		sprintf(szSendBuf, "d%ld\r\n", setpoint);

	} else {

		printf("Invalid control type! Should be AC or DC");
		return;
	}

	printf("Setpoint command: [%s]\r\n", szSendBuf);

	sendBytes = strlen(szSendBuf);
	printf("Setpoint command byte count: %d\r\n", sendBytes);

	/*
	 * Write command
	 */
	writeCount = write(
		fdFpi,
		szSendBuf,
		(size_t)sendBytes
	);

	if (writeCount == -1) {
		printf("write() for serial port failed!");
	}

	printf("write() write count = %d\n\n", (int)writeCount);

	if (sendBytes != writeCount) {
		printf("write() sendBytes != writeCount, write failed!");
	}

	fsync(fdFpi);

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
	fdLed = open("/dev/ttyACM1", O_RDWR | O_NOCTTY);

	if (fdLed < 0) {
		printf("Failed opening LED serial port!\r\n");
	} else {
		printf("Opened LED serial port!\r\n");
	}

	struct termios portSettings;

	tcgetattr(fdLed, &portSettings);

	cfsetispeed(&portSettings, B115200);
	cfsetospeed(&portSettings, B115200);

	cfmakeraw(&portSettings);

	/*
	 * 8 data
	 * no parity
	 * 1 stop bit
	 */
	portSettings.c_cflag &= ~CSIZE;
	portSettings.c_cflag |= CS8;
	
	portSettings.c_cflag &= ~CSTOPB;
	
	portSettings.c_cflag |= CREAD;

	portSettings.c_cflag &= ~PARENB;

	portSettings.c_cflag |= CLOCAL;

	portSettings.c_cflag &= ~CRTSCTS;


	tcsetattr(fdLed, TCSANOW, &portSettings);
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
	long					ledset
) {
	ssize_t					writeCount;
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

	/*
	 * Write to serial port
	 */
	writeCount = write(
		fdLed,
		szSendBuf,
		(size_t)sendBytes
	);

	if (writeCount == -1) {
		printf("write() for serial port failed!");
	}

	printf("write() write count = %d\n\n", (int)writeCount);

	if (sendBytes != writeCount) {
		printf("write() sendBytes != writeCount, write failed!");
	}

	fsync(fdLed);
}
/***************************************************************************//**
 *
 *	\brief		Take image and draw to display
 *
 * 	\param		
 * 
 *	\return		
 *
 *	\details	Take image and draw to display
 *
 * 	\note
 *	
 ******************************************************************************/
void takeImageAndDraw(
	Device *				pDev,
	FunctionInterface		fi,
	uint8_t *				pBuf
) {
	uint32_t				width;
	uint32_t				height;
	uint32_t				col;
	uint32_t				row;
	uint8_t					data;

	uint8_t					imgRed;
	uint8_t					imgGreen;
	uint8_t					imgBlue;
	uint32_t				leftoffset;
	
	// send a request to the default request queue of the device and wait for the result.
	fi.imageRequestSingle();

	manuallyStartAcquisitionIfNeeded( pDev, fi );

	// Wait for results from the default capture queue by passing a timeout (The maximum time allowed
	// for the application to wait for a Result). Infinity value: -1, positive value: The time to wait in milliseconds.
	// Please note that slow systems or interface technologies in combination with high resolution sensors
	// might need more time to transmit an image than the timeout value.
	// Once the device is configured for triggered image acquisition and the timeout elapsed before
	// the device has been triggered this might happen as well.
	// If waiting with an infinite timeout(-1) it will be necessary to call 'imageRequestReset' from another thread
	// to force 'imageRequestWaitFor' to return when no data is coming from the device/can be captured.
	int requestNr = fi.imageRequestWaitFor( 10000 );

	manuallyStopAcquisitionIfNeeded( pDev, fi );

	// check if the image has been captured without any problems.
	if( !fi.isRequestNrValid( requestNr ) )
	{
		// If the error code is -2119(DEV_WAIT_FOR_REQUEST_FAILED), the documentation will provide
		// additional information under TDMR_ERROR in the interface reference
		cout << "imageRequestWaitFor failed maybe the timeout value has been too small?" << endl;
		return;
	}

	const Request* pRequest = fi.getRequest( requestNr );

	if( !pRequest->isOK() )
	{
		cout << "Error: " << pRequest->requestResult.readS() << endl;
		// if the application wouldn't terminate at this point this buffer HAS TO be unlocked before
		// it can be used again as currently it is under control of the user. However terminating the application
		// will free the resources anyway thus the call
		// fi.imageRequestUnlock( requestNr );
		// can be omitted here.
		return;
	}

	cout    << "Image captured(" 
			<< pRequest->imagePixelFormat.readS() 
			<< " " 
			<< pRequest->imageWidth.read() 
			<< "x" 
			<< pRequest->imageHeight.read() 
			<< ")" 
			<< endl;

	/*
	 * Read data
	 */
	unsigned char * pImg = (unsigned char *)pRequest->imageData.read();
	unsigned char * pData = pImg;

	/*
	 * Image size
	 * 2592 x 1944
	 * 
	 * Screen size
	 * 1280 x 1024 (HP )
	 * 1920 x 1080 (HP EliteDisplay E231)
	 */
	width = 2592;
	height = 1944;

	leftoffset = 0; //700;

	for (row=0;row<height;row++) {

		for (col=0;col<width;col++) {

			/*
			 * Camera image format is given as:
			 * (BGR888Packed 2592x1944)
			 */
			imgBlue = *pData++;
			imgGreen = *pData++;
			imgRed = *pData++;

			if (    col >= leftoffset 
				&&  col < (leftoffset + displayWidth)
				&&	row >= 0
				&& 	row < (0 + displayHeight)
			) {
				*pBuf++ = imgRed;
				*pBuf++ = imgGreen;
				*pBuf++ = imgBlue;
			} 
		}

		/*
		 * Jump over dummy bytes if pitch larger than display width
		 */
		if (creq.pitch > (3 * displayWidth)) {

			uint32_t fillByteCount;

			fillByteCount = creq.pitch - (3 * displayWidth);

			pBuf += fillByteCount;
		}

		/*
		 * Stop drawing image when outside
		 * display row size
		 */
		if (row > displayHeight) {
			break;
		}
	}

	// unlock the buffer to let the driver know that you no longer need this buffer.
	fi.imageRequestUnlock( requestNr );
}
/***************************************************************************//**
 *
 *	\brief		Initialize display DRM interface
 *
 * 	\param		
 * 
 *	\return		
 *
 *	\details	Initialize display DRM interface
 *
 * 	\note
 *	
 ******************************************************************************/
void initDrmDisplay(
	void
) {
	drmModeEncoder *encoder;
	drmModeModeInfo mode;
	int ret;
	int i;
	struct drm_mode_map_dumb		mreq;
	struct drm_mode_destroy_dumb 	dreq;
	uint32_t fb;
	
	/*
	 * Open DRM device
	 */

	fdDrm = open("/dev/dri/card0", O_RDWR);

	if(fdDrm < 0){
		printf("drmOpen failed: %s\n", strerror(errno));
		return; //goto out;
	}

	resources = drmModeGetResources(fdDrm);
	if(resources == NULL) {
		printf("drmModeGetResources failed: %s\n", strerror(errno));
		return; //goto close_fd;
	}

	/*
	 * Get first connected connector
	 */

	/* find the first available connector with modes */
	for(i=0; i < resources->count_connectors; ++i){

		connector = drmModeGetConnector(fdDrm, resources->connectors[i]);

		if(connector != NULL){

			printf("connector %d found\n", connector->connector_id);

			if(		connector->connection == DRM_MODE_CONNECTED
				&&	connector->count_modes > 0
			) {
				break;
			}

			drmModeFreeConnector(connector);

		} else {
			printf("get a null connector pointer\n");
		}
	}

	if (i == resources->count_connectors) {
		printf("No active connector found.\n");
		return; //goto free_drm_res;
	}

	printf("Connector mode count: (%d)\n", connector->count_modes);

	for(i=0; i < connector->count_modes; i++){

		drmModeModeInfo tmpMode;

		tmpMode = connector->modes[i];
		printf("[%d] (%dx%d)\n", i, tmpMode.hdisplay, tmpMode.vdisplay);
	}

	mode = connector->modes[selectedMode];

	printf("Selected mode: %d (%dx%d)\n",
		selectedMode,
		mode.hdisplay,
		mode.vdisplay
	);

	/*
	 * Find encoder matching selected connector
	 */

	/* find the encoder matching the first available connector */
	for (i=0; i < resources->count_encoders; ++i){

		encoder = drmModeGetEncoder(fdDrm, resources->encoders[i]);

		if (encoder != NULL) {

			printf("encoder %d found\n", encoder->encoder_id);

			if (encoder->encoder_id == connector->encoder_id) {
				break;
			}

			drmModeFreeEncoder(encoder);

		} else {
			printf("get a null encoder pointer\n");
		}
	}

	if (i == resources->count_encoders) {
		printf("No matching encoder with connector, shouldn't happen\n");
		return; //goto free_drm_res;
	}

	/*
	 * Create dumb buffer
	 */

	/* create dumb buffer */
	memset(&creq, 0, sizeof(creq));

	creq.width = displayWidth; //1280;
	creq.height = displayHeight; //1024;
	creq.bpp = 24; //32;

	ret = drmIoctl(
		fdDrm,
		DRM_IOCTL_MODE_CREATE_DUMB,
		&creq
	);

	if (ret < 0) {
			/* buffer creation failed; see "errno" for more error codes */
			printf("buffer creation failed\n");
	}
	/* creq.pitch, creq.handle and creq.size are filled by this ioctl with
	* the requested values and can be used now. */

	printf("Dumb frame buffer parameters:\n");
	printf("  creq.width: %d\n", creq.width);
	printf("  creq.height: %d\n", creq.height);
	printf("  creq.bpp: %d\n", creq.bpp);
	printf("  creq.pitch: %d\n", creq.pitch);
	printf("  creq.handle: %d\n", creq.handle);
	printf("  creq.size: %llu\n", creq.size);

	/* create framebuffer object for the dumb-buffer */
	ret = drmModeAddFB(
		fdDrm,
		displayWidth,
		displayHeight,
		24,
		24, //32,
		creq.pitch,
		creq.handle,
		&fb
	);

	if (ret) {
			/* frame buffer creation failed; see "errno" */
			printf("frame buffer creation failed\n");
	}
	/* the framebuffer "fb" can now used for scanout with KMS */

	/* prepare buffer for memory mapping */
	memset(&mreq, 0, sizeof(mreq));
	
	mreq.handle = creq.handle;

	ret = drmIoctl(
		fdDrm,
		DRM_IOCTL_MODE_MAP_DUMB,
		&mreq
	);

	if (ret) {
			/* DRM buffer preparation failed; see "errno" */
			printf("DRM buffer preparation failed\n");
	}
	/* mreq.offset now contains the new offset that can be used with mmap() */

	/* perform actual memory mapping */
	pMap = mmap(
		0,						//addr
		creq.size,				//length
		PROT_READ | PROT_WRITE,	//prot
		MAP_SHARED,				//flags
		fdDrm,					//fd
		mreq.offset				//offset
	);

	if (pMap == MAP_FAILED) {
			/* memory-mapping failed; see "errno" */
			printf("memory-mapping failed: %s\n", strerror(errno));
			printf("creq.size: %llu\n", creq.size);
			printf("fdDrm: %d\n", fdDrm);
			printf("mreq.offset: %llu\n", mreq.offset);
	}


	/*
	 * Clear the framebuffer to 0
	 */
	printf("clear the framebuffer to 0\n");
	//memset(pMap, 0, creq.size);
	memset(pMap, 255, creq.size);

	orig_crtc = drmModeGetCrtc(
		fdDrm,
		encoder->crtc_id
	);

	if (orig_crtc == NULL) {

		printf("orig_crtc is NULL!");
		//goto free_first_bo;
	}

	/*
	 * Set CRTC
	 */
	ret = drmModeSetCrtc(
				fdDrm,
				encoder->crtc_id,
				fb, 
				0,	//x
				0,	//y
				&connector->connector_id, 
				1, 		/* element count of the connectors array above*/
				&mode
	);

	if (ret) {
		printf("drmModeSetCrtc failed: %s\n", strerror(errno));
		//goto free_first_fb;
	}

}
/***************************************************************************//**
 *
 *	\brief		Close display DRM interface
 *
 * 	\param		
 * 
 *	\return		
 *
 *	\details	Close display DRM interface
 *
 * 	\note
 *	
 ******************************************************************************/
void closeDrmDisplay(
	void
) {
	int						ret;

	/*
	 * Set back original crtc
	 */
	ret = drmModeSetCrtc(
		fdDrm,
		orig_crtc->crtc_id,
		orig_crtc->buffer_id,
		orig_crtc->x,
		orig_crtc->y,
		&connector->connector_id,
		1,
		&orig_crtc->mode
	);

	if (ret) {
		printf("drmModeSetCrtc() restore original crtc failed: %m\n");
	}

//free_drm_res:
	drmModeFreeResources(resources);

//close_fd:
	drmClose(fdDrm);
	
//out:
	return;
}
