-----------------------------------------------------------
-- fixedtodouble.vhd
--
-- Fixedtodouble
--
-- Copyright: Daniel Tisza, 2023, GPLv3 or later
--
-- ghdl -a -v fixedtodouble.vhd
-- ghdl -e -v fixedtodouble
-- ghdl -r fixedtodouble --vcd=out.vcd
-- gtkwave
--
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Describe the I/O of this "chip"
entity fixedtodouble is

	port (

		-- Clock and reset
		clk : in std_logic;

		-- Input data signals
		img1pix1rfixed : in STD_LOGIC_VECTOR ( 15 downto 0 );
		img1pix1gfixed : in STD_LOGIC_VECTOR ( 15 downto 0 );
		img1pix1bfixed : in STD_LOGIC_VECTOR ( 15 downto 0 );
		img1pix2rfixed : in STD_LOGIC_VECTOR ( 15 downto 0 );
		img1pix2gfixed : in STD_LOGIC_VECTOR ( 15 downto 0 );
		img1pix2bfixed : in STD_LOGIC_VECTOR ( 15 downto 0 );
		img1pix3rfixed : in STD_LOGIC_VECTOR ( 15 downto 0 );
		img1pix3gfixed : in STD_LOGIC_VECTOR ( 15 downto 0 );
		img1pix3bfixed : in STD_LOGIC_VECTOR ( 15 downto 0 );
		img1pix4rfixed : in STD_LOGIC_VECTOR ( 15 downto 0 );
		img1pix4gfixed : in STD_LOGIC_VECTOR ( 15 downto 0 );
		img1pix4bfixed : in STD_LOGIC_VECTOR ( 15 downto 0 );
 
		img2pix1rfixed : in STD_LOGIC_VECTOR ( 15 downto 0 ); 
		img2pix1gfixed : in STD_LOGIC_VECTOR ( 15 downto 0 ); 
		img2pix1bfixed : in STD_LOGIC_VECTOR ( 15 downto 0 ); 
		img2pix2rfixed : in STD_LOGIC_VECTOR ( 15 downto 0 ); 
		img2pix2gfixed : in STD_LOGIC_VECTOR ( 15 downto 0 ); 
		img2pix2bfixed : in STD_LOGIC_VECTOR ( 15 downto 0 ); 
		img2pix3rfixed : in STD_LOGIC_VECTOR ( 15 downto 0 ); 
		img2pix3gfixed : in STD_LOGIC_VECTOR ( 15 downto 0 ); 
		img2pix3bfixed : in STD_LOGIC_VECTOR ( 15 downto 0 ); 
		img2pix4rfixed : in STD_LOGIC_VECTOR ( 15 downto 0 ); 
		img2pix4gfixed : in STD_LOGIC_VECTOR ( 15 downto 0 ); 
		img2pix4bfixed : in STD_LOGIC_VECTOR ( 15 downto 0 ); 
		
		-- Output data signals
		img1pix1r : out STD_LOGIC_VECTOR ( 63 downto 0 );
		img1pix1g : out STD_LOGIC_VECTOR ( 63 downto 0 );
		img1pix1b : out STD_LOGIC_VECTOR ( 63 downto 0 );
		img1pix2r : out STD_LOGIC_VECTOR ( 63 downto 0 );
		img1pix2g : out STD_LOGIC_VECTOR ( 63 downto 0 );
		img1pix2b : out STD_LOGIC_VECTOR ( 63 downto 0 );
		img1pix3r : out STD_LOGIC_VECTOR ( 63 downto 0 );
		img1pix3g : out STD_LOGIC_VECTOR ( 63 downto 0 );
		img1pix3b : out STD_LOGIC_VECTOR ( 63 downto 0 );
		img1pix4r : out STD_LOGIC_VECTOR ( 63 downto 0 );
		img1pix4g : out STD_LOGIC_VECTOR ( 63 downto 0 );
		img1pix4b : out STD_LOGIC_VECTOR ( 63 downto 0 );

		img2pix1r : out STD_LOGIC_VECTOR ( 63 downto 0 );
		img2pix1g : out STD_LOGIC_VECTOR ( 63 downto 0 );
		img2pix1b : out STD_LOGIC_VECTOR ( 63 downto 0 );
		img2pix2r : out STD_LOGIC_VECTOR ( 63 downto 0 );
		img2pix2g : out STD_LOGIC_VECTOR ( 63 downto 0 );
		img2pix2b : out STD_LOGIC_VECTOR ( 63 downto 0 );
		img2pix3r : out STD_LOGIC_VECTOR ( 63 downto 0 );
		img2pix3g : out STD_LOGIC_VECTOR ( 63 downto 0 );
		img2pix3b : out STD_LOGIC_VECTOR ( 63 downto 0 );
		img2pix4r : out STD_LOGIC_VECTOR ( 63 downto 0 );
		img2pix4g : out STD_LOGIC_VECTOR ( 63 downto 0 );
		img2pix4b : out STD_LOGIC_VECTOR ( 63 downto 0 )
	);

