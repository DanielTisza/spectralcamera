-----------------------------------------------------------
-- imgreader.vhd
--
-- Image reader
--
-- Copyright: Daniel Tisza, 2022, GPLv3 or later
--
-- ghdl -a -v imgreader.vhd
-- ghdl -e -v imgreader
-- ghdl -r imgreader --vcd=out.vcd
-- gtkwave
--
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Describe the I/O of this "chip"
entity imgreader is

	generic(
		C_M_AXI_ADDR_WIDTH	: integer	:= 32;
		C_M_AXI_DATA_WIDTH	: integer	:= 64
	);

	port (

		-- Clock and reset
		clk : in std_logic;
		resetn	: in std_logic;

		-- Reading channel signals
		read_req0 : out std_logic;
		read_req_addr0 : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		read_done0 : in std_logic;
		read_data_in0 : in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);

		read_req1 : out std_logic;
		read_req_addr1 : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		read_done1 : in std_logic;
		read_data_in1 : in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);

		read_req2 : out std_logic;
		read_req_addr2 : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		read_done2 : in std_logic;
		read_data_in2 : in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);

		read_req3 : out std_logic;
		read_req_addr3 : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		read_done3 : in std_logic;
		read_data_in3 : in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);

		-- Image channel signals
		imgsync_ena : out std_logic;
		hsync_ena : out std_logic;
		vsync_ena : out std_logic;

		read_data_out : out std_logic_vector(4*C_M_AXI_DATA_WIDTH-1 downto 0);

		read_done_a : out std_logic;
		read_done_b : out std_logic;
		read_done_c : out std_logic
	);

end imgreader;

-- Describe the contents of this "chip"
architecture rtl of imgreader is

	-- Read channel signals 
	signal readstatebits : std_logic_vector(2 downto 0);
	
	signal read_next_addr_ena : std_logic;

	signal AXI_ARADDR_int0 : unsigned(C_M_AXI_ADDR_WIDTH-1 downto 0);
	signal AXI_ARADDR_int1 : unsigned(C_M_AXI_ADDR_WIDTH-1 downto 0);
	signal AXI_ARADDR_int2 : unsigned(C_M_AXI_ADDR_WIDTH-1 downto 0);
	signal AXI_ARADDR_int3 : unsigned(C_M_AXI_ADDR_WIDTH-1 downto 0);

	signal read_req_int0 : std_logic;
	signal read_req_int1 : std_logic;
	signal read_req_int2 : std_logic;
	signal read_req_int3 : std_logic;

	signal read_next_addr0 : unsigned(C_M_AXI_ADDR_WIDTH-1 downto 0);
	signal read_next_addr1 : unsigned(C_M_AXI_ADDR_WIDTH-1 downto 0);
	signal read_next_addr2 : unsigned(C_M_AXI_ADDR_WIDTH-1 downto 0);
	signal read_next_addr3 : unsigned(C_M_AXI_ADDR_WIDTH-1 downto 0);

	signal imgIdx : unsigned(1 downto 0);
	signal imgIdxPrev : unsigned(1 downto 0);
	signal rowIdx : unsigned(10 downto 0);
	signal colIdx : unsigned(11 downto 0);

	signal imgsync_ena_int : std_logic;
	signal hsync_ena_int : std_logic;
	signal vsync_ena_int : std_logic;

	signal read_done_a_int : std_logic;
	signal read_done_b_int : std_logic;
	signal read_done_c_int : std_logic;

