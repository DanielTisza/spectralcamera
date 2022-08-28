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
#include <iostream>
#include <apps/Common/exampleHelper.h>
#include <mvIMPACT_CPP/mvIMPACT_acquire.h>

/*
#ifdef _WIN32
#   define USE_DISPLAY
#   include <mvDisplay/Include/mvIMPACT_acquire_display.h>
using namespace mvIMPACT::acquire::display;
#endif // #ifdef _WIN32
*/

using namespace mvIMPACT::acquire;
using namespace std;

#include <apps/Common/exampleHelper.h>
#include <mvIMPACT_CPP/mvIMPACT_acquire.h>
#include <mvIMPACT_CPP/mvIMPACT_acquire_GenICam.h>
#include <mvIMPACT_CPP/mvIMPACT_acquire_helper.h>

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

    // unlock the buffer to let the driver know that you no longer need this buffer.
    fi.imageRequestUnlock( requestNr );

    cout << "Press [ENTER] to end the application" << endl;
    cin.get();
    return 0;
}
