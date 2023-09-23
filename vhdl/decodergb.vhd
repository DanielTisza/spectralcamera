-----------------------------------------------------------
-- decodergb.vhd
--
-- Decodergb
--
-- Copyright: Daniel Tisza, 2022, GPLv3 or later
--
-- ghdl -a -v decodergb.vhd
-- ghdl -e -v decodergb
-- ghdl -r decodergb --vcd=out.vcd
-- gtkwave
--
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Describe the I/O of this "chip"
entity decodergb is

	port (

		-- Clock and reset
		clk : in std_logic;
		resetn	: in std_logic;

		-- Input data signals

		-- Current row pixels from DDR
		targetsubvec : in std_logic_vector(47 downto 0);
		whitesubvec : in std_logic_vector(47 downto 0);

		-- Previous row pixels from delay RAM
		ram1_rd_data : in std_logic_vector(47 downto 0);
		ram2_rd_data : in std_logic_vector(47 downto 0);

		-- Current row odd indication
		targetreadrowodd : in std_logic;
		whitereadrowodd : in std_logic;

		-- Ena to capture to output buffer
		read_done_target_delayed : in std_logic;
		read_done_white_delayed : in std_logic;

		-- Output data signals
		targetpix1r : out unsigned(11 downto 0);
		targetpix1g : out unsigned(11 downto 0);
		targetpix1b : out unsigned(11 downto 0);
		targetpix2r : out unsigned(11 downto 0);
		targetpix2g : out unsigned(11 downto 0);
		targetpix2b : out unsigned(11 downto 0);
		targetpix3r : out unsigned(11 downto 0);
		targetpix3g : out unsigned(11 downto 0);
		targetpix3b : out unsigned(11 downto 0);
		targetpix4r : out unsigned(11 downto 0);
		targetpix4g : out unsigned(11 downto 0);
		targetpix4b : out unsigned(11 downto 0);

		whitepix1r : out unsigned(11 downto 0);
		whitepix1g : out unsigned(11 downto 0);
		whitepix1b : out unsigned(11 downto 0);
		whitepix2r : out unsigned(11 downto 0);
		whitepix2g : out unsigned(11 downto 0);
		whitepix2b : out unsigned(11 downto 0);
		whitepix3r : out unsigned(11 downto 0);
		whitepix3g : out unsigned(11 downto 0);
		whitepix3b : out unsigned(11 downto 0);
		whitepix4r : out unsigned(11 downto 0);
		whitepix4g : out unsigned(11 downto 0);
		whitepix4b : out unsigned(11 downto 0)
	);

end decodergb;

-- Describe the contents of this "chip"
architecture rtl of decodergb is
	
	------------------------------------------
	-- cfarows2rgb
	------------------------------------------
	component cfarows2rgb is

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
	
	end component cfarows2rgb;

	-----------------------
	-- Signals from cfarows2rgb block
	-----------------------

	-- Demosaic for target image
	signal targetdmpix1r : unsigned(11 downto 0);
	signal targetdmpix1g : unsigned(11 downto 0);
	signal targetdmpix1b : unsigned(11 downto 0);

	signal targetdmpix2r : unsigned(11 downto 0);
	signal targetdmpix2g : unsigned(11 downto 0);
	signal targetdmpix2b : unsigned(11 downto 0);

	signal targetdmpix3r : unsigned(11 downto 0);
	signal targetdmpix3g : unsigned(11 downto 0);
	signal targetdmpix3b : unsigned(11 downto 0);

	signal targetdmpix4r : unsigned(11 downto 0);
	signal targetdmpix4g : unsigned(11 downto 0);
	signal targetdmpix4b : unsigned(11 downto 0);

	-- Demosaic for white image
	signal whitedmpix1r : unsigned(11 downto 0);
	signal whitedmpix1g : unsigned(11 downto 0);
	signal whitedmpix1b : unsigned(11 downto 0);

	signal whitedmpix2r : unsigned(11 downto 0);
	signal whitedmpix2g : unsigned(11 downto 0);
	signal whitedmpix2b : unsigned(11 downto 0);

	signal whitedmpix3r : unsigned(11 downto 0);
	signal whitedmpix3g : unsigned(11 downto 0);
	signal whitedmpix3b : unsigned(11 downto 0);

	signal whitedmpix4r : unsigned(11 downto 0);
	signal whitedmpix4g : unsigned(11 downto 0);
	signal whitedmpix4b : unsigned(11 downto 0);

	-----------------------
	-- Output pixel signals
	-----------------------

	-- Image 1 pixel data for four pixels in 36-bit RGB format
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

	-- Image 2 pixel data for four pixels in 36-bit RGB format
	signal img2pix1r : unsigned(11 downto 0);
	signal img2pix1g : unsigned(11 downto 0);
	signal img2pix1b : unsigned(11 downto 0);

	signal img2pix2r : unsigned(11 downto 0);
	signal img2pix2g : unsigned(11 downto 0);
	signal img2pix2b : unsigned(11 downto 0);

	signal img2pix3r : unsigned(11 downto 0);
	signal img2pix3g : unsigned(11 downto 0);
	signal img2pix3b : unsigned(11 downto 0);

	signal img2pix4r : unsigned(11 downto 0);
	signal img2pix4g : unsigned(11 downto 0);
	signal img2pix4b : unsigned(11 downto 0);

