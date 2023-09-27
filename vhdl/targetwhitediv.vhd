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
		resetn	: in std_logic;

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

	signal muxphase : std_logic;

	-- Divider input signals
	signal divinpix1r : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal divinpix1g : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal divinpix1b : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal divinpix2r : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal divinpix2g : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal divinpix2b : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal divinpix3r : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal divinpix3g : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal divinpix3b : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal divinpix4r : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal divinpix4g : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal divinpix4b : STD_LOGIC_VECTOR ( 63 downto 0 );

	-- Divider output signals
	signal divoutpix1r : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal divoutpix1g : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal divoutpix1b : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal divoutpix2r : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal divoutpix2g : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal divoutpix2b : STD_LOGIC_VECTOR ( 63 downto 0 );

	-- Output buffer
	signal reflpix1r_int : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal reflpix1g_int : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal reflpix1b_int : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal reflpix2r_int : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal reflpix2g_int : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal reflpix2b_int : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal reflpix3r_int : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal reflpix3g_int : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal reflpix3b_int : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal reflpix4r_int : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal reflpix4g_int : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal reflpix4b_int : STD_LOGIC_VECTOR ( 63 downto 0 );

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

	mux_proc : process(
		clk,
		resetn
	)
	begin

		if (resetn='0') then

			muxphase <= '0';

			divinpix1r <= X"0000000000000000";
			divinpix1g <= X"0000000000000000";
			divinpix1b <= X"0000000000000000";
			divinpix2r <= X"0000000000000000";
			divinpix2g <= X"0000000000000000";
			divinpix2b <= X"0000000000000000";
			divinpix3r <= X"0000000000000000";
			divinpix3g <= X"0000000000000000";
			divinpix3b <= X"0000000000000000";
			divinpix4r <= X"0000000000000000";
			divinpix4g <= X"0000000000000000";
			divinpix4b <= X"0000000000000000";

			reflpix1r_int <= X"0000000000000000";
			reflpix1g_int <= X"0000000000000000";
			reflpix1b_int <= X"0000000000000000";
			reflpix2r_int <= X"0000000000000000";
			reflpix2g_int <= X"0000000000000000";
			reflpix2b_int <= X"0000000000000000";
			reflpix3r_int <= X"0000000000000000";
			reflpix3g_int <= X"0000000000000000";
			reflpix3b_int <= X"0000000000000000";
			reflpix4r_int <= X"0000000000000000";
			reflpix4g_int <= X"0000000000000000";
			reflpix4b_int <= X"0000000000000000";

		else

			if (clk'event and clk='1') then

				-- Default values
				reflpix1r_int <= reflpix1r_int;
				reflpix1g_int <= reflpix1g_int;
				reflpix1b_int <= reflpix1b_int;
				reflpix2r_int <= reflpix2r_int;
				reflpix2g_int <= reflpix2g_int;
				reflpix2b_int <= reflpix2b_int;
				reflpix3r_int <= reflpix3r_int;
				reflpix3g_int <= reflpix3g_int;
				reflpix3b_int <= reflpix3b_int;
				reflpix4r_int <= reflpix4r_int;
				reflpix4g_int <= reflpix4g_int;
				reflpix4b_int <= reflpix4b_int;

				muxphase <= not(muxphase);

				if (muxphase='0') then

					-- Input first 2 pixels from both images
					divinpix1r <= img1pix1r;
					divinpix1g <= img1pix1g;
					divinpix1b <= img1pix1b;
					divinpix2r <= img1pix2r;
					divinpix2g <= img1pix2g;
					divinpix2b <= img1pix2b;

					divinpix3r <= img2pix1r;
					divinpix3g <= img2pix1g;
					divinpix3b <= img2pix1b;
					divinpix4r <= img2pix2r;
					divinpix4g <= img2pix2g;
					divinpix4b <= img2pix2b;

					-- Output first 2 pixels from both images
					reflpix1r_int <= divoutpix1r;
					reflpix1g_int <= divoutpix1g;
					reflpix1b_int <= divoutpix1b;
					reflpix2r_int <= divoutpix2r;
					reflpix2g_int <= divoutpix2g;
					reflpix2b_int <= divoutpix2b;
					
				else

					-- Input last 2 pixels from both images
					divinpix1r <= img1pix3r;
					divinpix1g <= img1pix3g;
					divinpix1b <= img1pix3b;
					divinpix2r <= img1pix4r;
					divinpix2g <= img1pix4g;
					divinpix2b <= img1pix4b;

					divinpix3r <= img2pix3r;
					divinpix3g <= img2pix3g;
					divinpix3b <= img2pix3b;
					divinpix4r <= img2pix4r;
					divinpix4g <= img2pix4g;
					divinpix4b <= img2pix4b;

					-- Output last 2 pixels from both images
					reflpix3r_int <= divoutpix1r;
					reflpix3g_int <= divoutpix1g;
					reflpix3b_int <= divoutpix1b;
					reflpix4r_int <= divoutpix2r;
					reflpix4g_int <= divoutpix2g;
					reflpix4b_int <= divoutpix2b;

				end if;

			else
			end if;
		end if;

	end process;

	------------------------------------------
	-- Dividers
	------------------------------------------

	pix1div : rgbdoublediv port map(
		clk => clk,
		pixr1 => divinpix1r,
		pixg1 => divinpix1g,
		pixb1 => divinpix1b,
		pixr2 => divinpix3r,
		pixg2 => divinpix3g,
		pixb2 => divinpix3b,
		pixr => divoutpix1r,
		pixg => divoutpix1g,
		pixb => divoutpix1b
	);

	pix2div : rgbdoublediv port map(
		clk => clk,
		pixr1 => divinpix2r,
		pixg1 => divinpix2g,
		pixb1 => divinpix2b,
		pixr2 => divinpix4r,
		pixg2 => divinpix4g,
		pixb2 => divinpix4b,
		pixr => divoutpix2r,
		pixg => divoutpix2g,
		pixb => divoutpix2b
	);

--	pix3div : rgbdoublediv port map(
--		clk => clk,
--		pixr1 => img1pix3r,
--		pixg1 => img1pix3g,
--		pixb1 => img1pix3b,
--		pixr2 => img2pix3r,
--		pixg2 => img2pix3g,
--		pixb2 => img2pix3b,
--		pixr => reflpix3r,
--		pixg => reflpix3g,
--		pixb => reflpix3b
--	);
--
--	pix4div : rgbdoublediv port map(
--		clk => clk,
--		pixr1 => img1pix4r,
--		pixg1 => img1pix4g,
--		pixb1 => img1pix4b,
--		pixr2 => img2pix4r,
--		pixg2 => img2pix4g,
--		pixb2 => img2pix4b,
--		pixr => reflpix4r,
--		pixg => reflpix4g,
--		pixb => reflpix4b
--	);


	--------------------------
	-- Continuous connections
	--------------------------

	reflpix1r <= reflpix1r_int;
	reflpix1g <= reflpix1g_int;
	reflpix1b <= reflpix1b_int;
	reflpix2r <= reflpix2r_int;
	reflpix2g <= reflpix2g_int;
	reflpix2b <= reflpix2b_int;

	reflpix3r <= reflpix3r_int;
	reflpix3g <= reflpix3g_int;
	reflpix3b <= reflpix3b_int;
	reflpix4r <= reflpix4r_int;
	reflpix4g <= reflpix4g_int;
	reflpix4b <= reflpix4b_int;

end architecture;
