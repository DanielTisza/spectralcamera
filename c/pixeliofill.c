/*-----------------------------------------------------------
-- pixeliofill.c
--
-- Testing access to reserved DDR memory area for pixelio in FPGA
--
-- Copyright: Daniel Tisza, 2022, GPLv3 or later
--
-- gcc pixeliofill.c -o pixeliofill
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
	uint8_t *		ram_vptr;
	int 			fd;
	uint8_t *		pShared;
	uint32_t		ii;
	uint64_t		newValue;

	if ((fd = open("/dev/mem", O_RDWR | O_SYNC)) != -1) {

		ram_vptr = (uint8_t *)mmap(
			NULL, 
			ram_size, 
			PROT_READ | PROT_WRITE, 
			MAP_SHARED, 
			fd, 
			ram_pbase
		);

		/*
		 * Fill all buffers with zero
		 */
		uint64_t *pSrc1A = (uint64_t *)&ram_vptr[0]; //(uint64_t *)1006632960; //0x0000 0000 3C00 0000
		uint64_t *pSrc1B = (uint64_t *)&ram_vptr[(1006638140 - 1006632960)]; //0x0000 0000 3C00 143C

		uint64_t *pSrc2A = (uint64_t *)&ram_vptr[(1021749504 - 1006632960)]; //0x0000 0000 3CE6 A900
		uint64_t *pSrc2B = (uint64_t *)&ram_vptr[(1021754684 - 1006632960)]; //0x0000 0000 3CE6 BD3C
		
		uint64_t *pSrc3A = (uint64_t *)&ram_vptr[(1036866048 - 1006632960)]; //0x0000 0000 3DCD 5200
		uint64_t *pSrc3B = (uint64_t *)&ram_vptr[(1036871228 - 1006632960)]; //0x0000 0000 3DCD 663C

		printf("\r\n");
		printf("pSrc1A: [%llX]\r\n", (uint64_t)pSrc1A);
		printf("pSrc1A[0]: [%llX]\r\n", pSrc1A[0]);

		printf("\r\n");
		printf("pSrc1B: [%llX]\r\n", (uint64_t)pSrc1B);
		printf("pSrc1B[0]: [%llX]\r\n", pSrc1B[0]);

		/*
		 * Filling with 1's gives 0x6 = 6 (1 * 6, ok)
		 * Filling with 2's gives 0xC = 12 (2 * 6, ok)
		 */
		for (ii=0;ii<45349631;ii++) {
			ram_vptr[ii] = 1;
		}

		printf("\r\n");

		//for (ii=0;ii<45349631;ii++) {
		for (ii=0;ii<32;ii++) {

			printf("Reading value from reserved DDR at address (0x3EB3FB00): [%X]\r\n", ram_vptr[45349632 + ii]);
		}

		printf("\r\n");

//0x3eddec70 - 0x3C000000 = 48098416, this gives 0



		/*
		 * Number of 64-bit (8 byte) transfers is 1257444
		 */
		/*
		for (ii=0;ii<125444;ii++) {

			*pSrc1A++ = 0;
			*pSrc1B++ = 0;

			*pSrc2A++ = 0;
			*pSrc2B++ = 0;

			*pSrc3A++ = 0;
			*pSrc3B++ = 0;
		}
		*/


		//Read back data written to DDR reserved area

		/*
		uint64_t *pRes = (uint64_t *)&ram_vptr[(1051982592 - 1006632960)]; //0x3EB3 FB00

		printf("\r\n");
		printf("Reading value from reserved DDR at address (0x3EB3 FB00): [%llX]\r\n", pRes[0]);
		printf("\r\n");
		*/


		close(fd);
	}
 }
