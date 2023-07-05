-----------------------------------------------------------
-- rgbwrite.vhd
--
-- Rgbwrite
--
-- Copyright: Daniel Tisza, 2023, GPLv3 or later
--
-- ghdl -a -v rgbwrite.vhd
-- ghdl -e -v rgbwrite
-- ghdl -r rgbwrite --vcd=out.vcd
-- gtkwave
--
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Describe the I/O of this "chip"
entity rgbwrite is

	generic(
		C_M_AXI_ADDR_WIDTH	: integer	:= 32;
		C_M_AXI_DATA_WIDTH	: integer	:= 64
	);

	port (

		-- Clock and reset
		clk : in std_logic;
		resetn	: in std_logic;

		-- Input data signals
		imgsync_ena : in std_logic;
		hsync_ena : in std_logic;
		vsync_ena : in std_logic;

		-- Writing channel signals
		write_ready : in std_logic;
		write_ena : out std_logic;
		write_addr : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		write_data : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);

		-- Step 1 calculation result
		res1pix1r : in unsigned(63 downto 0);
		res1pix1g : in unsigned(63 downto 0);
		res1pix1b : in unsigned(63 downto 0);
		res1pix2r : in unsigned(63 downto 0);
		res1pix2g : in unsigned(63 downto 0);
		res1pix2b : in unsigned(63 downto 0);
		res1pix3r : in unsigned(63 downto 0);
		res1pix3g : in unsigned(63 downto 0);
		res1pix3b : in unsigned(63 downto 0);
		res1pix4r : in unsigned(63 downto 0);
		res1pix4g : in unsigned(63 downto 0);
		res1pix4b : in unsigned(63 downto 0)
	);

end rgbwrite;

-- Describe the contents of this "chip"
architecture rtl of rgbwrite is

	-- Direct read
	signal src2A : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal src3A : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);

	-- Delayed signals
	signal src1B : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal src2B : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal src3B : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);

	-- Computations
	signal result2 : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal result3 : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);

	-- Destination data to DDR memory
	signal write_addr_int : unsigned(C_M_AXI_ADDR_WIDTH-1 downto 0);
	signal write_data_int : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal write_ena_int : std_logic;

	signal pipelinedelay : std_logic_vector(3 downto 0);
	signal dstoffset : unsigned(23 downto 0);	

	signal firstrowhandled : std_logic;
	signal readrowodd : std_logic;

	signal pix1r : unsigned(63 downto 0);
	signal pix1g : unsigned(63 downto 0);
	signal pix1b : unsigned(63 downto 0);
	signal pix2r : unsigned(63 downto 0);
	signal pix2g : unsigned(63 downto 0);
	signal pix2b : unsigned(63 downto 0);
	signal pix3r : unsigned(63 downto 0);
	signal pix3g : unsigned(63 downto 0);
	signal pix3b : unsigned(63 downto 0);
	signal pix4r : unsigned(63 downto 0);
	signal pix4g : unsigned(63 downto 0);
	signal pix4b : unsigned(63 downto 0);

