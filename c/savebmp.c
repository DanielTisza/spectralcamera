/*-----------------------------------------------------------
-- savebmp.c
--
-- Test saving BMP file
--
-- Inspired by https://stackoverflow.com/a/55504419
--
-- cl savebmp.c
-- gcc savebmp.c -o savebmp
--
-- Copyright: Daniel Tisza, 2022, GPLv3 or later
-----------------------------------------------------------*/


/*------------------------------------------------------------------------------
 * Includes
 *----------------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef _MSC_VER

typedef __int8 int8_t;
typedef unsigned __int8 uint8_t;
typedef __int16 int16_t;
typedef unsigned __int16 uint16_t;
typedef __int32 int32_t;
typedef unsigned __int32 uint32_t;
typedef __int64 int64_t;
typedef unsigned __int64 uint64_t;

#else
#include <stdint.h>
#endif

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

	paddingSize = (4 - (pitch) % 4) % 4;

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
	 */
	for (i = 0; i < height; i++) {

		/*
		 * Pixel row
		 */
		fwrite(
			pBuf + (i * pitch),
			bytesPerPixel,
			width,
			imageFile
		);
		
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
void main(
	int						argc,
	char					argv[]
) {
	uint32_t				pitchBytes;
	uint32_t				width;
	uint32_t				height;
	uint8_t *				pBuf;
	long 					ii;
	long 					jj;
	long					nBytes;

	pitchBytes = 2700 * 3;
	width = 2592;
	height = 1944;

	nBytes = pitchBytes * height;

	pBuf = (uint8_t *)malloc(nBytes);
	
	if (pBuf) {

		uint8_t *				pTmp;

		pTmp = pBuf;

		/*
		 * Fill with color
		 */
		for (ii=0;ii<height;ii++) {

			for (jj=0;jj<width;jj++) {

				*pTmp++ = 0; //blue
				*pTmp++ = 0; //green
				*pTmp++ = 200;  //red
			}

			pTmp += (pitchBytes - (width * 3));			
		}

		saveBitmapImage(
			(unsigned char *)pBuf, 
			(int)height, 
			(int)width, 
			(int)pitchBytes, 
			"test.bmp"
		);
	}

	printf("Exiting program\r\n");
}
