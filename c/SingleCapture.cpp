/*-----------------------------------------------------------
-- SingleCapture.cpp
--
-- g++ SingleCapture.cpp -I/opt/mvIMPACT_Acquire -L/opt/mvIMPACT_Acquire/lib/armhf -l mvDeviceManager -std=c++11 -o SingleCapture
--
-- Visual Studio 2017 Developer Command Prompt v15.9.40
--
-- cl SingleCapture.cpp /EHsc /I "C:\Program Files\MATRIX VISION\mvIMPACT Acquire" /link /LIBPATH:"C:\Program Files\MATRIX VISION\mvIMPACT Acquire\lib"
--
-----------------------------------------------------------*/

#ifdef _MSC_VER // is Microsoft compiler?
#   if _MSC_VER < 1300  // is 'old' VC 6 compiler?
#       pragma warning( disable : 4786 ) // 'identifier was truncated to '255' characters in the debug information'
#   endif // #if _MSC_VER < 1300
#endif // #ifdef _MSC_VER

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#include <iostream>

#include <apps/Common/exampleHelper.h>
#include <mvIMPACT_CPP/mvIMPACT_acquire.h>
#include <mvIMPACT_CPP/mvIMPACT_acquire_GenICam.h>
#include <mvIMPACT_CPP/mvIMPACT_acquire_helper.h>

using namespace mvIMPACT::acquire;
using namespace std;

/*------------------------------------------------------------------------------
 * Definitions
 *----------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------
 * Global variables
 *----------------------------------------------------------------------------*/

#define bytesPerPixel			3 	// red, green, blue
#define fileHeaderSize			14
#define infoHeaderSize			40

/*------------------------------------------------------------------------------
 * Function declarations
 *----------------------------------------------------------------------------*/

void saveBitmapImage(
	unsigned char *			pBuf, 
	int 					height, 
	int 					width, 
	int 					pitch, 
	const char * 			szFileName
);


//-----------------------------------------------------------------------------
int main( void )
//-----------------------------------------------------------------------------
{
    DeviceManager devMgr;
    Device* pDev = getDeviceFromUserInput( devMgr );
    if( !pDev )
    {
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

#if 1
    /*
     * Test settings
     */
    mvIMPACT::acquire::GenICam::AcquisitionControl ac(pDev);
    mvIMPACT::acquire::GenICam::ImageFormatControl ifc(pDev);
    mvIMPACT::acquire::ImageProcessing imgp(pDev);
    mvIMPACT::acquire::GenICam::AnalogControl anlgc(pDev);
    mvIMPACT::acquire::GenICam::DeviceControl devc(pDev);

    cout    << "ac.exposureAuto: " << ac.exposureAuto.readS() << endl;
    ac.exposureAuto.writeS("Off");
    cout    << "ac.exposureAuto: " << ac.exposureAuto.readS() << endl;

    cout    << "ifc.pixelFormat: " << ifc.pixelFormat.readS() << endl;
    //"BayerGB12"
    //"RGB8"
    //ifc.pixelFormat.writeS("RGB8");
    ifc.pixelFormat.writeS("BayerGB12");
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

    //cout    << "devc.deviceConnectionSpeed: " << devc.deviceConnectionSpeed.readS() << endl;
    
    cout    << "devc.deviceLinkSpeed: " << devc.deviceLinkSpeed.readS() << endl;
    cout    << "devc.deviceLinkThroughputLimitMode: " << devc.deviceLinkThroughputLimitMode.readS() << endl;

    cout    << "devc.deviceLinkThroughputLimit: " << devc.deviceLinkThroughputLimit.readS() << endl;
    //devc.deviceLinkThroughputLimit.writeS("60000");
    cout    << "devc.deviceLinkThroughputLimit: " << devc.deviceLinkThroughputLimit.readS() << endl;

#endif

    FunctionInterface fi( pDev );

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
        return 1;
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
        return 1;
    }

    cout << "Image captured(" << pRequest->imagePixelFormat.readS() << " " << pRequest->imageWidth.read() << "x" << pRequest->imageHeight.read() << ")" << endl;

    unsigned char * pImg = (unsigned char *)pRequest->imageData.read();

    saveBitmapImage(
        (unsigned char *)pImg, 
        (int)1942, //height, 
        (int)2590, //width, 
        (int)5180, //pitchBytes, 
        "test.bmp"
    );

    // unlock the buffer to let the driver know that you no longer need this buffer.
    fi.imageRequestUnlock( requestNr );

    cout << "End the application" << endl;
//    cin.get();
    return 0;
}

/***************************************************************************//**
 *
 *	\brief		Save bitmap image
 *
 * 	\param		pBuf	Ptr to image pixels buffer
 * 	\param		height	Image height in pixels
 * 	\param		width	Image width in pixels
 * 	\param		pitch	Distance in bytes between successive rows in image
 * 	\param		szFileName	File name string, null-terminated
 * 
 *	\return		
 *
 *	\details	Save bitmap image
 *
 * 	\note
 *	
 ******************************************************************************/
