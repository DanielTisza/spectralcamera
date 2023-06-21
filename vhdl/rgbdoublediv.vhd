-----------------------------------------------------------
-- rgbdoublediv.vhd
--
-- Rgbdoublediv
--
-- Copyright: Daniel Tisza, 2023, GPLv3 or later
--
-- ghdl -a -v rgbdoublediv.vhd
-- ghdl -e -v rgbdoublediv
-- ghdl -r rgbdoublediv --vcd=out.vcd
-- gtkwave
--
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Describe the I/O of this "chip"
entity rgbdoublediv is

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

end rgbdoublediv;

-- Describe the contents of this "chip"
architecture rtl of rgbdoublediv is

	------------------------------------------
	-- xdoublediv
	---
	-- This component is implemented externally by a customized IP:
	--
	-- Xilinx Vivado Design Suite
	-- LogiCORE IP
	-- Floating-Point Operator v7.1
	--
	-- It is customized to divide two double-precision floating point
	-- values and give the result as double-precision floating point value.
	--
	------------------------------------------
	component xdoublediv
	port (
		aclk : IN STD_LOGIC;
		s_axis_a_tvalid : IN STD_LOGIC;
		s_axis_a_tdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
		s_axis_b_tvalid : IN STD_LOGIC;
		s_axis_b_tdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
		m_axis_result_tvalid : OUT STD_LOGIC;
		m_axis_result_tdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
	);
	end component;

begin

	------------------------------------------
	-- Divide RGB pixel
	------------------------------------------
	pixrfd : xdoublediv port map(
		aclk => clk,
		s_axis_a_tvalid => '1',
		s_axis_a_tdata => pixr1,
		s_axis_b_tvalid => '1',
		s_axis_b_tdata => pixr2,
		m_axis_result_tdata => pixr
	);

	pixgfd : xdoublediv port map(
		aclk => clk,
		s_axis_a_tvalid => '1',
		s_axis_a_tdata => pixg1,
		s_axis_b_tvalid => '1',
		s_axis_b_tdata => pixg2,
		m_axis_result_tdata => pixg
	);

	pixbfd : xdoublediv port map(
		aclk => clk,
		s_axis_a_tvalid => '1',
		s_axis_a_tdata => pixb1,
		s_axis_b_tvalid => '1',
		s_axis_b_tdata => pixb2,
		m_axis_result_tdata => pixb
	);	

end architecture;
