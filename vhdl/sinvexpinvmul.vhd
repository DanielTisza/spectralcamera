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
		resetn	: in std_logic;

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

	signal muxphase : std_logic;
	
	-- Multipliers input signals
	signal mulinpix1r : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal mulinpix1g : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal mulinpix1b : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal mulinpix2r : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal mulinpix2g : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal mulinpix2b : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal mulinpix3r : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal mulinpix3g : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal mulinpix3b : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal mulinpix4r : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal mulinpix4g : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal mulinpix4b : STD_LOGIC_VECTOR ( 63 downto 0 );

	-- Multipliers output signals
	signal muloutpix1r : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal muloutpix1g : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal muloutpix1b : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal muloutpix2r : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal muloutpix2g : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal muloutpix2b : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal muloutpix3r : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal muloutpix3g : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal muloutpix3b : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal muloutpix4r : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal muloutpix4g : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal muloutpix4b : STD_LOGIC_VECTOR ( 63 downto 0 );

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

	mux_proc : process(
		clk,
		resetn
	)
	begin

		if (resetn='0') then

			muxphase <= '0';

			mulinpix1r <= X"0000000000000000";
			mulinpix1g <= X"0000000000000000";
			mulinpix1b <= X"0000000000000000";
			mulinpix2r <= X"0000000000000000";
			mulinpix2g <= X"0000000000000000";
			mulinpix2b <= X"0000000000000000";
			mulinpix3r <= X"0000000000000000";
			mulinpix3g <= X"0000000000000000";
			mulinpix3b <= X"0000000000000000";
			mulinpix4r <= X"0000000000000000";
			mulinpix4g <= X"0000000000000000";
			mulinpix4b <= X"0000000000000000";

		else

			if (clk'event and clk='1') then

				muxphase <= not(muxphase);

				if (muxphase='0') then

					-- Input first 2 pixels from both images
					mulinpix1r <= img1pix1r;
					mulinpix1g <= img1pix1g;
					mulinpix1b <= img1pix1b;
					mulinpix2r <= img1pix2r;
					mulinpix2g <= img1pix2g;
					mulinpix2b <= img1pix2b;

					mulinpix3r <= img2pix1r;
					mulinpix3g <= img2pix1g;
					mulinpix3b <= img2pix1b;
					mulinpix4r <= img2pix2r;
					mulinpix4g <= img2pix2g;
					mulinpix4b <= img2pix2b;

					-- Output first 2 pixels from both images
					rad1pix1r <= muloutpix1r;
					rad1pix1g <= muloutpix1g;
					rad1pix1b <= muloutpix1b;
					rad1pix2r <= muloutpix2r;
					rad1pix2g <= muloutpix2g;
					rad1pix2b <= muloutpix2b;

					rad2pix1r <= muloutpix3r;
					rad2pix1g <= muloutpix3g;
					rad2pix1b <= muloutpix3b;
					rad2pix2r <= muloutpix4r;
					rad2pix2g <= muloutpix4g;
					rad2pix2b <= muloutpix4b;
					
				else

					-- Input last 2 pixels from both images
					mulinpix1r <= img1pix3r;
					mulinpix1g <= img1pix3g;
					mulinpix1b <= img1pix3b;
					mulinpix2r <= img1pix4r;
					mulinpix2g <= img1pix4g;
					mulinpix2b <= img1pix4b;

					mulinpix3r <= img2pix3r;
					mulinpix3g <= img2pix3g;
					mulinpix3b <= img2pix3b;
					mulinpix4r <= img2pix4r;
					mulinpix4g <= img2pix4g;
					mulinpix4b <= img2pix4b;

					-- Output last 2 pixels from both images
					rad1pix3r <= muloutpix1r;
					rad1pix3g <= muloutpix1g;
					rad1pix3b <= muloutpix1b;
					rad1pix4r <= muloutpix2r;
					rad1pix4g <= muloutpix2g;
					rad1pix4b <= muloutpix2b;

					rad2pix3r <= muloutpix3r;
					rad2pix3g <= muloutpix3g;
					rad2pix3b <= muloutpix3b;
					rad2pix4r <= muloutpix4r;
					rad2pix4g <= muloutpix4g;
					rad2pix4b <= muloutpix4b;

				end if;

			else
			end if;
		end if;

	end process;

	------------------------------------------
	-- Multipliers
	------------------------------------------
	img1pix1mul : rgbdoublemul port map(
		clk => clk,
		pixr1 => sinvexpinvr,
		pixg1 => sinvexpinvg,
		pixb1 => sinvexpinvb,
		pixr2 => mulinpix1r,
		pixg2 => mulinpix1g,
		pixb2 => mulinpix1b,
		pixr => muloutpix1r,
		pixg => muloutpix1g,
		pixb => muloutpix1b
	);

	img1pix2mul : rgbdoublemul port map(
		clk => clk,
		pixr1 => sinvexpinvr,
		pixg1 => sinvexpinvg,
		pixb1 => sinvexpinvb,
		pixr2 => mulinpix2r,
		pixg2 => mulinpix2g,
		pixb2 => mulinpix2b,
		pixr => muloutpix2r,
		pixg => muloutpix2g,
		pixb => muloutpix2b
	);

	img1pix3mul : rgbdoublemul port map(
		clk => clk,
		pixr1 => sinvexpinvr,
		pixg1 => sinvexpinvg,
		pixb1 => sinvexpinvb,
		pixr2 => mulinpix3r,
		pixg2 => mulinpix3g,
		pixb2 => mulinpix3b,
		pixr => muloutpix3r,
		pixg => muloutpix3g,
		pixb => muloutpix3b
	);

	img1pix4mul : rgbdoublemul port map(
		clk => clk,
		pixr1 => sinvexpinvr,
		pixg1 => sinvexpinvg,
		pixb1 => sinvexpinvb,
		pixr2 => mulinpix4r,
		pixg2 => mulinpix4g,
		pixb2 => mulinpix4b,
		pixr => muloutpix4r,
		pixg => muloutpix4g,
		pixb => muloutpix4b
	);

	------------------------------------------
	-- Multiply white image pixels
	------------------------------------------
--	img2pix1mul : rgbdoublemul port map(
--		clk => clk,
--		pixr1 => sinvexpinvr,
--		pixg1 => sinvexpinvg,
--		pixb1 => sinvexpinvb,
--		pixr2 => img2pix1r,
--		pixg2 => img2pix1g,
--		pixb2 => img2pix1b,
--		pixr => rad2pix1r,
--		pixg => rad2pix1g,
--		pixb => rad2pix1b
--	);
--
--	img2pix2mul : rgbdoublemul port map(
--		clk => clk,
--		pixr1 => sinvexpinvr,
--		pixg1 => sinvexpinvg,
--		pixb1 => sinvexpinvb,
--		pixr2 => img2pix2r,
--		pixg2 => img2pix2g,
--		pixb2 => img2pix2b,
--		pixr => rad2pix2r,
--		pixg => rad2pix2g,
--		pixb => rad2pix2b
--	);
--
--	img2pix3mul : rgbdoublemul port map(
--		clk => clk,
--		pixr1 => sinvexpinvr,
--		pixg1 => sinvexpinvg,
--		pixb1 => sinvexpinvb,
--		pixr2 => img2pix3r,
--		pixg2 => img2pix3g,
--		pixb2 => img2pix3b,
--		pixr => rad2pix3r,
--		pixg => rad2pix3g,
--		pixb => rad2pix3b
--	);
--
--	img2pix4mul : rgbdoublemul port map(
--		clk => clk,
--		pixr1 => sinvexpinvr,
--		pixg1 => sinvexpinvg,
--		pixb1 => sinvexpinvb,
--		pixr2 => img2pix4r,
--		pixg2 => img2pix4g,
--		pixb2 => img2pix4b,
--		pixr => rad2pix4r,
--		pixg => rad2pix4g,
--		pixb => rad2pix4b
--	);	

end architecture;
