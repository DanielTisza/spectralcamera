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
		resetn	: in std_logic;

		-- Input data signals
		img1pix1rfixed : in STD_LOGIC_VECTOR ( 11 downto 0 );
		img1pix1gfixed : in STD_LOGIC_VECTOR ( 11 downto 0 );
		img1pix1bfixed : in STD_LOGIC_VECTOR ( 11 downto 0 );
		img1pix2rfixed : in STD_LOGIC_VECTOR ( 11 downto 0 );
		img1pix2gfixed : in STD_LOGIC_VECTOR ( 11 downto 0 );
		img1pix2bfixed : in STD_LOGIC_VECTOR ( 11 downto 0 );
		img1pix3rfixed : in STD_LOGIC_VECTOR ( 11 downto 0 );
		img1pix3gfixed : in STD_LOGIC_VECTOR ( 11 downto 0 );
		img1pix3bfixed : in STD_LOGIC_VECTOR ( 11 downto 0 );
		img1pix4rfixed : in STD_LOGIC_VECTOR ( 11 downto 0 );
		img1pix4gfixed : in STD_LOGIC_VECTOR ( 11 downto 0 );
		img1pix4bfixed : in STD_LOGIC_VECTOR ( 11 downto 0 );
 
		img2pix1rfixed : in STD_LOGIC_VECTOR ( 11 downto 0 ); 
		img2pix1gfixed : in STD_LOGIC_VECTOR ( 11 downto 0 ); 
		img2pix1bfixed : in STD_LOGIC_VECTOR ( 11 downto 0 ); 
		img2pix2rfixed : in STD_LOGIC_VECTOR ( 11 downto 0 ); 
		img2pix2gfixed : in STD_LOGIC_VECTOR ( 11 downto 0 ); 
		img2pix2bfixed : in STD_LOGIC_VECTOR ( 11 downto 0 ); 
		img2pix3rfixed : in STD_LOGIC_VECTOR ( 11 downto 0 ); 
		img2pix3gfixed : in STD_LOGIC_VECTOR ( 11 downto 0 ); 
		img2pix3bfixed : in STD_LOGIC_VECTOR ( 11 downto 0 ); 
		img2pix4rfixed : in STD_LOGIC_VECTOR ( 11 downto 0 ); 
		img2pix4gfixed : in STD_LOGIC_VECTOR ( 11 downto 0 ); 
		img2pix4bfixed : in STD_LOGIC_VECTOR ( 11 downto 0 ); 
		
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

	signal muxphase : std_logic;
	
	-- Fixedtodouble input signals
	signal ftodinpix1r : STD_LOGIC_VECTOR ( 11 downto 0 );
	signal ftodinpix1g : STD_LOGIC_VECTOR ( 11 downto 0 );
	signal ftodinpix1b : STD_LOGIC_VECTOR ( 11 downto 0 );
	signal ftodinpix2r : STD_LOGIC_VECTOR ( 11 downto 0 );
	signal ftodinpix2g : STD_LOGIC_VECTOR ( 11 downto 0 );
	signal ftodinpix2b : STD_LOGIC_VECTOR ( 11 downto 0 );
	signal ftodinpix3r : STD_LOGIC_VECTOR ( 11 downto 0 );
	signal ftodinpix3g : STD_LOGIC_VECTOR ( 11 downto 0 );
	signal ftodinpix3b : STD_LOGIC_VECTOR ( 11 downto 0 );
	signal ftodinpix4r : STD_LOGIC_VECTOR ( 11 downto 0 );
	signal ftodinpix4g : STD_LOGIC_VECTOR ( 11 downto 0 );
	signal ftodinpix4b : STD_LOGIC_VECTOR ( 11 downto 0 );

	-- Fixedtodouble output signals
	signal ftodoutpix1r : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal ftodoutpix1g : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal ftodoutpix1b : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal ftodoutpix2r : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal ftodoutpix2g : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal ftodoutpix2b : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal ftodoutpix3r : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal ftodoutpix3g : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal ftodoutpix3b : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal ftodoutpix4r : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal ftodoutpix4g : STD_LOGIC_VECTOR ( 63 downto 0 );
	signal ftodoutpix4b : STD_LOGIC_VECTOR ( 63 downto 0 );

	component rgbfixedtodouble is
	port (
		clk : in std_logic;
		pixrfixed : in STD_LOGIC_VECTOR ( 11 downto 0 );
		pixgfixed : in STD_LOGIC_VECTOR ( 11 downto 0 );
		pixbfixed : in STD_LOGIC_VECTOR ( 11 downto 0 );
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

			ftodinpix1r <= X"000";
			ftodinpix1g <= X"000";
			ftodinpix1b <= X"000";
			ftodinpix2r <= X"000";
			ftodinpix2g <= X"000";
			ftodinpix2b <= X"000";
			ftodinpix3r <= X"000";
			ftodinpix3g <= X"000";
			ftodinpix3b <= X"000";
			ftodinpix4r <= X"000";
			ftodinpix4g <= X"000";
			ftodinpix4b <= X"000";

		else

			if (clk'event and clk='1') then

				muxphase <= not(muxphase);

				if (muxphase='0') then

					-- Input first 2 pixels from both images
					ftodinpix1r <= img1pix1rfixed;
					ftodinpix1g <= img1pix1gfixed;
					ftodinpix1b <= img1pix1bfixed;
					ftodinpix2r <= img1pix2rfixed;
					ftodinpix2g <= img1pix2gfixed;
					ftodinpix2b <= img1pix2bfixed;

					ftodinpix3r <= img2pix1rfixed;
					ftodinpix3g <= img2pix1gfixed;
					ftodinpix3b <= img2pix1bfixed;
					ftodinpix4r <= img2pix2rfixed;
					ftodinpix4g <= img2pix2gfixed;
					ftodinpix4b <= img2pix2bfixed;

					-- Output first 2 pixels from both images
					img1pix1r <= ftodoutpix1r;
					img1pix1g <= ftodoutpix1g;
					img1pix1b <= ftodoutpix1b;
					img1pix2r <= ftodoutpix2r;
					img1pix2g <= ftodoutpix2g;
					img1pix2b <= ftodoutpix2b;

					img2pix1r <= ftodoutpix3r;
					img2pix1g <= ftodoutpix3g;
					img2pix1b <= ftodoutpix3b;
					img2pix2r <= ftodoutpix4r;
					img2pix2g <= ftodoutpix4g;
					img2pix2b <= ftodoutpix4b;
					
				else

					-- Input last 2 pixels from both images
					ftodinpix1r <= img1pix3rfixed;
					ftodinpix1g <= img1pix3gfixed;
					ftodinpix1b <= img1pix3bfixed;
					ftodinpix2r <= img1pix4rfixed;
					ftodinpix2g <= img1pix4gfixed;
					ftodinpix2b <= img1pix4bfixed;
					
					ftodinpix3r <= img2pix3rfixed;
					ftodinpix3g <= img2pix3gfixed;
					ftodinpix3b <= img2pix3bfixed;
					ftodinpix4r <= img2pix4rfixed;
					ftodinpix4g <= img2pix4gfixed;
					ftodinpix4b <= img2pix4bfixed;

					-- Output last 2 pixels from both images
					img1pix3r <= ftodoutpix1r;
					img1pix3g <= ftodoutpix1g;
					img1pix3b <= ftodoutpix1b;
					img1pix4r <= ftodoutpix2r;
					img1pix4g <= ftodoutpix2g;
					img1pix4b <= ftodoutpix2b;

					img2pix3r <= ftodoutpix3r;
					img2pix3g <= ftodoutpix3g;
					img2pix3b <= ftodoutpix3b;
					img2pix4r <= ftodoutpix4r;
					img2pix4g <= ftodoutpix4g;
					img2pix4b <= ftodoutpix4b;

				end if;

			else
			end if;
		end if;

	end process;

	------------------------------------------
	-- Fixed to double converters
	------------------------------------------
	img1pix1fd : rgbfixedtodouble port map(
		clk => clk,
		pixrfixed => ftodinpix1r,
		pixgfixed => ftodinpix1g,
		pixbfixed => ftodinpix1b,
		pixr => ftodoutpix1r,
		pixg => ftodoutpix1g,
		pixb => ftodoutpix1b
	);

	img1pix2fd : rgbfixedtodouble port map(
		clk => clk,
		pixrfixed => ftodinpix2r,
		pixgfixed => ftodinpix2g,
		pixbfixed => ftodinpix2b,
		pixr => ftodoutpix2r,
		pixg => ftodoutpix2g,
		pixb => ftodoutpix2b
	);

	img1pix3fd : rgbfixedtodouble port map(
		clk => clk,
		pixrfixed => ftodinpix3r,
		pixgfixed => ftodinpix3g,
		pixbfixed => ftodinpix3b,
		pixr => ftodoutpix3r,
		pixg => ftodoutpix3g,
		pixb => ftodoutpix3b
	);

	img1pix4fd : rgbfixedtodouble port map(
		clk => clk,
		pixrfixed => ftodinpix4r,
		pixgfixed => ftodinpix4g,
		pixbfixed => ftodinpix4b,
		pixr => ftodoutpix4r,
		pixg => ftodoutpix4g,
		pixb => ftodoutpix4b
	);

	------------------------------------------
	-- Convert white image pixels
	------------------------------------------
--	img2pix1fd : rgbfixedtodouble port map(
--		clk => clk,
--		pixrfixed => img2pix1rfixed,
--		pixgfixed => img2pix1gfixed,
--		pixbfixed => img2pix1bfixed,
--		pixr => img2pix1r,
--		pixg => img2pix1g,
--		pixb => img2pix1b
--	);
--
--	img2pix2fd : rgbfixedtodouble port map(
--		clk => clk,
--		pixrfixed => img2pix2rfixed,
--		pixgfixed => img2pix2gfixed,
--		pixbfixed => img2pix2bfixed,
--		pixr => img2pix2r,
--		pixg => img2pix2g,
--		pixb => img2pix2b
--	);
--
--	img2pix3fd : rgbfixedtodouble port map(
--		clk => clk,
--		pixrfixed => img2pix3rfixed,
--		pixgfixed => img2pix3gfixed,
--		pixbfixed => img2pix3bfixed,
--		pixr => img2pix3r,
--		pixg => img2pix3g,
--		pixb => img2pix3b
--	);
--
--	img2pix4fd : rgbfixedtodouble port map(
--		clk => clk,
--		pixrfixed => img2pix4rfixed,
--		pixgfixed => img2pix4gfixed,
--		pixbfixed => img2pix4bfixed,
--		pixr => img2pix4r,
--		pixg => img2pix4g,
--		pixb => img2pix4b
--	);

end architecture;
