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
		read_done_c : in std_logic;

		-- Writing channel signals
		write_ready : in std_logic;
		write_ena : out std_logic;
		write_addr : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		write_data : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);

		-- Pipeline calculation result
		-- 4 RGB pixels with double precision floating point values
		-- 12 * 64-bit data
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

	-- Destination data to DDR memory
	signal write_addr_int : unsigned(C_M_AXI_ADDR_WIDTH-1 downto 0);
	signal write_ena_int : std_logic;

	signal pipelinedelay : unsigned(9 downto 0);

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

	signal rowIdx : unsigned(10 downto 0);
	signal colIdx : unsigned(11 downto 0);
	signal hsync_ena : std_logic;
	signal vsync_ena : std_logic;

	-- Sequence
	signal writeseqstatebits : std_logic_vector(7 downto 0);
	signal writeseq_done_int : std_logic;
	signal writenext_ena : std_logic;
	signal writecounter : unsigned(3 downto 0);

	-- Single write
	signal writestatebits : std_logic_vector(7 downto 0);
	signal writenext_done : std_logic;

	signal capture_ena : std_logic;

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

			pipelinedelay <= to_unsigned(0, 10);

			-- Writing channel signals
			write_addr_int <= to_unsigned(0, C_M_AXI_ADDR_WIDTH);
			write_ena_int <= '0';

			firstrowhandled <= '0';
			readrowodd <= '0';

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

			rowIdx <= to_unsigned(0,11);
			colIdx <= to_unsigned(0,12);
			hsync_ena <= '0';
			vsync_ena <= '0';

			writeseqstatebits <= "00000001";
			writeseq_done_int <= '0';
			writenext_ena <= '0';
			writecounter <= to_unsigned(0, 4);

			writestatebits <= "00000001";
			writenext_done <= '0';

			capture_ena <= '0';

		else

			if (clk'event and clk='1') then

				-- Destination data to DDR memory
				write_addr_int <= write_addr_int;
				write_ena_int <= '0';

				firstrowhandled <= firstrowhandled;
				readrowodd <= readrowodd;

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

				rowIdx <= rowIdx;
				colIdx <= colIdx;
				hsync_ena <= '0';
				vsync_ena <= '0';

				writeseqstatebits <= writeseqstatebits;
				writeseq_done_int <= '0';
				writenext_ena <= '0';
				writecounter <= writecounter;

				writestatebits <= writestatebits;
				writenext_done <= '0';

				pipelinedelay <= pipelinedelay;
				capture_ena <= '0';

				--------------------------------------
				-- Pipeline delay counter
				--------------------------------------

				-- Counter is reloaded when latest data is made available to
				-- pipeline at pipeline input.
				--
				-- When pipeline counter reaches 1, then pipeline processing
				-- has completed and processed data is available at 
				-- pipeline output.

				if (read_done_c='1') then
					pipelinedelay <= to_unsigned(16,10);
				else

					if (pipelinedelay > to_unsigned(0,10)) then
						pipelinedelay <= pipelinedelay - to_unsigned(1,10);
					else
					end if;

				end if;

				if (pipelinedelay = to_unsigned(1,10)) then
					capture_ena <= '1';
				else
				end if;

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
				-- Write sequence for 12 writes
				--------------------------------------
				case writeseqstatebits is

					when "00000001" =>

						-- Initial state
						-- Prepare to write 12 times
						-- Waiting for data to arrive from pipeline

						writecounter <= to_unsigned(12, 4);

						if (capture_ena='1') then
							writenext_ena <= '1';
							writeseqstatebits <= "00000010";
						else
						end if;

					when "00000010" =>

						-- Write is in progress,
						-- waiting for writing to complete
						if (writenext_done='1') then
							writecounter <= writecounter - to_unsigned(1, 4);
							writeseqstatebits <= "00000100";
						else
						end if;

					when "00000100" =>

						-- Check if need to write more
						-- or stop writing
						if (writecounter = to_unsigned(0,4)) then
							writeseqstatebits <= "00000001";
						else
							writenext_ena <= '1';
							writeseqstatebits <= "00000010";
						end if;

					when others =>
						null;

				end case;

				--------------------------------------
				-- Single write to memory
				--------------------------------------
				case writestatebits is

					when "00000001" =>

						-- Initial state
						-- Waiting for trigger to write next data
						if (writenext_ena='1') then
							writestatebits <= "00000010";
						else
						end if;

					when "00000010" =>

						-- Request write
						if (write_ready='1') then
							write_ena_int <= '1';
							writestatebits <= "00000100";
						else
						end if;

					when "00000100" =>

						-- Write started
						if (write_ready='0') then
							writenext_done <= '1';
							writestatebits <= "00000001";
						else
						end if;

					when others =>
						null;

				end case;


				--------------------------------------
				-- Prepare data to write
				--------------------------------------

				-- Make 144 bits shift register where 
				-- highest 64-bits connected to write port

				if (writenext_done='1') then

					pix1r <= pix1g;
					pix1g <= pix1b;
					pix1b <= pix2r;
					pix2r <= pix2g;
					pix2g <= pix2b;
					pix2b <= pix3r;
					pix3r <= pix3g;
					pix3g <= pix3b;
					pix3b <= pix4r;
					pix4r <= pix4g;
					pix4g <= pix4b;
					-- pix4b <= pix4b;
				else
				end if;


				--------------------------------------
				-- Column index and row index for write address
				--------------------------------------

				-- Increment column index or
				-- reset column index when maximum reached
				if (writenext_done='1') then

					-- 2590 pixels / 4 pixels per 64 bits transfer
					-- 2590/4 = 647.5 = 648
					if (colIdx=to_unsigned(648,12)) then
						colIdx <= to_unsigned(0,12);
						hsync_ena <= '1';
					else
						colIdx <= colIdx + to_unsigned(1,12);
					end if;

				else
				end if;

				-- Increment row index or
				-- reset row index when maximum reached
				if (hsync_ena='1') then

					if (rowIdx=to_unsigned(1942,11)) then
						rowIdx <= to_unsigned(0,11);
						vsync_ena <= '1';
					else
						rowIdx <= rowIdx + to_unsigned(1,11);
					end if;
					
				else 
				end if;

			else
			end if;
			
		end if;

	end process;

	--
	-- Continuous connections
	--

	-- Write channel signals
	write_addr <= std_logic_vector(write_addr_int);
	write_data <= std_logic_vector(pix1r);
	write_ena <= write_ena_int;
	
end architecture;
