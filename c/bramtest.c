/*-----------------------------------------------------------
-- bramtest.c
--
-- FPGA BRAM testing program
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
	off_t 			bram_pbase = 0x81000000;
	unsigned int 	bram_size = 0x8000;
	uint32_t *		bram_vptr;
	int 			fd;

	if ((fd = open("/dev/mem", O_RDWR | O_SYNC)) != -1) {

		bram_vptr = (uint32_t *)mmap(
			NULL, 
			bram_size, 
			PROT_READ | PROT_WRITE, 
			MAP_SHARED, 
			fd, 
			bram_pbase
		);

		//Read from BRAM located in FPGA
		//Current FPGA pixel processor writes value 0x1234ABCD to this location
		printf("\r\n");
		printf("Reading value from FPGA shared BRAM at address 0x0: %X\r\n", bram_vptr[0]);

		//Test writing to BRAM located in FPGA
		//Write to BRAM located in FPGA
		printf("\r\n");
		printf("Writing value 0xAABBCCDD to FPGA shared BRAM at address 0x1\r\n");
		bram_vptr[1] = 0xAABBCCDD;

		//Read back data written to BRAM located in FPGA
		printf("\r\n");
		printf("Reading back value 0xAABBCCDD from FPGA shared BRAM at address 0x1%X\r\n", bram_vptr[1]);
		printf("\r\n");

		close(fd);
	}
 }
