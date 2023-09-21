-----------------------------------------------------------
-- cfarows2rgb.vhd
--
-- Convert data from two CFA rows to RGB pixels
--
-- Copyright: Daniel Tisza, 2022, GPLv3 or later
--
-- ghdl -a -v cfarows2rgb.vhd
-- ghdl -e -v cfarows2rgb
-- ghdl -r cfarows2rgb --vcd=out.vcd
-- gtkwave
--
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Describe the I/O of this "chip"
entity cfarows2rgb is

	generic(
		C_M_AXI_ADDR_WIDTH	: integer	:= 32;
		C_M_AXI_DATA_WIDTH	: integer	:= 64
	);

	port (

		-- Clock and reset
		clk : in std_logic;
		resetn	: in std_logic;

		-- Input data signals
		readrowodd : in std_logic;
		ram1_rd_data : in std_logic_vector(47 downto 0);
		read_data : in std_logic_vector(47 downto 0);

		-- Output data signals
		pix1r : out unsigned(11 downto 0);
		pix1g : out unsigned(11 downto 0);
		pix1b : out unsigned(11 downto 0);

		pix2r : out unsigned(11 downto 0);
		pix2g : out unsigned(11 downto 0);
		pix2b : out unsigned(11 downto 0);

		pix3r : out unsigned(11 downto 0);
		pix3g : out unsigned(11 downto 0);
		pix3b : out unsigned(11 downto 0);

		pix4r : out unsigned(11 downto 0);
		pix4g : out unsigned(11 downto 0);
		pix4b : out unsigned(11 downto 0)
	);

end cfarows2rgb;

-- Describe the contents of this "chip"
architecture rtl of cfarows2rgb is

begin

	------------------------------------------
	-- IO process
	------------------------------------------
	io_proc : process(
		clk,
		resetn
	)
	begin

		-- Demosaic so that pick the first appearing green value
		-- to first pixel first
		
		if (readrowodd='1') then

			pix1g <= unsigned(ram1_rd_data(47 downto 36));		-- delayed
			pix1b <= unsigned(ram1_rd_data(35 downto 24));		-- delayed
			pix1r <= unsigned(read_data(47 downto 36));		-- direct

			pix2b <= unsigned(ram1_rd_data(35 downto 24));		-- delayed
			pix2r <= unsigned(read_data(47 downto 36));		-- direct
			pix2g <= unsigned(read_data(35 downto 24));		-- direct

			pix3g <= unsigned(ram1_rd_data(23 downto 12));		-- delayed
			pix3b <= unsigned(ram1_rd_data(11 downto 0));		-- delayed
			pix3r <= unsigned(read_data(23 downto 12));		-- direct

			pix4b <= unsigned(ram1_rd_data(11 downto 0));		-- delayed
			pix4r <= unsigned(read_data(23 downto 12));		-- direct
			pix4g <= unsigned(read_data(11 downto 0));		-- direct

		else

			-- 47 downto 36
			-- 35 downto 24
			-- 23 downto 12
			-- 11 downto 0

			pix1r <= unsigned(ram1_rd_data(47 downto 36));	-- delayed
			pix1g <= unsigned(read_data(47 downto 36));		-- direct
			pix1b <= unsigned(read_data(35 downto 24));		-- direct

			pix2r <= unsigned(ram1_rd_data(47 downto 36));	-- delayed
			pix2g <= unsigned(ram1_rd_data(35 downto 24));	-- delayed
			pix2b <= unsigned(read_data(35 downto 24));		-- direct

			pix3r <= unsigned(ram1_rd_data(23 downto 12));	-- delayed
			pix3g <= unsigned(read_data(23 downto 12));		-- direct
			pix3b <= unsigned(read_data(11 downto 0));		-- direct

			pix4r <= unsigned(ram1_rd_data(23 downto 12));	-- delayed
			pix4g <= unsigned(ram1_rd_data(11 downto 0));	-- delayed
			pix4b <= unsigned(read_data(11 downto 0));		-- direct

		end if;

	end process;

end architecture;
