-----------------------------------------------------------
-- rowdelay.vhd
--
-- Rowdelay
--
-- Copyright: Daniel Tisza, 2022, GPLv3 or later
--
-- ghdl -a -v rowdelay.vhd
-- ghdl -e -v rowdelay
-- ghdl -r rowdelay --vcd=out.vcd
-- gtkwave
--
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Describe the I/O of this "chip"
entity rowdelay is

	generic(
		C_M_AXI_ADDR_WIDTH	: integer	:= 32;
		C_M_AXI_DATA_WIDTH	: integer	:= 64
	);

	port (

		-- Clock and reset
		clk : in std_logic;
		resetn	: in std_logic;

		-- Input data signals		
		signal src1A : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
		signal src2A : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
		signal src3A : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);

		signal read_done_a : std_logic;
		signal read_done_b : std_logic;
		signal read_done_c : std_logic;

		signal imgsync_ena : std_logic;
		signal hsync_ena : std_logic;
		signal vsync_ena : std_logic

	);

end rowdelay;

-- Describe the contents of this "chip"
architecture rtl of rowdelay is

	signal src1B : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal src2B : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal src3B : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);

	-- Computations
	signal result1 : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal result2 : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal result3 : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);

begin
	
	io_proc : process(
		clk,
		resetn
	)
	begin

		if (resetn='0') then

			src1B <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			src2B <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			src3B <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			
			-- Computations
			result1 <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			result2 <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			result3 <= to_unsigned(0, C_M_AXI_DATA_WIDTH);

		else

			if (clk'event and clk='1') then

				src1B <= src1B;
				src2B <= src2B;
				src3B <= src3B;

				-- Computations
				result1 <= src1A + src1B;
				result2 <= src2A + src2B;
				result3 <= src3A + src3B;


			else		
			end if;
			
		end if;

	end process;

	--
	-- Continuous connections
	--
	
end architecture;
