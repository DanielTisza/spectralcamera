/*-----------------------------------------------------------
-- SingleCapture.cpp
--
-- g++ SingleCapture.cpp -I/opt/mvIMPACT_Acquire -L/opt/mvIMPACT_Acquire/lib/armhf -l mvDeviceManager -o SingleCapture
--
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
#ifdef _WIN32
#   define USE_DISPLAY
#   include <mvDisplay/Include/mvIMPACT_acquire_display.h>
using namespace mvIMPACT::acquire::display;
#endif // #ifdef _WIN32

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

#ifdef USE_DISPLAY
    cout << "Please note that there will be just one refresh for the display window, so if it is" << endl
         << "hidden under another window the result will not be visible." << endl;
    // everything went well. Display the result
    ImageDisplayWindow display( "mvIMPACT_acquire sample" );
    display.GetImageDisplay().SetImage( pRequest );
    display.GetImageDisplay().Update();
#endif // USE_DISPLAY
    cout << "Image captured(" << pRequest->imagePixelFormat.readS() << " " << pRequest->imageWidth.read() << "x" << pRequest->imageHeight.read() << ")" << endl;

    // unlock the buffer to let the driver know that you no longer need this buffer.
    fi.imageRequestUnlock( requestNr );

    cout << "Press [ENTER] to end the application" << endl;
    cin.get();
    return 0;
}
