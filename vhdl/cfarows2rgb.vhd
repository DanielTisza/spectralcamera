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

	signal img1pix1r : unsigned(11 downto 0);
	signal img1pix1g : unsigned(11 downto 0);
	signal img1pix1b : unsigned(11 downto 0);

	signal img1pix2r : unsigned(11 downto 0);
	signal img1pix2g : unsigned(11 downto 0);
	signal img1pix2b : unsigned(11 downto 0);

	signal img1pix3r : unsigned(11 downto 0);
	signal img1pix3g : unsigned(11 downto 0);
	signal img1pix3b : unsigned(11 downto 0);

	signal img1pix4r : unsigned(11 downto 0);
	signal img1pix4g : unsigned(11 downto 0);
	signal img1pix4b : unsigned(11 downto 0);

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

			img1pix1g <= to_unsigned(0, 12);
			img1pix1b <= to_unsigned(0, 12);
			img1pix1r <= to_unsigned(0, 12);

			img1pix2b <= to_unsigned(0, 12);
			img1pix2r <= to_unsigned(0, 12);
			img1pix2g <= to_unsigned(0, 12);

			img1pix3g <= to_unsigned(0, 12);
			img1pix3b <= to_unsigned(0, 12);
			img1pix3r <= to_unsigned(0, 12);

			img1pix4b <= to_unsigned(0, 12);
			img1pix4r <= to_unsigned(0, 12);
			img1pix4g <= to_unsigned(0, 12);

		else

			if (clk'event and clk='1') then

				img1pix1g <= img1pix1g;
				img1pix1b <= img1pix1b;
				img1pix1r <= img1pix1r;

				img1pix2b <= img1pix2b;
				img1pix2r <= img1pix2r;
				img1pix2g <= img1pix2g;

				img1pix3g <= img1pix3g;
				img1pix3b <= img1pix3b;
				img1pix3r <= img1pix3r;
				
				img1pix4b <= img1pix4b;
				img1pix4r <= img1pix4r;
				img1pix4g <= img1pix4g;

				-- Demosaic so that pick the first appearing green value
				-- to first pixel first
				
				if (readrowodd='1') then

					img1pix1g <= unsigned(ram1_rd_data(47 downto 36));		-- delayed
					img1pix1b <= unsigned(ram1_rd_data(35 downto 24));		-- delayed
					img1pix1r <= unsigned(read_data(47 downto 36));		-- direct

					img1pix2b <= unsigned(ram1_rd_data(35 downto 24));		-- delayed
					img1pix2r <= unsigned(read_data(47 downto 36));		-- direct
					img1pix2g <= unsigned(read_data(35 downto 24));		-- direct
										
					img1pix3g <= unsigned(ram1_rd_data(23 downto 12));		-- delayed
					img1pix3b <= unsigned(ram1_rd_data(11 downto 0));		-- delayed
					img1pix3r <= unsigned(read_data(23 downto 12));		-- direct

					img1pix4b <= unsigned(ram1_rd_data(11 downto 0));		-- delayed
					img1pix4r <= unsigned(read_data(23 downto 12));		-- direct
					img1pix4g <= unsigned(read_data(11 downto 0));		-- direct

				else
					
					-- 47 downto 36
					-- 35 downto 24
					-- 23 downto 12
					-- 11 downto 0

					img1pix1r <= unsigned(ram1_rd_data(47 downto 36));	-- delayed
					img1pix1g <= unsigned(read_data(47 downto 36));		-- direct
					img1pix1b <= unsigned(read_data(35 downto 24));		-- direct
					
					img1pix2r <= unsigned(ram1_rd_data(47 downto 36));	-- delayed
					img1pix2g <= unsigned(ram1_rd_data(35 downto 24));	-- delayed
					img1pix2b <= unsigned(read_data(35 downto 24));		-- direct
					
					img1pix3r <= unsigned(ram1_rd_data(23 downto 12));	-- delayed
					img1pix3g <= unsigned(read_data(23 downto 12));		-- direct
					img1pix3b <= unsigned(read_data(11 downto 0));		-- direct

					img1pix4r <= unsigned(ram1_rd_data(23 downto 12));	-- delayed
					img1pix4g <= unsigned(ram1_rd_data(11 downto 0));	-- delayed
					img1pix4b <= unsigned(read_data(11 downto 0));		-- direct

				end if;

			else
			end if;
			
		end if;

	end process;

	--
	-- Continuous connections
	--
	pix1r <= img1pix1r;
	pix1g <= img1pix1g;
	pix1b <= img1pix1b;

	pix2r <= img1pix2r;
	pix2g <= img1pix2g;
	pix2b <= img1pix2b;

	pix3r <= img1pix3r;
	pix3g <= img1pix3g;
	pix3b <= img1pix3b;
	
	pix4r <= img1pix4r;
	pix4g <= img1pix4g;
	pix4b <= img1pix4b;
	
end architecture;
