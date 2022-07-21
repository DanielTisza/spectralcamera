/*-----------------------------------------------------------
-- capturedrm.cpp
--
-- Capture image and display it using libdrm
-- with RGB888 pixel format
--
-- Inspired by SingleCapture.cpp
-- Inspired by https://waynewolf.github.io/code/post/kms-pageflip.c
--
-- g++ capturedrm.cpp -I/opt/mvIMPACT_Acquire -L/opt/mvIMPACT_Acquire/lib/armhf -l mvDeviceManager -I/usr/include/libdrm -l drm -o capturedrm
--
-- Copyright: Daniel Tisza, 2022, GPLv3 or later
-----------------------------------------------------------*/

#define _FILE_OFFSET_BITS 64

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

using namespace mvIMPACT::acquire;
using namespace std;

void initDrmDisplay(void);
void closeDrmDisplay(void);

void takeImageAndDraw(
	Device *				pDev,
	FunctionInterface		fi,
	uint8_t *				pBuf
);

int 							fdDrm;
drmModeRes *					resources;
drmModeConnector *				connector;
struct drm_mode_create_dumb		creq;
drmModeCrtcPtr					orig_crtc;
void *							pMap;


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

//-----------------------------------------------------------------------------
int main( void )
//-----------------------------------------------------------------------------
{
    int             fd;
    DeviceManager	devMgr;

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
	 * Enter loop taking images
	 */
	while (1) {
		
		char		userCmd;

		/*
		 * Take image and draw to display
		 */
		takeImageAndDraw(pDev, fi, (uint8_t *)pMap);

		/*
		 * Handle user commands
		 */
		cout << "Press space key to take image" << endl;
		cout << "Press 'q' key to end application" << endl;

		scanf("%c", &userCmd);

		switch (userCmd) {
			default:
				break;
		}

		if (userCmd == 'q') {
			break;
		}
	}

	closeDrmDisplay();

    return 0;
}

/***************************************************************************//**
 *
 *	\brief		Take image and draw to display
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
/*------------------------------------------------------------------------------
 * 
 *
 *
 *
**----------------------------------------------------------------------------*/
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

/*------------------------------------------------------------------------------
 * 
 *
 *
 *
**----------------------------------------------------------------------------*/
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