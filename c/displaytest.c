/*-----------------------------------------------------------
-- displaytest.c
--
-- Displayport display framebuffer testing program
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
	uint32_t		width;
	uint32_t		height;
	uint32_t		col;
	uint32_t		row;
	uint8_t			data;
	ssize_t			bytesWritten;

	if ((fd = open("/dev/fb0", O_RDWR | O_SYNC)) != -1) {

		printf("\r\n");
		printf("Successfully opened /dev/fb0");
			
		width = 1280;
		height = 1024;

		for (row=0;row<height;row++) {
			
			for (col=0;col<width;col++) {
				
#if 0
				/*
				 * 512 with 16-bits seems to fill half of screen!
				 * 
				 * This fills with black
				 */
				 
				data = 0;					
				bytesWritten = write(fd, &data, 1);
				
				data = 0;
				bytesWritten = write(fd, &data, 1);
#endif
				
					
#if 0
				/*
				 * 512 with 16-bits seems to fill half of screen!
				 * 
				 * This fills with white
				 */
				 
				data = 255;					
				bytesWritten = write(fd, &data, 1);
				
				data = 255;
				bytesWritten = write(fd, &data, 1);
#endif
			
#if 0
				/*
				 * 512 with 16-bits seems to fill half of screen!
				 * 
				 * This fills with full yellow!
				 * This should have now green and blue components
				 */
				 
				data = 0;					
				bytesWritten = write(fd, &data, 1);
				
				data = 255;
				bytesWritten = write(fd, &data, 1);
#endif			

#if 0
				/*
				 * 512 with 16-bits seems to fill half of screen!
				 * 
				 * This fills with full green
				 */
				 
				data = 0;					
				bytesWritten = write(fd, &data, 1);
				
				data = 31<<1 | 1<<0;
				bytesWritten = write(fd, &data, 1);
#endif			

#if 0
				/*
				 * 512 with 16-bits seems to fill half of screen!
				 * 
				 * This fills with full red (little bluish?
				 */
				 
				data = 7<<0;					
				bytesWritten = write(fd, &data, 1);
				
				data = 3<<6 | 0<<1 | 1<<0;
				bytesWritten = write(fd, &data, 1);
#endif			

#if 0
				/*
				 * 512 with 16-bits seems to fill half of screen!
				 * 
				 * This fills with full blue
				 */
				 
				data = 31<<3 | 0<<0;					
				bytesWritten = write(fd, &data, 1);
				
				data = 0<<6 | 0<<1 | 1<<0;
				bytesWritten = write(fd, &data, 1);
#endif			
				
#if 0
				/*
				 * 512 with 16-bits seems to fill half of screen!
				 * 
				 * This fills with blue
				 */
				 
				data = 31<<3 | 0<<0;					
				bytesWritten = write(fd, &data, 1);
				
				data = 0<<6 | 0<<1 | 0<<0;
				bytesWritten = write(fd, &data, 1);
#endif			

#if 0
				/*
				 * 512 with 16-bits seems to fill half of screen!
				 * 
				 * This fills with bright blue
				 */
				 
				data = 1<<7 | 31<<2 | 0<<0;					
				bytesWritten = write(fd, &data, 1);
				
				data = 0<<6 | 0<<1 | 0<<0;
				bytesWritten = write(fd, &data, 1);
#endif			

#if 0
				/*
				 * 512 with 16-bits seems to fill half of screen!
				 * 
				 * This fills with bright red
				 */
				 
				data = 1<<7 | 0<<2 | 3<<0;
				bytesWritten = write(fd, &data, 1);
				
				data = 7<<5 | 0<<0;
				bytesWritten = write(fd, &data, 1);
#endif			

#if 0
				/*
				 * 512 with 16-bits seems to fill half of screen!
				 * 
				 * This fills with bright green
				 */
				 
				data = 1<<7 | 0<<2 | 0<<0;
				bytesWritten = write(fd, &data, 1);
				
				data = 0<<5 | 31<<0;
				bytesWritten = write(fd, &data, 1);
#endif			


#if 0
				/*
				 * Format seems to be
				 * ABRG
				 * 
				 * | A B R | R G |
				 * | 1 5 2 | 3 5 |
				 */
				 
				 if (row < 300) {
					 
					data = 1<<7 | 31<<2 | 0<<0;					
					bytesWritten = write(fd, &data, 1);
					
					data = 0<<6 | 0<<1 | 0<<0;
					bytesWritten = write(fd, &data, 1);
					 
				 } else if (row < 600) {
					 
					data = 1<<7 | 0<<2 | 3<<0;
					bytesWritten = write(fd, &data, 1);
					
					data = 7<<5 | 0<<0;
					bytesWritten = write(fd, &data, 1);
					 
				 } else {
					 
					data = 1<<7 | 0<<2 | 0<<0;
					bytesWritten = write(fd, &data, 1);
					
					data = 0<<5 | 31<<0;
					bytesWritten = write(fd, &data, 1);
				 }
#endif

#if 1
				/*
				 * Format seems to be
				 * ABRG
				 * 
				 * | A B R | R G |
				 * | 1 5 2 | 3 5 |
				 */
				 
				 if (row < 200) {
					 
					data = 1<<7 | 31<<2 | 0<<0;					
					bytesWritten = write(fd, &data, 1);
					
					data = 0<<6 | 0<<1 | 0<<0;
					bytesWritten = write(fd, &data, 1);
					 
				 } else if (row < 400) {
					 
					data = 1<<7 | 0<<2 | 3<<0;
					bytesWritten = write(fd, &data, 1);
					
					data = 7<<5 | 0<<0;
					bytesWritten = write(fd, &data, 1);
					 
				 } else if (row < 600) {
					 
					data = 1<<7 | 0<<2 | 0<<0;
					bytesWritten = write(fd, &data, 1);
					
					data = 0<<5 | 31<<0;
					bytesWritten = write(fd, &data, 1);

				 } else if (row < 800) {
					 
					data = 1<<7 | 0<<2 | 0<<0;
					bytesWritten = write(fd, &data, 1);
					
					data = 0<<5 | 0<<0;
					bytesWritten = write(fd, &data, 1);
					
				 } else {
					 
					data = 1<<7 | 31<<2 | 3<<0;
					bytesWritten = write(fd, &data, 1);
					
					data = 7<<5 | 31<<0;
					bytesWritten = write(fd, &data, 1);
				 } 
#endif
				
			}
		}
		
		printf("\r\n");
		printf("Finished writing to framebuffer!");

		close(fd);
	}
 }
