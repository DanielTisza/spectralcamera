/*-----------------------------------------------------------
-- SingleUserMemCapture.cpp
--
-- g++ SingleUserMemCapture.cpp -I/opt/mvIMPACT_Acquire -L/opt/mvIMPACT_Acquire/lib/armhf -l mvDeviceManager -std=c++11 -o SingleUserMemCapture
--
-- Visual Studio 2017 Developer Command Prompt v15.9.40
--
-- cl SingleUserMemCapture.cpp /EHsc /I "C:\Program Files\MATRIX VISION\mvIMPACT Acquire" /link /LIBPATH:"C:\Program Files\MATRIX VISION\mvIMPACT Acquire\lib"
--
-----------------------------------------------------------*/

#ifdef _MSC_VER // is Microsoft compiler?
#   if _MSC_VER < 1300  // is 'old' VC 6 compiler?
#       pragma warning( disable : 4786 ) // 'identifier was truncated to '255' characters in the debug information'
#   endif // #if _MSC_VER < 1300
#endif // #ifdef _MSC_VER

#include <iostream>
#include <apps/Common/exampleHelper.h>
#include <mvIMPACT_CPP/mvIMPACT_acquire.h>
#include <mvIMPACT_CPP/mvIMPACT_acquire_GenICam.h>
#include <mvIMPACT_CPP/mvIMPACT_acquire_helper.h>

using namespace mvIMPACT::acquire;
using namespace std;

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


    /*
     * User supplied capture buffer
	 *
	 * https://www.matrix-vision.com/manuals/SDK_CPP/classmvIMPACT_1_1acquire_1_1FunctionInterface.html#a749fd22991f052f7c324b0ba4105f33c
     */
	ImageRequestControl		irc( pDev );

    Request * 				pCurrentCaptureBufferLayout = NULL;

	int 					bufferAlignment = {0};

    int result = fi.getCurrentCaptureBufferLayout(
		irc,
		&pCurrentCaptureBufferLayout,
		&bufferAlignment
	);

    if( result != 0 )
    {
        cout << "An error occurred while querying the current capture buffer layout for device " << endl
             << "Press [ENTER] to end the application..." << endl;
        cin.get();
        return 1;
    }

    int bufferSize =
			pCurrentCaptureBufferLayout->imageSize.read()
		+	pCurrentCaptureBufferLayout->imageFooterSize.read();

    int bufferPitch = pCurrentCaptureBufferLayout->imageLinePitch.read();

    char * pUserBuf = (char *)_aligned_malloc(bufferSize, bufferAlignment);

	cout << "Buffer size: " << bufferSize << endl;
	cout << "Buffer pitch: " << bufferPitch << endl;
    cout << "Buffer alignment: " << bufferAlignment << endl;
    cout << "Buffer pointer: " << pUserBuf << endl;

	/*
	 * Allocate user buffer pointer
	 */
	Request* pReq = fi.getRequest( 0 );

	// the buffer assigned to the request object must be aligned accordingly
	// the size of the user supplied buffer MUST NOT include the additional size
	// caused by the alignment

    result = pReq->attachUserBuffer(pUserBuf, bufferSize);

	if(result == DMR_NO_ERROR )
	{
		irc.requestToUse.write( 0 ); // use the buffer just configured for the next image request

		// now the next image will be captured into the user supplied memory
		
		fi.imageRequestSingle( &irc ); // this will send request '0' to the driver

		// wait for the buffer. Once it has been returned by the driver AND the user buffer shall no
		// longer be used call

		manuallyStartAcquisitionIfNeeded( pDev, fi );

		int requestNr = fi.imageRequestWaitFor( 10000 );

		cout << "Got after waiting reqNr: " << requestNr << endl;

		manuallyStopAcquisitionIfNeeded( pDev, fi );

		
		// check if the image has been captured without any problems.
		if( !fi.isRequestNrValid( requestNr ) )
		{
			// If the error code is -2119(DEV_WAIT_FOR_REQUEST_FAILED), the documentation will provide
			// additional information under TDMR_ERROR in the interface reference
			cout << "imageRequestWaitFor failed maybe the timeout value has been too small?" << endl;
			return 1;
		}

		Request* pRequest = fi.getRequest( requestNr );

		if( !pRequest->isOK() )
		{
			cout << "Error: " << pRequest->requestResult.readS() << endl;
			return 1;
		}

		cout << "Image captured(" 
			<<	pRequest->imagePixelFormat.readS()
			<<	" " 
			<<	pRequest->imageWidth.read() 
			<< 	"x" 
			<<	pRequest->imageHeight.read()
			<<	")"
			<<	endl;

		
		if( pRequest->detachUserBuffer() != DMR_NO_ERROR )
		{
			// handle error
		}

		// now this request will use internal memory again.
	}
	else
	{
		// handle error
	}

    cout << "Press [ENTER] to end the application" << endl;
    cin.get();
    return 0;
}
