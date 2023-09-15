-----------------------------------------------------------
-- rgbfixedtodouble.vhd
--
-- Rgbfixedtodouble
--
-- Copyright: Daniel Tisza, 2023, GPLv3 or later
--
-- ghdl -a -v rgbfixedtodouble.vhd
-- ghdl -e -v rgbfixedtodouble
-- ghdl -r rgbfixedtodouble --vcd=out.vcd
-- gtkwave
--
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Describe the I/O of this "chip"
entity rgbfixedtodouble is

	port (

		-- Clock and reset
		clk : in std_logic;

		-- Input data signals
		pixrfixed : in STD_LOGIC_VECTOR ( 11 downto 0 );
		pixgfixed : in STD_LOGIC_VECTOR ( 11 downto 0 );
		pixbfixed : in STD_LOGIC_VECTOR ( 11 downto 0 );
		
		-- Output data signals
		pixr : out STD_LOGIC_VECTOR ( 63 downto 0 );
		pixg : out STD_LOGIC_VECTOR ( 63 downto 0 );
		pixb : out STD_LOGIC_VECTOR ( 63 downto 0 )
	);

end rgbfixedtodouble;

-- Describe the contents of this "chip"
architecture rtl of rgbfixedtodouble is

	------------------------------------------
	-- xfixedtodouble
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
	component xfixedtodouble is
	port (
		aclk : IN STD_LOGIC;
		s_axis_a_tvalid : IN STD_LOGIC;
		s_axis_a_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		m_axis_result_tvalid : OUT STD_LOGIC;
		m_axis_result_tdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
  	);
	end component; 

	signal pixrfixed15 : STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal pixgfixed15 : STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal pixbfixed15 : STD_LOGIC_VECTOR(15 DOWNTO 0);

begin

	-- Expand from 12 bits to 16 bits for xfixedtodouble
	pixrfixed15 <= "0000" & pixrfixed;
	pixgfixed15 <= "0000" & pixgfixed;
	pixbfixed15 <= "0000" & pixbfixed;

	------------------------------------------
	-- Convert RGB pixel from 12-bit fixed integer
    -- to double-precision floating point value
	------------------------------------------
	pixrfd : xfixedtodouble port map(
		aclk => clk,
		s_axis_a_tvalid => '1',
		s_axis_a_tdata => pixrfixed15,
		m_axis_result_tdata => pixr
	);

	pixgfd : xfixedtodouble port map(
		aclk => clk,
		s_axis_a_tvalid => '1',
		s_axis_a_tdata => pixgfixed15,
		m_axis_result_tdata => pixg
	);

	pixbfd : xfixedtodouble port map(
		aclk => clk,
		s_axis_a_tvalid => '1',
		s_axis_a_tdata => pixbfixed15,
		m_axis_result_tdata => pixb
	);	

end architecture;
