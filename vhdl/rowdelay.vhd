-----------------------------------------------------------
-- rowdelay.vhd
--
-- Rowdelay
--
-- Copyright: Daniel Tisza, 2022, GPLv3 or later
--
-- ghdl -a -v rowdelay.vhd
-- ghdl -e -v rowdelay
-- ghdl -r rowdelay --vcd=out.vcd
-- gtkwave
--
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Describe the I/O of this "chip"
entity rowdelay is

	generic(
		C_M_AXI_ADDR_WIDTH	: integer	:= 32;
		C_M_AXI_DATA_WIDTH	: integer	:= 64
	);

	port (

		-- Clock and reset
		clk : in std_logic;
		resetn	: in std_logic;

		-- Input data signals
		read_done_a : in std_logic;
		read_done_b : in std_logic;
		read_done_c : in std_logic;

		imgsync_ena : in std_logic;
		hsync_ena : in std_logic;
		vsync_ena : in std_logic;

		targetsubvec : in std_logic_vector(47 downto 0);
		whitesubvec : in std_logic_vector(47 downto 0);

		-- Output data signals

		-- Previous row pixels from delay RAM
		ram1_rd_data : out std_logic_vector(47 downto 0);
		ram2_rd_data : out std_logic_vector(47 downto 0);

		-- Current row odd indication
		targetreadrowodd : out std_logic;
		whitereadrowodd : out std_logic;

		-- Ena to capture to output buffer
		read_done_target_delayed : out std_logic;
		read_done_white_delayed : out std_logic
	);

end rowdelay;

-- Describe the contents of this "chip"
architecture rtl of rowdelay is
	
	------------------------------------------
	-- rowdelayram
	------------------------------------------
	component rowdelayram is

		generic(
			C_M_AXI_ADDR_WIDTH	: integer	:= 32;
			C_M_AXI_DATA_WIDTH	: integer	:= 64
		);
	
		port (
	
			-- Clock and reset
			clk : in std_logic;
	
			-- RAM signals
			wr : in std_logic;
			addr : in std_logic_vector(9 downto 0);
			wr_data : in std_logic_vector(47 downto 0);
			rd_data : out std_logic_vector(47 downto 0)
		);
	
	end component rowdelayram;

	-- Delay RAM definition

	-- RAM definitions

	-- RAM data word size
	-- 64 bits contains 4 pixels * 16 bits
	-- Each 16 bits contain only 12 bits effective data
	-- So we get 4 pixels * 12 bits = 48 bits effective data

	-- RAM data word count
	-- 2590 pixels / 4 pixels per 64 bits transfer
	-- 2590/4 = 647.5 = 648

	subtype ram_word_type is std_logic_vector(47 downto 0);
	subtype ram_addr_type is unsigned(9 downto 0);
	
	-- RAM1 signals for target image
	signal ram1_addr : ram_addr_type;
	signal ram1_rd_data_int : ram_word_type;
	signal ram1_wr_data : ram_word_type;
	signal ram1_wr : std_logic;

	-- RAM2 signals for white image
	signal ram2_addr : ram_addr_type;
	signal ram2_rd_data_int : ram_word_type;
	signal ram2_wr_data : ram_word_type;
	signal ram2_wr : std_logic;

	signal targetfirstrowhandled : std_logic;
	signal targetreadrowodd_int : std_logic;
	signal read_done_target_delayed_int : std_logic;

	signal whitefirstrowhandled : std_logic;
	signal whitereadrowodd_int : std_logic;
	signal read_done_white_delayed_int : std_logic;

begin

	------------------------------------------
	-- rowdelayram1 for target image
	------------------------------------------
	rowdelayram1 : rowdelayram port map(

		-- Clock and reset
		clk => clk,
	
		-- RAM signals
		wr => read_done_b,
		addr => std_logic_vector(ram1_addr),
		wr_data => ram1_wr_data,
		rd_data => ram1_rd_data_int
	);
	
	ram1_wr_data <= targetsubvec;

	ram1_wr <= read_done_b;

	------------------------------------------
	-- rowdelayram2 for white image
	------------------------------------------
	rowdelayram2 : rowdelayram port map(

		-- Clock and reset
		clk => clk,
	
		-- RAM signals
		wr => read_done_c,
		addr => std_logic_vector(ram2_addr),
		wr_data => ram2_wr_data,
		rd_data => ram2_rd_data_int
	);
	
	ram2_wr_data <= whitesubvec;

	ram2_wr <= read_done_c;

	------------------------------------------
	-- IO process
	------------------------------------------
	io_proc : process(
		clk,
		resetn
	)
	begin

		if (resetn='0') then

			ram1_addr <= to_unsigned(0,10);
			ram2_addr <= to_unsigned(0,10);

			targetfirstrowhandled <= '0';
			targetreadrowodd_int <= '0';
			read_done_target_delayed_int <= '0';

			whitefirstrowhandled <= '0';
			whitereadrowodd_int <= '0';
			read_done_white_delayed_int <= '0';

		else

			if (clk'event and clk='1') then

				ram1_addr <= ram1_addr;
				ram2_addr <= ram2_addr;

				targetfirstrowhandled <= targetfirstrowhandled;
				targetreadrowodd_int <= targetreadrowodd_int;
				read_done_target_delayed_int <= '0';

				whitefirstrowhandled <= whitefirstrowhandled;
				whitereadrowodd_int <= whitereadrowodd_int;
				read_done_white_delayed_int <= '0';

				-- Capture image 2
				-- This is target image in BayerGB12 CFA format
				if (read_done_b='1') then

					read_done_target_delayed_int <= '1';

					-- Increment row delay ram address
					if (ram1_addr=to_unsigned(648,10)) then
						ram1_addr <= to_unsigned(0,10);
						targetfirstrowhandled <= '1';
						targetreadrowodd_int <= not(targetreadrowodd_int);
					else
						ram1_addr <= ram1_addr + to_unsigned(1,10);
					end if;

				else
				end if;

				-- Capture image 3
				-- This is white reference image in BayerGB12 CFA format
				if (read_done_c='1') then

					read_done_white_delayed_int <= '1';

					-- Increment row delay ram address
					if (ram2_addr=to_unsigned(648,10)) then
						ram2_addr <= to_unsigned(0,10);
						whitefirstrowhandled <= '1';
						whitereadrowodd_int <= not(whitereadrowodd_int);
					else
						ram2_addr <= ram2_addr + to_unsigned(1,10);
					end if;

				else
				end if;

			else
			end if;
			
		end if;

	end process;

	--
	-- Continuous connections
	--

	ram1_rd_data <= ram1_rd_data_int;
	ram2_rd_data <= ram2_rd_data_int;

	targetreadrowodd <= targetreadrowodd_int;
	read_done_target_delayed <= read_done_target_delayed_int;

	whitereadrowodd <= whitereadrowodd_int;
	read_done_white_delayed <= read_done_white_delayed_int;

end architecture;