begin
    
	------------------------------------------
	-- IO process
	------------------------------------------
	io_proc : process(
		clk,
		resetn
	)
	begin

		if (resetn='0') then

			-- Direct read
			src2A <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			src3A <= to_unsigned(0, C_M_AXI_DATA_WIDTH);

			-- Delayed signals
			src1B <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			src2B <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			src3B <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			
			-- Computations
			result2 <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			result3 <= to_unsigned(0, C_M_AXI_DATA_WIDTH);

			pipelinedelay <= (others => '0');
			dstoffset <= to_unsigned(0, 24);

			-- Writing channel signals
			write_addr_int <= to_unsigned(0, C_M_AXI_ADDR_WIDTH);
			write_data_int <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			write_ena_int <= '0';

			firstrowhandled <= '0';
			readrowodd <= '0';

			-- Pipeline processing delay shift register trigger
			pipelinedelay <= (others => '0');

			pix1r <= to_unsigned(0, 64);
			pix1g <= to_unsigned(0, 64);
			pix1b <= to_unsigned(0, 64);
			pix2r <= to_unsigned(0, 64);
			pix2g <= to_unsigned(0, 64);
			pix2b <= to_unsigned(0, 64);
			pix3r <= to_unsigned(0, 64);
			pix3g <= to_unsigned(0, 64);
			pix3b <= to_unsigned(0, 64);
			pix4r <= to_unsigned(0, 64);
			pix4g <= to_unsigned(0, 64);
			pix4b <= to_unsigned(0, 64);

		else

			if (clk'event and clk='1') then

				-- Direct read
				src2A <= src2A;
				src3A <= src3A;

				-- Delayed signals
				src1B <= src1B;
				src2B <= src2B;
				src3B <= src3B;

				-- Computations
				result2 <= src2A + src2B;
				result3 <= src3A + src3B;

				-- Destination data to DDR memory
				write_addr_int <= write_addr_int;
				write_data_int <= result2 + result3;
				write_ena_int <= '0';

				pipelinedelay <= pipelinedelay(pipelinedelay'length-2 downto 0) & pipelinedelay(pipelinedelay'length-1);
				dstoffset <= dstoffset;

				firstrowhandled <= firstrowhandled;
				readrowodd <= readrowodd;

				-- Pipeline processing delay shift register trigger
				pipelinedelay <= pipelinedelay(pipelinedelay'length-2 downto 0) & '0';

				pix1r <= pix1r;
				pix1g <= pix1g;
				pix1b <= pix1b;
				pix2r <= pix2r;
				pix2g <= pix2g;
				pix2b <= pix2b;
				pix3r <= pix3r;
				pix3g <= pix3g;
				pix3b <= pix3b;
				pix4r <= pix4r;
				pix4g <= pix4g;
				pix4b <= pix4b;

				-- if (read_done_img2_delayed='1') then

					-- Last data read for pipeline processing
					-- Trigger writing after pipeline delay
					-- pipelinedelay <= pipelinedelay(pipelinedelay'length-2 downto 0) & '1';

				-- else
				-- end if;

				-- Result image RGB pixels with double-precision floating point
				-- has 64-bit pixels (8 bytes)
				--
				-- For 4 pixels need to write
				-- 4 * 3 * 64-bits = 144 bits (96 bytes)
				--
				-- Can write 64-bits at a time
				-- (4*3*64-bits) / 64-bits = 12
				-- So 12 transfers are needed to write back processed pixel data
				-- in double-precision floating point format
				--
				-- Spectral camera module resolution
				-- 2592 x 1944				
				-- 2592 pixels * 8 bytes = 20736 (0x5100)
				-- 2592 * 1944 * 8 bytes = 40310784 bytes

				-- Boxed camera module resolution
				-- 2590 x 1942
				-- 2590 pixels * 8 bytes = 20720 (0x50F0)
				-- 2590 * 1942 * 8 bytes = 40238240 bytes

				-- Result image
				-- 3EB3FB00		first row

				-- Write address is:
				--		3EB3FB00 + (rowIdx * rowBytes) + (colIdx * 8 bytes)
				--
				-- where
				--		imgBase		= 1006632960 = 0x3C000000	(32 bits)
				--		imgIdx 		= 0...2						(2 bits)
				--		imgSize 	= 15116544 bytes = 0xE6A900
				--		rowIdx 		= 0...1941					(11 bits)
				--		rowBytes	= 20720 bytes = 0x50F0
				--		colIdx		= 0...2589					(12 bits)

				write_addr_int <= 		to_unsigned(1051982592, C_M_AXI_ADDR_WIDTH)	--X"3EB3FB00"
									+ 	rowIdx * to_unsigned(20720, 15)
									+	colIdx * to_unsigned(8, 4);

				--------------------------------------
				-- Wait for pipeline data to become available
				--------------------------------------
				if (pipelinedelay(pipelinedelay'length-1)='1') then

					-- Capture the result from pipeline
					-- Request write1
					-- Request write2
					-- Request write3

					-- Make 144 bits shift register where highest 64-bits connected
					-- to write port

					-- Wait for write interface to be available
					if (write_ready='1') then

						-- Set address and request write
						write_addr_int <= to_unsigned(1051982592, C_M_AXI_ADDR_WIDTH) + dstoffset; --X"3EB3FB00"
						write_ena_int <= '1';

						-- Calculate offset for next write address
						dstoffset <= dstoffset + to_unsigned(8, 4);

						-- Detect when all data has been written
						if (dstoffset=to_unsigned(10059552, 24)) then  --X"997F20"
							dstoffset <= to_unsigned(0, 24);
						else
						end if;

					else

						-- This is fatal error, if pipeline data has arrived
						-- but writing is not available.
					end if;
					
				else
				end if;

				--if (write_req1='1') then
				--else
				--end if;


			else		
			end if;
			
		end if;

	end process;

	--
	-- Continuous connections
	--

	-- Write channel signals
	write_addr <= std_logic_vector(write_addr_int);
	write_data <= std_logic_vector(write_data_int);
	write_ena <= write_ena_int;
	
end architecture;
