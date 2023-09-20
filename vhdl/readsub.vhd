-----------------------------------------------------------
-- readsub.vhd
--
-- Read pixel data subtracting
--
-- Copyright: Daniel Tisza, 2022, GPLv3 or later
--
-- ghdl -a -v readsub.vhd
-- ghdl -e -v readsub
-- ghdl -r readsub --vcd=out.vcd
-- gtkwave
--
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Describe the I/O of this "chip"
entity readsub is

	generic(
		C_M_AXI_ADDR_WIDTH	: integer	:= 32;
		C_M_AXI_DATA_WIDTH	: integer	:= 64
	);

	port (

		-- Clock and reset
		clk : in std_logic;
		resetn	: in std_logic;

		-- Input data signals
		read_data : in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);

		read_done_a : in std_logic;
		read_done_b : in std_logic;
		read_done_c : in std_logic;

		-- Output data signals
		targetsubvec : out std_logic_vector(47 downto 0);
		whitesubvec : out std_logic_vector(47 downto 0)
	);

end readsub;

-- Describe the contents of this "chip"
architecture rtl of readsub is

	-- Direct read
	signal read_data_dark : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal read_data_target : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal read_data_white : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
		
	-- Subtract dark from target
	signal targetsub1 : unsigned(11 downto 0);
	signal targetsub2 : unsigned(11 downto 0);
	signal targetsub3 : unsigned(11 downto 0);
	signal targetsub4 : unsigned(11 downto 0);

	-- Subtract dark from white
	signal whitesub1 : unsigned(11 downto 0);
	signal whitesub2 : unsigned(11 downto 0);
	signal whitesub3 : unsigned(11 downto 0);
	signal whitesub4 : unsigned(11 downto 0);

begin

	------------------------------------------
	-- IO process
	------------------------------------------
	io_proc : process(
		clk,
		resetn
	)
	begin

		if (resetn='0') then

			-- Direct read
			read_data_dark <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			read_data_target <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			read_data_white <= to_unsigned(0, C_M_AXI_DATA_WIDTH);

			-- Subtract dark from target
			targetsub1 <= to_unsigned(0, 12);
			targetsub2 <= to_unsigned(0, 12);
			targetsub3 <= to_unsigned(0, 12);
			targetsub4 <= to_unsigned(0, 12);

			-- Subtract dark from target
			whitesub1 <= to_unsigned(0, 12);
			whitesub2 <= to_unsigned(0, 12);
			whitesub3 <= to_unsigned(0, 12);
			whitesub4 <= to_unsigned(0, 12);

		else

			if (clk'event and clk='1') then

				-- Direct read
				read_data_dark <= read_data_dark;
				read_data_target <= read_data_target;
				read_data_white <= read_data_white;

				-- Capture image 1
				-- This is dark reference image in BayerGB12 CFA format
				if (read_done_a='1') then
					read_data_dark <= unsigned(read_data);
				else
				end if;

				-- Capture image 2
				-- This is target image in BayerGB12 CFA format
				if (read_done_b='1') then
					read_data_target <= unsigned(read_data);
				else
				end if;

				-- Capture image 3
				-- This is white reference image in BayerGB12 CFA format
				if (read_done_c='1') then
					read_data_white <= unsigned(read_data);
				else
				end if;

				----------------------------
				-- Subtract dark image in BayerGB12 CFA format
				----------------------------

				-- Target image after subtracting dark image
				targetsub1 <= read_data_target(59 downto 48) - read_data_dark(59 downto 48);
				targetsub2 <= read_data_target(43 downto 32) - read_data_dark(43 downto 32);
				targetsub3 <= read_data_target(27 downto 16) - read_data_dark(27 downto 16);
				targetsub4 <= read_data_target(11 downto 0) - read_data_dark(11 downto 0);

				-- White image after subtracting dark image
				whitesub1 <= read_data_white(59 downto 48) - read_data_dark(59 downto 48);
				whitesub2 <= read_data_white(43 downto 32) - read_data_dark(43 downto 32);
				whitesub3 <= read_data_white(27 downto 16) - read_data_dark(27 downto 16);
				whitesub4 <= read_data_white(11 downto 0) - read_data_dark(11 downto 0);

			else
			end if;
			
		end if;

	end process;

	--
	-- Continuous connections
	--

	targetsubvec <=	std_logic_vector(targetsub1)
				&	std_logic_vector(targetsub2)
				&	std_logic_vector(targetsub3)
				&	std_logic_vector(targetsub4);

	whitesubvec <=	std_logic_vector(whitesub1)
				&	std_logic_vector(whitesub2)
				&	std_logic_vector(whitesub3)
				&	std_logic_vector(whitesub4);
	
end architecture;
