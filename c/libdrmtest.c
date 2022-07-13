/*-----------------------------------------------------------
-- libdrmtest.c
--
-- Libdrm setting mode test
-- Based on https://waynewolf.github.io/code/post/kms-pageflip.c
--
-- gcc libdrmtest.c -I/usr/include/libdrm -l drm -o libdrmtest
--
-- Copyright: Daniel Tisza, 2022, GPLv3 or later
-----------------------------------------------------------*/

#define _FILE_OFFSET_BITS 64

//#include <iostream>
//using namespace std;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <termios.h>
#include <fcntl.h>
#include <errno.h>
#include <math.h>
#include <xf86drm.h>
#include <xf86drmMode.h>
//#include <libkms.h>
//#include <cairo.h>
#include <sys/mman.h>


int main(int argc, char *argv[])
{
	int fd, pitch, bo_handle, fb_id, second_fb_id;
	drmModeRes *resources;
	drmModeConnector *connector;
	drmModeEncoder *encoder;
	drmModeModeInfo mode;
	drmModeCrtcPtr orig_crtc;
	//struct kms_driver *kms_driver;
	//struct kms_bo *kms_bo, *second_kms_bo;
	void *map_buf;
	int ret, i;
	
	/*
	 * Open DRM device
	 */

	fd = open("/dev/dri/card0", O_RDWR);

	if(fd < 0){
		printf("drmOpen failed: %s\n", strerror(errno));
		goto out;
	}

	resources = drmModeGetResources(fd);
	if(resources == NULL){
		printf("drmModeGetResources failed: %s\n", strerror(errno));
		goto close_fd;
	}

	/*
	 * Get first connected connector
	 */

	/* find the first available connector with modes */
	for(i=0; i < resources->count_connectors; ++i){

		connector = drmModeGetConnector(fd, resources->connectors[i]);

		if(connector != NULL){
			printf("connector %d found\n", connector->connector_id);
			if(connector->connection == DRM_MODE_CONNECTED
				&& connector->count_modes > 0)
				break;
			drmModeFreeConnector(connector);
		}
		else
			printf("get a null connector pointer\n");
	}
	if(i == resources->count_connectors){
		printf("No active connector found.\n");
		goto free_drm_res;
	}

	mode = connector->modes[0];
	printf("(%dx%d)\n", mode.hdisplay, mode.vdisplay);

	/*
	 * Find encoder matching selected connector
	 */

	/* find the encoder matching the first available connector */
	for(i=0; i < resources->count_encoders; ++i){

		encoder = drmModeGetEncoder(fd, resources->encoders[i]);

		if(encoder != NULL){
			printf("encoder %d found\n", encoder->encoder_id);
			if(encoder->encoder_id == connector->encoder_id);
				break;
			drmModeFreeEncoder(encoder);
		} else
			printf("get a null encoder pointer\n");
	}
	if(i == resources->count_encoders){
		printf("No matching encoder with connector, shouldn't happen\n");
		goto free_drm_res;
	}

	/*
	 * Create dumb buffer
	 */
{
	struct drm_mode_create_dumb		creq;
	struct drm_mode_map_dumb		mreq;

	struct drm_mode_destroy_dumb dreq;
	
	uint32_t fb;
	int ret;
	void *map;

	/* create dumb buffer */
	memset(&creq, 0, sizeof(creq));

	creq.width = 1280;
	creq.height = 1024;
	creq.bpp = 24; //32;

	ret = drmIoctl(
		fd,
		DRM_IOCTL_MODE_CREATE_DUMB,
		&creq
	);

	if (ret < 0) {
			/* buffer creation failed; see "errno" for more error codes */
			printf("buffer creation failed\n");
	}
	/* creq.pitch, creq.handle and creq.size are filled by this ioctl with
	* the requested values and can be used now. */

	/* create framebuffer object for the dumb-buffer */
	ret = drmModeAddFB(
		fd,
		1280,
		1024,
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
		fd,
		DRM_IOCTL_MODE_MAP_DUMB,
		&mreq
	);

	if (ret) {
			/* DRM buffer preparation failed; see "errno" */
			printf("DRM buffer preparation failed\n");
	}
	/* mreq.offset now contains the new offset that can be used with mmap() */

	/* perform actual memory mapping */
	map = mmap(
		0,						//addr
		creq.size,				//length
		PROT_READ | PROT_WRITE,	//prot
		MAP_SHARED,				//flags
		fd,						//fd
		mreq.offset				//offset
	);

	if (map == MAP_FAILED) {
			/* memory-mapping failed; see "errno" */
			printf("memory-mapping failed: %s\n", strerror(errno));
			printf("creq.size: %llu\n", creq.size);
			printf("fd: %d\n", fd);
			printf("mreq.offset: %llu\n", mreq.offset);
	}

	/* clear the framebuffer to 0 */
	printf("clear the framebuffer to 0\n");
	//memset(map, 0, creq.size);
	memset(map, 255, creq.size);

	orig_crtc = drmModeGetCrtc(
		fd,
		encoder->crtc_id
	);

	if (orig_crtc == NULL) {

		printf("orig_crtc is NULL!");
		//goto free_first_bo;

	} else {

		/* kernel mode setting, wow! */
		ret = drmModeSetCrtc(
					fd,
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
		} else {

			/*
			 * Start drawing!
			 */

			printf("Sleeping...");
			sleep(5);

		}

		/*
		 * Set back original crtc
		 */
		ret = drmModeSetCrtc(
			fd,
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
	}

	
}
	printf("Exiting...");


#if 0
free_second_fb:
	drmModeRmFB(fd, second_fb_id);
	
free_second_bo:
	kms_bo_destroy(&second_kms_bo);
	
free_first_fb:
	drmModeRmFB(fd, fb_id);
	
free_first_bo:
	kms_bo_destroy(&kms_bo);

free_kms_driver:
	kms_destroy(&kms_driver);
#endif

	
free_drm_res:
	drmModeFreeResources(resources);

close_fd:
	drmClose(fd);
	
out:
	return EXIT_SUCCESS;
}
