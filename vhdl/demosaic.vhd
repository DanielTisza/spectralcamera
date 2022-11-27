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

	port (

		-- Clock and reset
		clk : in std_logic;
		resetn	: in std_logic

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



			else		
			end if;
			
		end if;

	end process;
	
end architecture;