end fixedtodouble;

-- Describe the contents of this "chip"
architecture rtl of fixedtodouble is

	component rgbfixedtodouble is
	port (
		clk : in std_logic;
		pixrfixed : in STD_LOGIC_VECTOR ( 15 downto 0 );
		pixgfixed : in STD_LOGIC_VECTOR ( 15 downto 0 );
		pixbfixed : in STD_LOGIC_VECTOR ( 15 downto 0 );
		pixr : out STD_LOGIC_VECTOR ( 63 downto 0 );
		pixg : out STD_LOGIC_VECTOR ( 63 downto 0 );
		pixb : out STD_LOGIC_VECTOR ( 63 downto 0 )
	);
	end component;

begin

	------------------------------------------
	-- Convert target image pixels
	------------------------------------------
	img1pix1fd : rgbfixedtodouble port map(
		clk => clk,
		pixrfixed => img1pix1rfixed,
		pixgfixed => img1pix1gfixed,
		pixbfixed => img1pix1bfixed,
		pixr => img1pix1r,
		pixg => img1pix1g,
		pixb => img1pix1b
	);

	img1pix2fd : rgbfixedtodouble port map(
		clk => clk,
		pixrfixed => img1pix2rfixed,
		pixgfixed => img1pix2gfixed,
		pixbfixed => img1pix2bfixed,
		pixr => img1pix2r,
		pixg => img1pix2g,
		pixb => img1pix2b
	);

	img1pix3fd : rgbfixedtodouble port map(
		clk => clk,
		pixrfixed => img1pix3rfixed,
		pixgfixed => img1pix3gfixed,
		pixbfixed => img1pix3bfixed,
		pixr => img1pix3r,
		pixg => img1pix3g,
		pixb => img1pix3b
	);

	img1pix4fd : rgbfixedtodouble port map(
		clk => clk,
		pixrfixed => img1pix4rfixed,
		pixgfixed => img1pix4gfixed,
		pixbfixed => img1pix4bfixed,
		pixr => img1pix4r,
		pixg => img1pix4g,
		pixb => img1pix4b
	);

	------------------------------------------
	-- Convert white image pixels
	------------------------------------------
	img2pix1fd : rgbfixedtodouble port map(
		clk => clk,
		pixrfixed => img2pix1rfixed,
		pixgfixed => img2pix1gfixed,
		pixbfixed => img2pix1bfixed,
		pixr => img2pix1r,
		pixg => img2pix1g,
		pixb => img2pix1b
	);

	img2pix2fd : rgbfixedtodouble port map(
		clk => clk,
		pixrfixed => img2pix2rfixed,
		pixgfixed => img2pix2gfixed,
		pixbfixed => img2pix2bfixed,
		pixr => img2pix2r,
		pixg => img2pix2g,
		pixb => img2pix2b
	);

	img2pix3fd : rgbfixedtodouble port map(
		clk => clk,
		pixrfixed => img2pix3rfixed,
		pixgfixed => img2pix3gfixed,
		pixbfixed => img2pix3bfixed,
		pixr => img2pix3r,
		pixg => img2pix3g,
		pixb => img2pix3b
	);

	img2pix4fd : rgbfixedtodouble port map(
		clk => clk,
		pixrfixed => img2pix4rfixed,
		pixgfixed => img2pix4gfixed,
		pixbfixed => img2pix4bfixed,
		pixr => img2pix4r,
		pixg => img2pix4g,
		pixb => img2pix4b
	);

end architecture;
