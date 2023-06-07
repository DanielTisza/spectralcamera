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

	------------------------------------------
	-- xfixedtofloat
	---
	-- This component is implemented externally by a customized IP:
	--
	-- Xilinx Vivado Design Suite
	-- LogiCORE IP
	-- Floating-Point Operator v7.1
	--
	-- It is customized to perform conversion from
	-- 12-bit fixed integer value to double-precision floating point
	------------------------------------------
	component xfixedtofloat is
	port (
		aclk : IN STD_LOGIC;
		s_axis_a_tvalid : IN STD_LOGIC;
		s_axis_a_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		m_axis_result_tvalid : OUT STD_LOGIC;
		m_axis_result_tdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
  	);
	end component xfixedtofloat; 

begin

	------------------------------------------
	-- xfixedtofloat for target image
	------------------------------------------
	imgpix1rfd : xfixedtofloat port map(
		aclk => clk,
		s_axis_a_tvalid => '1',
		s_axis_a_tdata => img1pix1rfixed,
		m_axis_result_tdata => img1pix1r
	);


	
end architecture;
