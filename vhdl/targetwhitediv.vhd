-----------------------------------------------------------
-- targetwhitediv.vhd
--
-- Targetwhitediv
--
-- Copyright: Daniel Tisza, 2023, GPLv3 or later
--
-- ghdl -a -v targetwhitediv.vhd
-- ghdl -e -v targetwhitediv
-- ghdl -r targetwhitediv --vcd=out.vcd
-- gtkwave
--
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Describe the I/O of this "chip"
entity targetwhitediv is

	port (

		-- Clock and reset
		clk : in std_logic;

		-- Input data signals
		img1pix1r : in STD_LOGIC_VECTOR ( 63 downto 0 );
		img1pix1g : in STD_LOGIC_VECTOR ( 63 downto 0 );
		img1pix1b : in STD_LOGIC_VECTOR ( 63 downto 0 );
		img1pix2r : in STD_LOGIC_VECTOR ( 63 downto 0 );
		img1pix2g : in STD_LOGIC_VECTOR ( 63 downto 0 );
		img1pix2b : in STD_LOGIC_VECTOR ( 63 downto 0 );
		img1pix3r : in STD_LOGIC_VECTOR ( 63 downto 0 );
		img1pix3g : in STD_LOGIC_VECTOR ( 63 downto 0 );
		img1pix3b : in STD_LOGIC_VECTOR ( 63 downto 0 );
		img1pix4r : in STD_LOGIC_VECTOR ( 63 downto 0 );
		img1pix4g : in STD_LOGIC_VECTOR ( 63 downto 0 );
		img1pix4b : in STD_LOGIC_VECTOR ( 63 downto 0 );

		img2pix1r : in STD_LOGIC_VECTOR ( 63 downto 0 );
		img2pix1g : in STD_LOGIC_VECTOR ( 63 downto 0 );
		img2pix1b : in STD_LOGIC_VECTOR ( 63 downto 0 );
		img2pix2r : in STD_LOGIC_VECTOR ( 63 downto 0 );
		img2pix2g : in STD_LOGIC_VECTOR ( 63 downto 0 );
		img2pix2b : in STD_LOGIC_VECTOR ( 63 downto 0 );
		img2pix3r : in STD_LOGIC_VECTOR ( 63 downto 0 );
		img2pix3g : in STD_LOGIC_VECTOR ( 63 downto 0 );
		img2pix3b : in STD_LOGIC_VECTOR ( 63 downto 0 );
		img2pix4r : in STD_LOGIC_VECTOR ( 63 downto 0 );
		img2pix4g : in STD_LOGIC_VECTOR ( 63 downto 0 );
		img2pix4b : in STD_LOGIC_VECTOR ( 63 downto 0 );

		-- Output data signals
		reflpix1r : out STD_LOGIC_VECTOR ( 63 downto 0 );
		reflpix1g : out STD_LOGIC_VECTOR ( 63 downto 0 );
		reflpix1b : out STD_LOGIC_VECTOR ( 63 downto 0 );
		reflpix2r : out STD_LOGIC_VECTOR ( 63 downto 0 );
		reflpix2g : out STD_LOGIC_VECTOR ( 63 downto 0 );
		reflpix2b : out STD_LOGIC_VECTOR ( 63 downto 0 );
		reflpix3r : out STD_LOGIC_VECTOR ( 63 downto 0 );
		reflpix3g : out STD_LOGIC_VECTOR ( 63 downto 0 );
		reflpix3b : out STD_LOGIC_VECTOR ( 63 downto 0 );
		reflpix4r : out STD_LOGIC_VECTOR ( 63 downto 0 );
		reflpix4g : out STD_LOGIC_VECTOR ( 63 downto 0 );
		reflpix4b : out STD_LOGIC_VECTOR ( 63 downto 0 )
	);

end targetwhitediv;

-- Describe the contents of this "chip"
architecture rtl of targetwhitediv is

	component rgbdoublediv is
	port (
		-- Clock and reset
		clk : in std_logic;

		-- Input data signals
		pixr1 : in STD_LOGIC_VECTOR ( 63 downto 0 );
		pixg1 : in STD_LOGIC_VECTOR ( 63 downto 0 );
		pixb1 : in STD_LOGIC_VECTOR ( 63 downto 0 );

		pixr2 : in STD_LOGIC_VECTOR ( 63 downto 0 );
		pixg2 : in STD_LOGIC_VECTOR ( 63 downto 0 );
		pixb2 : in STD_LOGIC_VECTOR ( 63 downto 0 );
		
		-- Output data signals
		pixr : out STD_LOGIC_VECTOR ( 63 downto 0 );
		pixg : out STD_LOGIC_VECTOR ( 63 downto 0 );
		pixb : out STD_LOGIC_VECTOR ( 63 downto 0 )
	);
	
	end component;

begin

	------------------------------------------
	-- Divide target image pixels 
	-- with white image pixels
	------------------------------------------

	pix1div : rgbdoublediv port map(
		clk => clk,
		pixr1 => img1pix1r,
		pixg1 => img1pix1g,
		pixb1 => img1pix1b,
		pixr2 => img2pix1r,
		pixg2 => img2pix1g,
		pixb2 => img2pix1b,
		pixr => reflpix1r,
		pixg => reflpix1g,
		pixb => reflpix1b
	);

	pix2div : rgbdoublediv port map(
		clk => clk,
		pixr1 => img1pix2r,
		pixg1 => img1pix2g,
		pixb1 => img1pix2b,
		pixr2 => img2pix2r,
		pixg2 => img2pix2g,
		pixb2 => img2pix2b,
		pixr => reflpix2r,
		pixg => reflpix2g,
		pixb => reflpix2b
	);

	pix3div : rgbdoublediv port map(
		clk => clk,
		pixr1 => img1pix3r,
		pixg1 => img1pix3g,
		pixb1 => img1pix3b,
		pixr2 => img2pix3r,
		pixg2 => img2pix3g,
		pixb2 => img2pix3b,
		pixr => reflpix3r,
		pixg => reflpix3g,
		pixb => reflpix3b
	);

	pix4div : rgbdoublediv port map(
		clk => clk,
		pixr1 => img1pix4r,
		pixg1 => img1pix4g,
		pixb1 => img1pix4b,
		pixr2 => img2pix4r,
		pixg2 => img2pix4g,
		pixb2 => img2pix4b,
		pixr => reflpix4r,
		pixg => reflpix4g,
		pixb => reflpix4b
	);


end architecture;
