-----------------------------------------------------------
-- rowdelayram.vhd
--
-- Rowdelayram
--
-- Copyright: Daniel Tisza, 2023, GPLv3 or later
--
-- ghdl -a -v rowdelayram.vhd
-- ghdl -e -v rowdelayram
-- ghdl -r rowdelayram --vcd=out.vcd
-- gtkwave
--
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Describe the I/O of this "chip"
entity rowdelayram is

	generic(
		C_M_AXI_ADDR_WIDTH	: integer	:= 32;
		C_M_AXI_DATA_WIDTH	: integer	:= 64
	);

	port (

		-- Clock and reset
		clk : in std_logic;

		-- RAM signals
		wr : in std_logic;
		addr : in std_logic_vector(9 downto 0);
		wr_data : in std_logic_vector(47 downto 0);
		rd_data : out std_logic_vector(47 downto 0)
	);

end rowdelayram;

-- Describe the contents of this "chip"
architecture rtl of rowdelayram is

	-- Delay RAM definition

	-- RAM definitions

	-- RAM data word size
	-- 64 bits contains 4 pixels * 16 bits
	-- Each 16 bits contain only 12 bits effective data
	-- So we get 4 pixels * 12 bits = 48 bits effective data

	-- RAM data word count
	-- 2590 pixels / 4 pixels per 64 bits transfer
	-- 2590/4 = 647.5 = 648

	subtype ram_word_type is std_logic_vector(47 downto 0);
	type ram_type is array(0 to 647) of ram_word_type ;
	subtype ram_addr_type is unsigned(9 downto 0);
	
	-- RAM1 signals
	signal ram1 : ram_type;
	signal ram1_addr : ram_addr_type;
	signal ram1_rd_data : ram_word_type;
	signal ram1_wr_data : ram_word_type;
	signal ram1_wr : std_logic;

begin
	
	------------------------------------------
	-- RAM with single read and write address
	------------------------------------------
	ram1_proc : process(
		clk,
		ram1,
		ram1_addr,
		ram1_wr_data,
		ram1_wr
	)
	begin
		
		if (clk'event and clk='1') then
		
			-- Write to RAM
			if (ram1_wr='1') then
				ram1(to_integer(ram1_addr)) <= ram1_wr_data;
			else
			end if;
			
			-- Read from RAM
			ram1_rd_data <= ram1(to_integer(ram1_addr));
		
		else
		end if;
	end process;

	--
	-- Continuous connections
	--
	ram1_wr <= wr;
	ram1_addr <= unsigned(addr);
	ram1_wr_data <= wr_data;
	rd_data <= ram1_rd_data;
	
end architecture;
