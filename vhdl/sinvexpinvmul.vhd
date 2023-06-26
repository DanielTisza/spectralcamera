-----------------------------------------------------------
-- sinvexpinvmul.vhd
--
-- Sinvexpinvmul
--
-- Copyright: Daniel Tisza, 2023, GPLv3 or later
--
-- ghdl -a -v sinvexpinvmul.vhd
-- ghdl -e -v sinvexpinvmul
-- ghdl -r sinvexpinvmul --vcd=out.vcd
-- gtkwave
--
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Describe the I/O of this "chip"
entity sinvexpinvmul is

	port (

		-- Clock and reset
		clk : in std_logic;

		-- Input data signals
		sinvexpinvr : in STD_LOGIC_VECTOR ( 63 downto 0 );
		sinvexpinvg : in STD_LOGIC_VECTOR ( 63 downto 0 );
		sinvexpinvb : in STD_LOGIC_VECTOR ( 63 downto 0 );

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
		rad1pix1r : out STD_LOGIC_VECTOR ( 63 downto 0 );
		rad1pix1g : out STD_LOGIC_VECTOR ( 63 downto 0 );
		rad1pix1b : out STD_LOGIC_VECTOR ( 63 downto 0 );
		rad1pix2r : out STD_LOGIC_VECTOR ( 63 downto 0 );
		rad1pix2g : out STD_LOGIC_VECTOR ( 63 downto 0 );
		rad1pix2b : out STD_LOGIC_VECTOR ( 63 downto 0 );
		rad1pix3r : out STD_LOGIC_VECTOR ( 63 downto 0 );
		rad1pix3g : out STD_LOGIC_VECTOR ( 63 downto 0 );
		rad1pix3b : out STD_LOGIC_VECTOR ( 63 downto 0 );
		rad1pix4r : out STD_LOGIC_VECTOR ( 63 downto 0 );
		rad1pix4g : out STD_LOGIC_VECTOR ( 63 downto 0 );
		rad1pix4b : out STD_LOGIC_VECTOR ( 63 downto 0 );

		rad2pix1r : out STD_LOGIC_VECTOR ( 63 downto 0 );
		rad2pix1g : out STD_LOGIC_VECTOR ( 63 downto 0 );
		rad2pix1b : out STD_LOGIC_VECTOR ( 63 downto 0 );
		rad2pix2r : out STD_LOGIC_VECTOR ( 63 downto 0 );
		rad2pix2g : out STD_LOGIC_VECTOR ( 63 downto 0 );
		rad2pix2b : out STD_LOGIC_VECTOR ( 63 downto 0 );
		rad2pix3r : out STD_LOGIC_VECTOR ( 63 downto 0 );
		rad2pix3g : out STD_LOGIC_VECTOR ( 63 downto 0 );
		rad2pix3b : out STD_LOGIC_VECTOR ( 63 downto 0 );
		rad2pix4r : out STD_LOGIC_VECTOR ( 63 downto 0 );
		rad2pix4g : out STD_LOGIC_VECTOR ( 63 downto 0 );
		rad2pix4b : out STD_LOGIC_VECTOR ( 63 downto 0 )
	);

end sinvexpinvmul;

-- Describe the contents of this "chip"
architecture rtl of sinvexpinvmul is

	component rgbdoublemul
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
	-- Multiply target image pixels
	------------------------------------------
	img1pix1mul : rgbdoublemul port map(
		clk => clk,
		pixr1 => sinvexpinvr,
		pixg1 => sinvexpinvg,
		pixb1 => sinvexpinvb,
		pixr2 => img1pix1r,
		pixg2 => img1pix1g,
		pixb2 => img1pix1b,
		pixr => rad1pix1r,
		pixg => rad1pix1g,
		pixb => rad1pix1b
	);

	img1pix2mul : rgbdoublemul port map(
		clk => clk,
		pixr1 => sinvexpinvr,
		pixg1 => sinvexpinvg,
		pixb1 => sinvexpinvb,
		pixr2 => img1pix2r,
		pixg2 => img1pix2g,
		pixb2 => img1pix2b,
		pixr => rad1pix2r,
		pixg => rad1pix2g,
		pixb => rad1pix2b
	);

	img1pix3mul : rgbdoublemul port map(
		clk => clk,
		pixr1 => sinvexpinvr,
		pixg1 => sinvexpinvg,
		pixb1 => sinvexpinvb,
		pixr2 => img1pix3r,
		pixg2 => img1pix3g,
		pixb2 => img1pix3b,
		pixr => rad1pix3r,
		pixg => rad1pix3g,
		pixb => rad1pix3b
	);

	img1pix4mul : rgbdoublemul port map(
		clk => clk,
		pixr1 => sinvexpinvr,
		pixg1 => sinvexpinvg,
		pixb1 => sinvexpinvb,
		pixr2 => img1pix4r,
		pixg2 => img1pix4g,
		pixb2 => img1pix4b,
		pixr => rad1pix4r,
		pixg => rad1pix4g,
		pixb => rad1pix4b
	);

	------------------------------------------
	-- Convert white image pixels
	------------------------------------------
	img2pix1mul : rgbdoublemul port map(
		clk => clk,
		pixr1 => sinvexpinvr,
		pixg1 => sinvexpinvg,
		pixb1 => sinvexpinvb,
		pixr2 => img2pix1r,
		pixg2 => img2pix1g,
		pixb2 => img2pix1b,
		pixr => rad2pix1r,
		pixg => rad2pix1g,
		pixb => rad2pix1b
	);

	img2pix2mul : rgbdoublemul port map(
		clk => clk,
		pixr1 => sinvexpinvr,
		pixg1 => sinvexpinvg,
		pixb1 => sinvexpinvb,
		pixr2 => img2pix2r,
		pixg2 => img2pix2g,
		pixb2 => img2pix2b,
		pixr => rad2pix2r,
		pixg => rad2pix2g,
		pixb => rad2pix2b
	);

	img2pix3mul : rgbdoublemul port map(
		clk => clk,
		pixr1 => sinvexpinvr,
		pixg1 => sinvexpinvg,
		pixb1 => sinvexpinvb,
		pixr2 => img2pix3r,
		pixg2 => img2pix3g,
		pixb2 => img2pix3b,
		pixr => rad2pix3r,
		pixg => rad2pix3g,
		pixb => rad2pix3b
	);

	img2pix4mul : rgbdoublemul port map(
		clk => clk,
		pixr1 => sinvexpinvr,
		pixg1 => sinvexpinvg,
		pixb1 => sinvexpinvb,
		pixr2 => img2pix4r,
		pixg2 => img2pix4g,
		pixb2 => img2pix4b,
		pixr => rad2pix4r,
		pixg => rad2pix4g,
		pixb => rad2pix4b
	);	

end architecture;