begin
	
	io_proc : process(
		clk,
		resetn
	)
	begin

		if (resetn='0') then

			-- Reading channel signals
			readstatebits <= "001";

			AXI_ARADDR_int0 <= to_unsigned(0, C_M_AXI_ADDR_WIDTH);
			AXI_ARADDR_int1 <= to_unsigned(0, C_M_AXI_ADDR_WIDTH);
			AXI_ARADDR_int2 <= to_unsigned(0, C_M_AXI_ADDR_WIDTH);
			AXI_ARADDR_int3 <= to_unsigned(0, C_M_AXI_ADDR_WIDTH);

			read_req_int0 <= '0';
			read_req_int1 <= '0';
			read_req_int2 <= '0';
			read_req_int3 <= '0';

			read_next_addr0 <= to_unsigned(0, C_M_AXI_ADDR_WIDTH);
			read_next_addr1 <= to_unsigned(0, C_M_AXI_ADDR_WIDTH);
			read_next_addr2 <= to_unsigned(0, C_M_AXI_ADDR_WIDTH);
			read_next_addr3 <= to_unsigned(0, C_M_AXI_ADDR_WIDTH);

			read_next_addr_ena <= '0';

			imgIdx <= to_unsigned(0,2);
			imgIdxPrev <= to_unsigned(0,2);
			rowIdx <= to_unsigned(0,11);
			colIdx <= to_unsigned(0,12);

			imgsync_ena_int <= '0';
			hsync_ena_int <= '0';
			vsync_ena_int <= '0';

			read_done_a_int <= '0';
			read_done_b_int <= '0';
			read_done_c_int <= '0';

		else

			if (clk'event and clk='1') then

				-- Read channel signals
				readstatebits <= readstatebits;
				
				AXI_ARADDR_int0 <= AXI_ARADDR_int0;
				AXI_ARADDR_int1 <= AXI_ARADDR_int1;
				AXI_ARADDR_int2 <= AXI_ARADDR_int2;
				AXI_ARADDR_int3 <= AXI_ARADDR_int3;

				read_req_int0 <= read_req_int0;
				read_req_int1 <= read_req_int1;
				read_req_int2 <= read_req_int2;
				read_req_int3 <= read_req_int3;

				read_next_addr_ena <= '0';

				imgIdx <= imgIdx;
				imgIdxPrev <= imgIdxPrev;
				rowIdx <= rowIdx;
				colIdx <= colIdx;

				imgsync_ena_int <= '0';
				hsync_ena_int <= '0';
				vsync_ena_int <= '0';

				read_done_a_int <= '0';
				read_done_b_int <= '0';
				read_done_c_int <= '0';

				--
				-- Spectral camera
				--
				-- 2592 x 1944
				-- 2592 pixels * 2 bytes = 5184 (0x1440) pitch bytes
				-- 5184 / 8 bytes = 648 transfers
				-- 5184 / 32 bytes = 162 transfers

				--
				-- Boxed camera module
				--
				-- 2590 x 1942
				-- 2590 pixels * 2 bytes = 5180 (0x143C) pitch bytes
				-- 5180 / 8 bytes = 647.5 transfers
				-- 5180 / 32 bytes = 161.875 transfers

				-- 0 - 1941 rows

				-- First row first pixel is green
				-- First row second pixel is blue
				-- Second row first pixel is red

				-- 0 - 2589 pixels
				
				--------------------------------------
				-- Capture read data and prepare next address
				--------------------------------------

				case readstatebits is

					-- Init state
					-- Give time to calculate first address
					when "001" =>

						readstatebits <= "010";

					-- Set read address
					when "010" =>

						AXI_ARADDR_int0 <= read_next_addr0;
						AXI_ARADDR_int1 <= read_next_addr1;
						AXI_ARADDR_int2 <= read_next_addr2;
						AXI_ARADDR_int3 <= read_next_addr3;

						read_req_int0 <= '1';
						read_req_int1 <= '1';
						read_req_int2 <= '1';
						read_req_int3 <= '1';

						read_next_addr_ena <= '1';
						readstatebits <= "100";

					-- Waiting for read done indication
					when "100" =>

						if (	read_done0='1' 
							and read_done1='1'
							and read_done2='1'
							and read_done3='1'
						) then
							read_req_int0 <= '0';
							read_req_int1 <= '0';
							read_req_int2 <= '0';
							read_req_int3 <= '0';

							readstatebits <= "010";
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
				--		3C000000 + (imgIdx * imgBytes) + (rowIdx * rowBytes) + (colIdx * 32 bytes)
				--
				-- where
				--		imgBase		= 1006632960 = 0x3C000000	(32 bits)
				--		imgIdx 		= 0...2						(2 bits)
				--		imgSize 	= 15116544 bytes = 0xE6A900
				--		rowIdx 		= 0...1941					(11 bits)
				--		rowBytes	= 5180 bytes = 0x143C
				--		colIdx		= 0...2589					(12 bits)

				-- 0x3C00 0000
				read_next_addr0 <= 		to_unsigned(1006632960, C_M_AXI_ADDR_WIDTH)
									+	imgIdx * to_unsigned(15116544, 24)
									+ 	rowIdx * to_unsigned(5180, 13)
									+	colIdx * to_unsigned(32, 6);

				-- 0x3C00 0008
				read_next_addr1 <= 		to_unsigned(1006632968, C_M_AXI_ADDR_WIDTH)
									+	imgIdx * to_unsigned(15116544, 24)
									+ 	rowIdx * to_unsigned(5180, 13)
									+	colIdx * to_unsigned(32, 6);

				-- 0x3C00 0010
				read_next_addr2 <= 		to_unsigned(1006632976, C_M_AXI_ADDR_WIDTH)
									+	imgIdx * to_unsigned(15116544, 24)
									+ 	rowIdx * to_unsigned(5180, 13)
									+	colIdx * to_unsigned(32, 6);

				-- 0x3C00 0018
				read_next_addr3 <= 		to_unsigned(1006632984, C_M_AXI_ADDR_WIDTH)
									+	imgIdx * to_unsigned(15116544, 24)
									+ 	rowIdx * to_unsigned(5180, 13)
									+	colIdx * to_unsigned(32, 6);


				-- Increment image index or
				-- reset image index when maximum reached
				if (read_next_addr_ena='1') then

					imgIdxPrev <= imgIdx;

					if (imgIdx=to_unsigned(2,2)) then
						imgIdx <= to_unsigned(0,2);
						imgsync_ena_int <= '1';
					else
						imgIdx <= imgIdx + to_unsigned(1,2);
					end if;

				else
				end if;

				-- Increment column index or
				-- reset column index when maximum reached
				if (imgsync_ena_int='1') then

					-- 2590 pixels / 4 pixels per 64 bits transfer
					-- 2590/4 = 647.5 => 648
					-- 2590 pixels / 16 pixels per 4*64 bits transfer
					-- 2590/16 = 161.875 => 162
					if (colIdx=to_unsigned(162,12)) then
						colIdx <= to_unsigned(0,12);
						hsync_ena_int <= '1';
					else
						colIdx <= colIdx + to_unsigned(1,12);
					end if;

				else
				end if;

				-- Increment row index or
				-- reset row index when maximum reached
				if (hsync_ena_int='1') then

					if (rowIdx=to_unsigned(1942,11)) then
						rowIdx <= to_unsigned(0,11);
						vsync_ena_int <= '1';
					else
						rowIdx <= rowIdx + to_unsigned(1,11);
					end if;
					
				else 
				end if;

				-- Convert read_done to image-specific read_done signal
				if (	read_done0='1' 
					and read_done1='1'
					and read_done2='1'
					and read_done3='1'
				) then

					if (imgIdxPrev=to_unsigned(0,2)) then
						read_done_a_int <= '1';
					else
					end if;

					if (imgIdxPrev=to_unsigned(1,2)) then
						read_done_b_int <= '1';
					else
					end if;

					if (imgIdxPrev=to_unsigned(2,2)) then
						read_done_c_int <= '1';
					else
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
	read_req_addr0 <= std_logic_vector(AXI_ARADDR_int0);
	read_req_addr1 <= std_logic_vector(AXI_ARADDR_int1);
	read_req_addr2 <= std_logic_vector(AXI_ARADDR_int2);
	read_req_addr3 <= std_logic_vector(AXI_ARADDR_int3);

	read_req0 <= read_req_int0;
	read_req1 <= read_req_int1;
	read_req2 <= read_req_int2;
	read_req3 <= read_req_int3;

	read_data_out <=	read_data_in3 
					& 	read_data_in2
					&	read_data_in1
					&	read_data_in0;

	read_done_a <= read_done_a_int;
	read_done_b <= read_done_b_int;
	read_done_c <= read_done_c_int;

	imgsync_ena <= imgsync_ena_int;
	hsync_ena <= hsync_ena_int;
	vsync_ena <= vsync_ena_int;
	
end architecture;