begin

	------------------------------------------
	-- cfarows2rgb1 for target image
	------------------------------------------
	cfarows2rgb1 : cfarows2rgb port map(
	
		-- Clock and reset
		clk => clk,
		resetn => resetn,

		-- Input data signals
		readrowodd => targetreadrowodd,
		ram1_rd_data => ram1_rd_data,

		read_data => targetsubvec,

		-- Output data signals
		pix1r => targetdmpix1r,
		pix1g => targetdmpix1g,
		pix1b => targetdmpix1b,

		pix2r => targetdmpix2r,
		pix2g => targetdmpix2g,
		pix2b => targetdmpix2b,

		pix3r => targetdmpix3r,
		pix3g => targetdmpix3g,
		pix3b => targetdmpix3b,

		pix4r => targetdmpix4r,
		pix4g => targetdmpix4g,
		pix4b => targetdmpix4b
 	);

	------------------------------------------
	-- cfarows2rgb2 for white image
	------------------------------------------
	cfarows2rgb2 : cfarows2rgb port map(
	
		-- Clock and reset
		clk => clk,
		resetn => resetn,

		-- Input data signals
		readrowodd => whitereadrowodd,
		ram1_rd_data => ram2_rd_data,

		read_data => whitesubvec,

		-- Output data signals
		pix1r => whitedmpix1r,
		pix1g => whitedmpix1g,
		pix1b => whitedmpix1b,

		pix2r => whitedmpix2r,
		pix2g => whitedmpix2g,
		pix2b => whitedmpix2b,

		pix3r => whitedmpix3r,
		pix3g => whitedmpix3g,
		pix3b => whitedmpix3b,

		pix4r => whitedmpix4r,
		pix4g => whitedmpix4g,
		pix4b => whitedmpix4b
 	);

	------------------------------------------
	-- IO process
	------------------------------------------
	io_proc : process(
		clk,
		resetn
	)
	begin

		if (resetn='0') then

			-- Image 1 pixel data for four pixels in 36-bit RGB format
			img1pix1r <= to_unsigned(0, 12);
			img1pix1g <= to_unsigned(0, 12);
			img1pix1b <= to_unsigned(0, 12);
			img1pix2r <= to_unsigned(0, 12);
			img1pix2g <= to_unsigned(0, 12);
			img1pix2b <= to_unsigned(0, 12);
			img1pix3r <= to_unsigned(0, 12);
			img1pix3g <= to_unsigned(0, 12);
			img1pix3b <= to_unsigned(0, 12);
			img1pix4r <= to_unsigned(0, 12);
			img1pix4g <= to_unsigned(0, 12);
			img1pix4b <= to_unsigned(0, 12);

			-- Image 2 pixel data for four pixels in 36-bit RGB format
			img2pix1r <= to_unsigned(0, 12);
			img2pix1g <= to_unsigned(0, 12);
			img2pix1b <= to_unsigned(0, 12);
			img2pix2r <= to_unsigned(0, 12);
			img2pix2g <= to_unsigned(0, 12);
			img2pix2b <= to_unsigned(0, 12);
			img2pix3r <= to_unsigned(0, 12);
			img2pix3g <= to_unsigned(0, 12);
			img2pix3b <= to_unsigned(0, 12);
			img2pix4r <= to_unsigned(0, 12);
			img2pix4g <= to_unsigned(0, 12);
			img2pix4b <= to_unsigned(0, 12);

		else

			if (clk'event and clk='1') then

				-- Image 1 pixel data for four pixels in 36-bit RGB format
				img1pix1r <= img1pix1r;
				img1pix1g <= img1pix1g;
				img1pix1b <= img1pix1b;
				img1pix2r <= img1pix2r;
				img1pix2g <= img1pix2g;
				img1pix2b <= img1pix2b;
				img1pix3r <= img1pix3r;
				img1pix3g <= img1pix3g;
				img1pix3b <= img1pix3b;
				img1pix4r <= img1pix4r;
				img1pix4g <= img1pix4g;
				img1pix4b <= img1pix4b;

				-- Image 2 pixel data for four pixels in 36-bit RGB format
				img2pix1r <= img1pix1r;
				img2pix1g <= img1pix1g;
				img2pix1b <= img1pix1b;
				img2pix2r <= img1pix2r;
				img2pix2g <= img1pix2g;
				img2pix2b <= img1pix2b;
				img2pix3r <= img1pix3r;
				img2pix3g <= img1pix3g;
				img2pix3b <= img1pix3b;
				img2pix4r <= img1pix4r;
				img2pix4g <= img1pix4g;
				img2pix4b <= img1pix4b;

				----------------------------
				-- Image after demosaic in 36-bit RGB format
				----------------------------

				-- Target image capture RGB pixels after demosaic
				if (read_done_target_delayed='1') then

					img1pix1r <= targetdmpix1r;
					img1pix1g <= targetdmpix1g;
					img1pix1b <= targetdmpix1b;
					img1pix2r <= targetdmpix2r;
					img1pix2g <= targetdmpix2g;
					img1pix2b <= targetdmpix2b;
					img1pix3r <= targetdmpix3r;
					img1pix3g <= targetdmpix3g;
					img1pix3b <= targetdmpix3b;
					img1pix4r <= targetdmpix4r;
					img1pix4g <= targetdmpix4g;
					img1pix4b <= targetdmpix4b;

				else
				end if;

				-- White image capture RGB pixels after demosaic
				if (read_done_white_delayed='1') then

					img2pix1r <= whitedmpix1r;
					img2pix1g <= whitedmpix1g;
					img2pix1b <= whitedmpix1b;
					img2pix2r <= whitedmpix2r;
					img2pix2g <= whitedmpix2g;
					img2pix2b <= whitedmpix2b;
					img2pix3r <= whitedmpix3r;
					img2pix3g <= whitedmpix3g;
					img2pix3b <= whitedmpix3b;
					img2pix4r <= whitedmpix4r;
					img2pix4g <= whitedmpix4g;
					img2pix4b <= whitedmpix4b;
				else
				end if;

			else
			end if;
			
		end if;

	end process;

	--
	-- Continuous connections
	--
	
	targetpix1r <= img1pix1r;
	targetpix1g <= img1pix1g;
	targetpix1b <= img1pix1b;
	targetpix2r <= img1pix2r;
	targetpix2g <= img1pix2g;
	targetpix2b <= img1pix2b;
	targetpix3r <= img1pix3r;
	targetpix3g <= img1pix3g;
	targetpix3b <= img1pix3b;
	targetpix4r <= img1pix4r;
	targetpix4g <= img1pix4g;
	targetpix4b <= img1pix4b;

	whitepix1r <= img2pix1r;
	whitepix1g <= img2pix1g;
	whitepix1b <= img2pix1b;
	whitepix2r <= img2pix2r;
	whitepix2g <= img2pix2g;
	whitepix2b <= img2pix2b;
	whitepix3r <= img2pix3r;
	whitepix3g <= img2pix3g;
	whitepix3b <= img2pix3b;
	whitepix4r <= img2pix4r;
	whitepix4g <= img2pix4g;
	whitepix4b <= img2pix4b;

end architecture;
