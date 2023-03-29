-----------------------------------------------------------
-- demosaic.vhd
--
-- Demosaic
--
-- Copyright: Daniel Tisza, 2022, GPLv3 or later
--
-- ghdl -a -v demosaic.vhd
-- ghdl -e -v demosaic
-- ghdl -r demosaic --vcd=out.vcd
-- gtkwave
--
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Describe the I/O of this "chip"
entity demosaic is

	generic(
		C_M_AXI_ADDR_WIDTH	: integer	:= 32;
		C_M_AXI_DATA_WIDTH	: integer	:= 64
	);

	port (

		-- Clock and reset
		clk : in std_logic;
		resetn	: in std_logic;

		-- Reading channel signals
		read_req : out std_logic;
		read_req_addr : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		read_done : in std_logic;
		read_data : in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);

		-- Writing channel signals
		write_ready : in std_logic;
		write_ena : out std_logic;
		write_addr : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		write_data : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0)
	);

end demosaic;

-- Describe the contents of this "chip"
architecture rtl of demosaic is

	-- Read channel signals 
	signal readstatebits : std_logic_vector(7 downto 0);
	signal read_req_int : std_logic;

	signal read_next_addr_ena : std_logic;
	signal read_first_addr_ena : std_logic;
	signal sourceselectstatebits : std_logic_vector(5 downto 0);

	signal AXI_ARADDR_int : unsigned(C_M_AXI_ADDR_WIDTH-1 downto 0);
	
	-- Source data from DDR memory
	signal src1A : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal src1B : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal src2A : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal src2B : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal src3A : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal src3B : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);

	-- Computations
	signal result1 : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal result2 : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal result3 : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);

	-- Destination data to DDR memory
	signal write_addr_int : unsigned(C_M_AXI_ADDR_WIDTH-1 downto 0);
	signal write_data_int : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal write_ena_int : std_logic;

	signal pipelinedelay : std_logic_vector(3 downto 0);
	signal dstoffset : unsigned(23 downto 0);

	signal imgIdx : unsigned(1 downto 0);
	signal imgIdxPrev : unsigned(1 downto 0);
	signal rowIdx : unsigned(10 downto 0);
	signal colIdx : unsigned(11 downto 0);
	signal read_next_addr : unsigned(C_M_AXI_ADDR_WIDTH-1 downto 0);

	signal imgsync_ena : std_logic;
	signal hsync_ena : std_logic;
	signal vsync_ena : std_logic;

	signal read_done_a : std_logic;
	signal read_done_b : std_logic;
	signal read_done_c : std_logic;

