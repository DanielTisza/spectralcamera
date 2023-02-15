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

		-- Input data
		src1A : in unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
		src1B : in unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);

		src2A : in unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
		src2B : in unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);

		src3A : in unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
		src3B : in unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);

		read_done : in std_logic;
		sourceselectstatebits : in std_logic_vector(5 downto 0);

		-- Output data
		result : out unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
		statebits : out std_logic_vector(7 downto 0);
		dstwriteena : out std_logic
	);

end demosaic;

-- Describe the contents of this "chip"
architecture rtl of demosaic is

	

begin
	
	io_proc : process(
		clk,
		resetn
	)
	begin

		if (resetn='0') then

			

		else

			if (clk'event and clk='1') then


				-- 2592 x 1944
				-- 2592 pixels * 2 bytes = 5184 (0x1440) pitch bytes
				-- 5184 / 8 bytes = 648 transfers

				-- 2590 x 1942
				-- 2590 pixels * 2 bytes = 5180 (0x143C) pitch bytes
				-- 5184 / 8 bytes = 647.5 transfers

				-- 0 - 1941 rows

				-- First row first pixel is green
				-- First row second pixel is blue
				-- Second row first pixel is red

				-- 0 - 2589 pixels

				

				


			else		
			end if;
			
		end if;

	end process;
	
end architecture;
