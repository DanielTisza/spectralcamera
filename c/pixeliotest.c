/*-----------------------------------------------------------
-- pixeliotest.c
--
-- Testing access to reserved DDR memory area for pixelio in FPGA
--
-- Copyright: Daniel Tisza, 2022, GPLv3 or later
--
-- gcc pixeliotest.c -o pixelio
--
-----------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <stdint.h>

int main()
{
	off_t 			ram_pbase = 0x3C000000;
	unsigned int 	ram_size = 0x4000000;
	uint64_t *		ram_vptr;
	int 			fd;
	uint8_t *		pShared;
	uint32_t		ii;
	uint64_t		newValue;

	if ((fd = open("/dev/mem", O_RDWR | O_SYNC)) != -1) {

		ram_vptr = (uint64_t *)mmap(
			NULL, 
			ram_size, 
			PROT_READ | PROT_WRITE, 
			MAP_SHARED, 
			fd, 
			ram_pbase
		);

		
		//Read from DDR reserved area
		printf("\r\n");
		printf("Reading value from reserved DDR at address (0x3C000000 + 0x8): [%llX]\r\n", ram_vptr[1]);

		//Write to DDR reserved area

		newValue = 0x12345678;
		printf("\r\n");
		printf("Writing value to DDR reserved area at address (0x3C000000 + 0x8): [%llX]\r\n", newValue);
		ram_vptr[1] = newValue;

		//Read back data written to DDR reserved area
		printf("\r\n");
		printf("Reading value from reserved DDR at address (0x3C000000 + 0x8): [%llX]\r\n", ram_vptr[1]);
		printf("\r\n");

		//Read data from DDR reserved area

		printf("\r\n");

		pShared = (uint8_t *)ram_vptr;

		for (ii=0;ii<16;ii++) {

			printf(
				"Reading from DDR reserved area at address (0x3C000000 + %d): [%X]\r\n",
				ii,
				pShared[ii]
			);

			//pShared[ii] = 0xA5;
		}
		
		printf("\r\n");


		close(fd);
	}
 }