void saveBitmapImage(
	unsigned char *			pBuf, 
	int 					height, 
	int 					width, 
	int 					pitch, 
	const char * 			szFileName
) {
	int 					i;
	FILE * 					imageFile;
	int						paddingSize;
	int						fileSize;

	/*
		0,0,0,0, /// header size
		0,0,0,0, /// image width
		0,0,0,0, /// image height
		0,0, /// number of color planes
		0,0, /// bits per pixel
		0,0,0,0, /// compression
		0,0,0,0, /// image size
		0,0,0,0, /// horizontal resolution
		0,0,0,0, /// vertical resolution
		0,0,0,0, /// colors in color table
		0,0,0,0, /// important color count
	 */
	unsigned char infoHeader[infoHeaderSize];

	/*
		0,0, /// signature
		0,0,0,0, /// image file size in bytes
		0,0,0,0, /// reserved
		0,0,0,0, /// start of pixel array
	*/
	unsigned char fileHeader[fileHeaderSize];

	/*
	 * Dummy buffer for writing padding values
	 */
	unsigned char padding[3] = { 0, 0, 0 };

	/*
	 * Bitmap file header
	 */
	memset(&fileHeader[0], 0, fileHeaderSize);

	//paddingSize = (4 - (pitch) % 4) % 4;
	paddingSize = 2;

	fileSize = 
			fileHeaderSize
		+ 	infoHeaderSize
		+ 	(pitch + paddingSize) * height;

	fileHeader[0] = (unsigned char)('B');
	fileHeader[1] = (unsigned char)('M');

	fileHeader[2] = (unsigned char)(fileSize);
	fileHeader[3] = (unsigned char)(fileSize >> 8);
	fileHeader[4] = (unsigned char)(fileSize >> 16);
	fileHeader[5] = (unsigned char)(fileSize >> 24);

	fileHeader[10] = (unsigned char)(fileHeaderSize + infoHeaderSize);

	/*
	 * Bitmap info header
	 */
	memset(&infoHeader[0], 0, infoHeaderSize);

	infoHeader[0] = (unsigned char)(infoHeaderSize);

	infoHeader[4] = (unsigned char)(width);
	infoHeader[5] = (unsigned char)(width >> 8);
	infoHeader[6] = (unsigned char)(width >> 16);
	infoHeader[7] = (unsigned char)(width >> 24);

	infoHeader[8] = (unsigned char)(height);
	infoHeader[9] = (unsigned char)(height >> 8);
	infoHeader[10] = (unsigned char)(height >> 16);
	infoHeader[11] = (unsigned char)(height >> 24);

	infoHeader[12] = (unsigned char)(1);

	infoHeader[14] = (unsigned char)24;

	/*
	 * Create file
	 */
	imageFile = fopen(szFileName, "wb");

	/*
	 * Bitmap file header
	 * Bitmap info header
	 */
	fwrite(&fileHeader[0], 1, fileHeaderSize, imageFile);
	fwrite(&infoHeader[0], 1, infoHeaderSize, imageFile);

	/*
	 * Pixels
	 *
	 * 0 - 1941
	 */
	for (i = 0; i < height; i++) {

		/*
		 * Pixel row
		 */
		uint16_t * pEven;
		uint16_t * pOdd;

		/*
		 * Need to convert from BayerGB12
		 *
		 * 2590
		 * 1942
		 * 
		 * 2590 * 3 bytes = 7770 bytes
		 * 7770 / 4 bytes = 1942.5
		 * 1943 * 4 = 7772 bytes
		 * 
		 * => padding = 2 bytes
		 */
		if ( (i & 1) == 0) {

			/*
			 * Current row is even
			 */
			pEven = (uint16_t *)(pBuf + (i * pitch));
			pOdd = (uint16_t *)(pBuf + ( (i+1) * pitch));

		} else {

			/*
			 * Current row is odd
			 * Last row index should also be odd, we trust that here
			 */
			pEven = (uint16_t *)(pBuf + ( (i-1) * pitch));
			pOdd = (uint16_t *)(pBuf + ( i * pitch));
		}

		uint16_t * pBlue = pEven + 1;
		uint16_t * pRed = pOdd;
		uint16_t * pGreen = pEven;

		/*
		 * Pixels in row
		 *
		 * 0 - 2589
		 * 
		 * 12-bit color value
		 */
		for (int j=0;j<width;j++) {

			uint16_t red = *pRed;
			uint16_t blue = *pBlue;

			if ((j & 1) == 0) {

				/*
				 * Odd pixel row index
				 */
				pGreen = pEven + j;

				pRed += 2;
				pBlue += 2;

			} else {

				/*
				 * Even pixel row index
				 */
				pGreen = pOdd + j + 1;
			}

			uint16_t green = *pGreen;

			padding[0] = blue >> 4;
			padding[1] = green >> 4;
			padding[2] = red >> 4;

			fwrite(
				padding,
				1,
				3,
				imageFile
			);
		}
		
		/*
		 * Padding to multiple of 4
		 */
		fwrite(
			padding,
			1,
			paddingSize,
			imageFile
		);
	}

	fclose(imageFile);
}