begin
	
	io_proc : process(
		clk,
		resetn
	)
	begin

		if (resetn='0') then

			-- Reading channel signals
			readstatebits <= "00000001";
			read_req_int <= '0';
			AXI_ARADDR_int <= to_unsigned(0, C_M_AXI_ADDR_WIDTH);

			read_next_addr_ena <= '0';
			read_first_addr_ena <= '0';
			sourceselectstatebits <= "000001";

			imgIdx <= to_unsigned(0,2);
			imgIdxPrev <= to_unsigned(0,2);
			rowIdx <= to_unsigned(0,11);
			colIdx <= to_unsigned(0,12);
			read_next_addr <= to_unsigned(0, C_M_AXI_ADDR_WIDTH);

			imgsync_ena <= '0';
			hsync_ena <= '0';
			vsync_ena <= '0';

			-- Source data from DDR memory
			src1A <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			src1B <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			src2A <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			src2B <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			src3A <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			src3B <= to_unsigned(0, C_M_AXI_DATA_WIDTH);

			-- Computations
			result1 <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			result2 <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			result3 <= to_unsigned(0, C_M_AXI_DATA_WIDTH);

			pipelinedelay <= (others => '0');
			dstoffset <= to_unsigned(0, 24);

			-- Writing channel signals
			write_addr_int <= to_unsigned(0, C_M_AXI_ADDR_WIDTH);
			write_data_int <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			write_ena_int <= '0';

			read_done_a <= '0';
			read_done_b <= '0';
			read_done_c <= '0';

		else

			if (clk'event and clk='1') then

				-- Read channel signals
				readstatebits <= readstatebits;
				read_req_int <= read_req_int;
				AXI_ARADDR_int <= AXI_ARADDR_int;

				read_next_addr_ena <= '0';
				read_first_addr_ena <= '0';
				sourceselectstatebits <= sourceselectstatebits;

				-- Source data from DDR memory
				src1A <= src1A;
				src1B <= src1B;
				src2A <= src2A;
				src2B <= src2B;
				src3A <= src3A;
				src3B <= src3B;

				-- Computations
				result1 <= src1A + src1B;
				result2 <= src2A + src2B;
				result3 <= src3A + src3B;

				-- Destination data to DDR memory
				write_addr_int <= write_addr_int;
				write_data_int <= result1 + result2 + result3;
				write_ena_int <= '0';

				pipelinedelay <= pipelinedelay(pipelinedelay'length-2 downto 0) & pipelinedelay(pipelinedelay'length-1);
				dstoffset <= dstoffset;

				imgIdx <= imgIdx;
				imgIdxPrev <= imgIdxPrev;
				rowIdx <= rowIdx;
				colIdx <= colIdx;

				imgsync_ena <= '0';
				hsync_ena <= '0';
				vsync_ena <= '0';

				read_done_a <= '0';
				read_done_b <= '0';
				read_done_c <= '0';

				--
				-- Spectral camera
				--
				-- 2592 x 1944
				-- 2592 pixels * 2 bytes = 5184 (0x1440) pitch bytes
				-- 5184 / 8 bytes = 648 transfers

				--
				-- Boxed camera module
				--
				-- 2590 x 1942
				-- 2590 pixels * 2 bytes = 5180 (0x143C) pitch bytes
				-- 5184 / 8 bytes = 647.5 transfers

				-- 0 - 1941 rows

				-- First row first pixel is green
				-- First row second pixel is blue
				-- Second row first pixel is red

				-- 0 - 2589 pixels
				
				--------------------------------------
				-- Capture read data and prepare next address
				--------------------------------------

				case readstatebits is

					-- Set read address
					when "00000001" =>

						AXI_ARADDR_int <= read_next_addr;
						read_req_int <= '1';
						read_next_addr_ena <= '1';
						readstatebits <= "00000010";

					-- Waiting for read done indication
					when "00000010" =>

						if (read_done='1') then

							read_req_int <= '0';

							-- Trigger writing after pipeline delay
							pipelinedelay <= pipelinedelay(pipelinedelay'length-2 downto 0) & '1';

							readstatebits <= "00000001";
						else
						end if;

					when others => 
						null;

				end case;


				-- Spectral camera module resolution
				-- 2592 x 1944
				-- 2592 pixels * 2 bytes = 5184 (0x1440)

				-- Boxed camera module resolution
				-- 2590 x 1942
				-- 2590 pixels * 2 bytes = 5180 (0x143C)

				-- First source image
				-- 3C000000		first row
				-- 3C00143C		second row

				-- Second source image
				-- 3CE6A900		first row
				-- 3CE6BD3C		second row

				-- Third source image
				-- 3DCD5200		first row
				-- 3DCD663C		second row

				-- Read address is:
				--		3C000000 + (imgIdx * imgBytes) + (rowIdx * rowBytes) + (colIdx * 8 bytes)
				--
				-- where
				--		imgBase		= 1006632960 = 0x3C000000	(32 bits)
				--		imgIdx 		= 0...2						(2 bits)
				--		imgSize 	= 15116544 bytes = 0xE6A900
				--		rowIdx 		= 0...1941					(11 bits)
				--		rowBytes	= 5180 bytes = 0x143C
				--		colIdx		= 0...2589					(12 bits)

				read_next_addr <= 		to_unsigned(1006632960, C_M_AXI_ADDR_WIDTH)
									+	imgIdx * to_unsigned(15116544, 24)
									+ 	rowIdx * to_unsigned(5180, 13)
									+	colIdx * to_unsigned(8, 4);

				-- Increment image index or
				-- reset image index when maximum reached
				if (read_next_addr_ena='1') then

					imgIdxPrev <= imgIdx;

					if (imgIdx=to_unsigned(2,2)) then
						imgIdx <= to_unsigned(0,2);
						imgsync_ena <= '1';
					else
						imgIdx <= imgIdx + to_unsigned(1,2);
					end if;

				else
				end if;

				-- Increment column index or
				-- reset column index when maximum reached
				if (imgsync_ena='1') then

					if (colIdx=to_unsigned(2590,12)) then
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

				-- Convert read_done to image-specific read_done signal
				if (read_done='1') then

					if (imgIdxPrev=to_unsigned(0,2)) then
						read_done_a <= '1';
					else
					end if;

					if (imgIdxPrev=to_unsigned(1,2)) then
						read_done_b <= '1';
					else
					end if;

					if (imgIdxPrev=to_unsigned(2,2)) then
						read_done_c <= '1';
					else
					end if;

				else
				end if;

				-- Capture image read data 
				if (read_done_a='1') then
					src1A <= unsigned(read_data);
				else
				end if;

				if (read_done_b='1') then
					src2A <= unsigned(read_data);
				else
				end if;

				if (read_done_c='1') then
					src3A <= unsigned(read_data);
				else
				end if;


				--if (read_next_addr_ena='1' or read_done='1') then
				--	sourceselectstatebits <= sourceselectstatebits(sourceselectstatebits'length-2 downto 0) & sourceselectstatebits(sourceselectstatebits'length-1);
				--else
				--end if;

				--------------------------------------
				-- Wait for pipeline data to become available
				--------------------------------------
				if (pipelinedelay(pipelinedelay'length-1)='1') then

					-- Wait for write interface to be available
					if (write_ready='1') then

						-- This signaling can be reworked later
						pipelinedelay <= (others => '0');

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


			else		
			end if;
			
		end if;

	end process;

	--
	-- Continuous connections
	--

	-- Read channel signals
	read_req_addr <= std_logic_vector(AXI_ARADDR_int);

	-- Write channel signals
	write_addr <= std_logic_vector(write_addr_int);
	write_data <= std_logic_vector(write_data_int);
	write_ena <= write_ena_int;
	
end architecture;
