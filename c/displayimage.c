/*-----------------------------------------------------------
-- displayimage.c
--
-- Displayport display framebuffer image drawing program
--
-- Copyright: Daniel Tisza, 2022, GPLv3 or later
-----------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <stdint.h>

int main()
{
	int 			fd;
	int				fdImg;
	uint32_t		width;
	uint32_t		height;
	uint32_t		col;
	uint32_t		row;
	uint8_t			data;
	ssize_t			bytesWritten;
	
	uint8_t			imgRed;
	uint8_t			imgGreen;
	uint8_t			imgBlue;
	uint32_t		leftoffset;

	if ((fd = open("/dev/fb0", O_RDWR | O_SYNC)) != -1) {

		printf("\r\n");
		printf("Successfully opened /dev/fb0");
			
		if ( (fdImg = open("test.dat", O_RDWR)) != -1) {
			
			/*
			 * Image size
			 * 2592 x 1944
			 * 
			 * Screen size
			 * 1280 x 1024
			 */
			width = 2592;	//1280; 
			height = 1944;	//1024;
			
			leftoffset = 0; //700;

			for (row=0;row<height;row++) {
				
				for (col=0;col<width;col++) {
					
					/*
					 * Read every pixel from file
					 */
					read(fdImg, &imgRed, 1);
					read(fdImg, &imgGreen, 1);
					read(fdImg, &imgBlue, 1);
					  
					 
					if (	col >= leftoffset 
						&&	col < (leftoffset + 1280)
						&&	row >= 0
						&& 	row < (0 + 1024)
					) {
						
						/*
						 * Draw pixel to screen
						 * 
						 * Format seems to be
						 * ABRG
						 * 
						 * | A B R | R G |
						 * | 1 5 2 | 3 5 |
						 * 
						 */
						data =	1<<7
							|	(imgBlue>>3) << 2
							|	(imgRed>>6)<<0;
							
						bytesWritten = write(fd, &data, 1);
							
						data =	((imgRed>>3) & 0x7) << 5
							|	(imgGreen>>3) << 0;
							
						bytesWritten = write(fd, &data, 1);
					}
					
				}
				
				/*
				 * Stop reading file when outside
				 * display row size
				 */
				if (row > 1024) {
					break;
				}
			}
			
			close(fdImg);
			
		}
		
		printf("\r\n");
		printf("Finished writing to framebuffer!");

		close(fd);
	}
 }
