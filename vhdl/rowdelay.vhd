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
		read_data : in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);

		read_done_a : in std_logic;
		read_done_b : in std_logic;
		read_done_c : in std_logic;

		imgsync_ena : in std_logic;
		hsync_ena : in std_logic;
		vsync_ena : in std_logic;

		-- Output data signals
		respix1r : out unsigned(11 downto 0);
		respix1g : out unsigned(11 downto 0);
		respix1b : out unsigned(11 downto 0);

		respix2r : out unsigned(11 downto 0);
		respix2g : out unsigned(11 downto 0);
		respix2b : out unsigned(11 downto 0);

		respix3r : out unsigned(11 downto 0);
		respix3g : out unsigned(11 downto 0);
		respix3b : out unsigned(11 downto 0);

		respix4r : out unsigned(11 downto 0);
		respix4g : out unsigned(11 downto 0);
		respix4b : out unsigned(11 downto 0)

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

	------------------------------------------
	-- cfarows2rgb
	------------------------------------------
	component cfarows2rgb is

		generic(
			C_M_AXI_ADDR_WIDTH	: integer	:= 32;
			C_M_AXI_DATA_WIDTH	: integer	:= 64
		);
	
		port (
	
			-- Clock and reset
			clk : in std_logic;
			resetn	: in std_logic;
	
			-- Input data signals
			readrowodd : in std_logic;
			ram1_rd_data : in std_logic_vector(47 downto 0);
			read_data : in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
	
			-- Output data signals
			pix1r : out unsigned(11 downto 0);
			pix1g : out unsigned(11 downto 0);
			pix1b : out unsigned(11 downto 0);
	
			pix2r : out unsigned(11 downto 0);
			pix2g : out unsigned(11 downto 0);
			pix2b : out unsigned(11 downto 0);
	
			pix3r : out unsigned(11 downto 0);
			pix3g : out unsigned(11 downto 0);
			pix3b : out unsigned(11 downto 0);
	
			pix4r : out unsigned(11 downto 0);
			pix4g : out unsigned(11 downto 0);
			pix4b : out unsigned(11 downto 0)
		);
	
	end component cfarows2rgb;

	-- Direct read
	signal read_data_dark : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal read_data_target : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal read_data_white : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);

	signal pipelinedelay : std_logic_vector(3 downto 0);

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
	signal ram1_rd_data : ram_word_type;
	signal ram1_wr_data : ram_word_type;
	signal ram1_wr : std_logic;

	-- RAM2 signals for white image
	signal ram2_addr : ram_addr_type;
	signal ram2_rd_data : ram_word_type;
	signal ram2_wr_data : ram_word_type;
	signal ram2_wr : std_logic;

	signal firstrowhandled : std_logic;
	signal readrowodd : std_logic;

	-- Image 1 pixel data for four pixels in 36-bit RGB format
	signal read_done_img1_delayed : std_logic;

	signal img1pix1r : unsigned(11 downto 0);
	signal img1pix1g : unsigned(11 downto 0);
	signal img1pix1b : unsigned(11 downto 0);

	signal img1pix2r : unsigned(11 downto 0);
	signal img1pix2g : unsigned(11 downto 0);
	signal img1pix2b : unsigned(11 downto 0);

	signal img1pix3r : unsigned(11 downto 0);
	signal img1pix3g : unsigned(11 downto 0);
	signal img1pix3b : unsigned(11 downto 0);

	signal img1pix4r : unsigned(11 downto 0);
	signal img1pix4g : unsigned(11 downto 0);
	signal img1pix4b : unsigned(11 downto 0);

	-- Image 2 pixel data for four pixels in 36-bit RGB format
	signal read_done_img2_delayed : std_logic;
	
	signal img2pix1r : unsigned(11 downto 0);
	signal img2pix1g : unsigned(11 downto 0);
	signal img2pix1b : unsigned(11 downto 0);

	signal img2pix2r : unsigned(11 downto 0);
	signal img2pix2g : unsigned(11 downto 0);
	signal img2pix2b : unsigned(11 downto 0);

	signal img2pix3r : unsigned(11 downto 0);
	signal img2pix3g : unsigned(11 downto 0);
	signal img2pix3b : unsigned(11 downto 0);

	signal img2pix4r : unsigned(11 downto 0);
	signal img2pix4g : unsigned(11 downto 0);
	signal img2pix4b : unsigned(11 downto 0);

	-- Step 1 calculation result
	signal res1pix1r : unsigned(11 downto 0);
	signal res1pix1g : unsigned(11 downto 0);
	signal res1pix1b : unsigned(11 downto 0);

	signal res1pix2r : unsigned(11 downto 0);
	signal res1pix2g : unsigned(11 downto 0);
	signal res1pix2b : unsigned(11 downto 0);

	signal res1pix3r : unsigned(11 downto 0);
	signal res1pix3g : unsigned(11 downto 0);
	signal res1pix3b : unsigned(11 downto 0);

	signal res1pix4r : unsigned(11 downto 0);
	signal res1pix4g : unsigned(11 downto 0);
	signal res1pix4b : unsigned(11 downto 0);
	
	-- Subtract dark from target
	signal targetsub1 : unsigned(11 downto 0);
	signal targetsub2 : unsigned(11 downto 0);
	signal targetsub3 : unsigned(11 downto 0);
	signal targetsub4 : unsigned(11 downto 0);

	signal targetsubvec : std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);

	-- Subtract dark from white
	signal whitesub1 : unsigned(11 downto 0);
	signal whitesub2 : unsigned(11 downto 0);
	signal whitesub3 : unsigned(11 downto 0);
	signal whitesub4 : unsigned(11 downto 0);

	signal whitesubvec : std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);

	-- Demosaic for target image
	signal targetdmpix1r : unsigned(11 downto 0);
	signal targetdmpix1g : unsigned(11 downto 0);
	signal targetdmpix1b : unsigned(11 downto 0);

	signal targetdmpix2r : unsigned(11 downto 0);
	signal targetdmpix2g : unsigned(11 downto 0);
	signal targetdmpix2b : unsigned(11 downto 0);

	signal targetdmpix3r : unsigned(11 downto 0);
	signal targetdmpix3g : unsigned(11 downto 0);
	signal targetdmpix3b : unsigned(11 downto 0);

	signal targetdmpix4r : unsigned(11 downto 0);
	signal targetdmpix4g : unsigned(11 downto 0);
	signal targetdmpix4b : unsigned(11 downto 0);

	-- Demosaic for white image
	signal whitedmpix1r : unsigned(11 downto 0);
	signal whitedmpix1g : unsigned(11 downto 0);
	signal whitedmpix1b : unsigned(11 downto 0);

	signal whitedmpix2r : unsigned(11 downto 0);
	signal whitedmpix2g : unsigned(11 downto 0);
	signal whitedmpix2b : unsigned(11 downto 0);

	signal whitedmpix3r : unsigned(11 downto 0);
	signal whitedmpix3g : unsigned(11 downto 0);
	signal whitedmpix3b : unsigned(11 downto 0);

	signal whitedmpix4r : unsigned(11 downto 0);
	signal whitedmpix4g : unsigned(11 downto 0);
	signal whitedmpix4b : unsigned(11 downto 0);

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
		rd_data => ram1_rd_data
	);
	
	ram1_wr_data <= std_logic_vector(targetsub1)
				 &	std_logic_vector(targetsub2)
				 &	std_logic_vector(targetsub3)
				 &	std_logic_vector(targetsub4);

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
		rd_data => ram2_rd_data
	);
	
	ram2_wr_data <= std_logic_vector(whitesub1)
				 &	std_logic_vector(whitesub2)
				 &	std_logic_vector(whitesub3)
				 &	std_logic_vector(whitesub4);

	ram2_wr <= read_done_c;

	------------------------------------------
	-- cfarows2rgb1 for target image
	------------------------------------------
	cfarows2rgb1 : cfarows2rgb port map(
	
		-- Clock and reset
		clk => clk,
		resetn => resetn,

		-- Input data signals
		readrowodd => readrowodd,
		ram1_rd_data => ram1_rd_data,

		read_data => targetsubvec,

		-- Output data signals
		pix1r => targetdmpix1r,
		pix1g => targetdmpix1g,
		pix1b => targetdmpix1b,

		pix2r => targetdmpix2r,
		pix2g => targetdmpix2g,
		pix2b => targetdmpix2b,

		pix3r => targetdmpix3r,
		pix3g => targetdmpix3g,
		pix3b => targetdmpix3b,

		pix4r => targetdmpix4r,
		pix4g => targetdmpix4g,
		pix4b => targetdmpix4b
 	);

	------------------------------------------
	-- cfarows2rgb2 for white image
	------------------------------------------
	cfarows2rgb2 : cfarows2rgb port map(
	
		-- Clock and reset
		clk => clk,
		resetn => resetn,

		-- Input data signals
		readrowodd => readrowodd,
		ram1_rd_data => ram2_rd_data,

		read_data => whitesubvec,

		-- Output data signals
		pix1r => whitedmpix1r,
		pix1g => whitedmpix1g,
		pix1b => whitedmpix1b,

		pix2r => whitedmpix2r,
		pix2g => whitedmpix2g,
		pix2b => whitedmpix2b,

		pix3r => whitedmpix3r,
		pix3g => whitedmpix3g,
		pix3b => whitedmpix3b,

		pix4r => whitedmpix4r,
		pix4g => whitedmpix4g,
		pix4b => whitedmpix4b
 	);

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

			pipelinedelay <= (others => '0');

			firstrowhandled <= '0';
			readrowodd <= '0';

			-- Image 1 pixel data for four pixels in 36-bit RGB format
			read_done_img1_delayed <= '0';

			img1pix1r <= to_unsigned(0, 12);
			img1pix1g <= to_unsigned(0, 12);
			img1pix1b <= to_unsigned(0, 12);
			img1pix2r <= to_unsigned(0, 12);
			img1pix2g <= to_unsigned(0, 12);
			img1pix2b <= to_unsigned(0, 12);
			img1pix3r <= to_unsigned(0, 12);
			img1pix3g <= to_unsigned(0, 12);
			img1pix3b <= to_unsigned(0, 12);
			img1pix4r <= to_unsigned(0, 12);
			img1pix4g <= to_unsigned(0, 12);
			img1pix4b <= to_unsigned(0, 12);

			-- Image 2 pixel data for four pixels in 36-bit RGB format
			read_done_img2_delayed <= '0';

			img2pix1r <= to_unsigned(0, 12);
			img2pix1g <= to_unsigned(0, 12);
			img2pix1b <= to_unsigned(0, 12);
			img2pix2r <= to_unsigned(0, 12);
			img2pix2g <= to_unsigned(0, 12);
			img2pix2b <= to_unsigned(0, 12);
			img2pix3r <= to_unsigned(0, 12);
			img2pix3g <= to_unsigned(0, 12);
			img2pix3b <= to_unsigned(0, 12);
			img2pix4r <= to_unsigned(0, 12);
			img2pix4g <= to_unsigned(0, 12);
			img2pix4b <= to_unsigned(0, 12);

			-- Step 1 calculation result
			res1pix1r <= to_unsigned(0, 12);
			res1pix1g <= to_unsigned(0, 12);
			res1pix1b <= to_unsigned(0, 12);
			res1pix2r <= to_unsigned(0, 12);
			res1pix2g <= to_unsigned(0, 12);
			res1pix2b <= to_unsigned(0, 12);
			res1pix3r <= to_unsigned(0, 12);
			res1pix3g <= to_unsigned(0, 12);
			res1pix3b <= to_unsigned(0, 12);
			res1pix4r <= to_unsigned(0, 12);
			res1pix4g <= to_unsigned(0, 12);
			res1pix4b <= to_unsigned(0, 12);

			-- Pipeline processing delay shift register trigger
			pipelinedelay <= (others => '0');

		else

			if (clk'event and clk='1') then

				ram1_addr <= ram1_addr;
				ram2_addr <= ram2_addr;

				-- Direct read
				read_data_dark <= read_data_dark;
				read_data_target <= read_data_target;
				read_data_white <= read_data_white;

				pipelinedelay <= pipelinedelay(pipelinedelay'length-2 downto 0) & pipelinedelay(pipelinedelay'length-1);

				firstrowhandled <= firstrowhandled;
				readrowodd <= readrowodd;

				-- Image 1 pixel data for four pixels in 36-bit RGB format
				read_done_img1_delayed <= '0';

				img1pix1r <= img1pix1r;
				img1pix1g <= img1pix1g;
				img1pix1b <= img1pix1b;
				img1pix2r <= img1pix2r;
				img1pix2g <= img1pix2g;
				img1pix2b <= img1pix2b;
				img1pix3r <= img1pix3r;
				img1pix3g <= img1pix3g;
				img1pix3b <= img1pix3b;
				img1pix4r <= img1pix4r;
				img1pix4g <= img1pix4g;
				img1pix4b <= img1pix4b;

				-- Image 2 pixel data for four pixels in 36-bit RGB format
				read_done_img2_delayed <= '0';

				img2pix1r <= img1pix1r;
				img2pix1g <= img1pix1g;
				img2pix1b <= img1pix1b;
				img2pix2r <= img1pix2r;
				img2pix2g <= img1pix2g;
				img2pix2b <= img1pix2b;
				img2pix3r <= img1pix3r;
				img2pix3g <= img1pix3g;
				img2pix3b <= img1pix3b;
				img2pix4r <= img1pix4r;
				img2pix4g <= img1pix4g;
				img2pix4b <= img1pix4b;

				-- Pipeline processing delay shift register trigger
				pipelinedelay <= pipelinedelay(pipelinedelay'length-2 downto 0) & '0';

				-- Capture image 1
				-- This is dark reference image in BayerGB12 CFA format
				if (read_done_a='1') then

					read_done_img1_delayed <= '1';
					read_data_dark <= unsigned(read_data);
				else
				end if;

				if (read_done_img1_delayed='1') then

					img1pix1r <= targetdmpix1r;
					img1pix1g <= targetdmpix1g;
					img1pix1b <= targetdmpix1b;
					img1pix2r <= targetdmpix2r;
					img1pix2g <= targetdmpix2g;
					img1pix2b <= targetdmpix2b;
					img1pix3r <= targetdmpix3r;
					img1pix3g <= targetdmpix3g;
					img1pix3b <= targetdmpix3b;
					img1pix4r <= targetdmpix4r;
					img1pix4g <= targetdmpix4g;
					img1pix4b <= targetdmpix4b;

				else
				end if;

				-- Capture image 2
				-- This is target image in BayerGB12 CFA format
				if (read_done_b='1') then

					read_done_img2_delayed <= '1';
					read_data_target <= unsigned(read_data);

					-- Increment row delay ram address
					if (ram1_addr=to_unsigned(648,10)) then
						ram1_addr <= to_unsigned(0,10);
						firstrowhandled <= '1';
						readrowodd <= not(readrowodd);
					else
						ram1_addr <= ram1_addr + to_unsigned(1,10);
					end if;

				else
				end if;

				if (read_done_img2_delayed='1') then

					img2pix1r <= whitedmpix1r;
					img2pix1g <= whitedmpix1g;
					img2pix1b <= whitedmpix1b;
					img2pix2r <= whitedmpix2r;
					img2pix2g <= whitedmpix2g;
					img2pix2b <= whitedmpix2b;
					img2pix3r <= whitedmpix3r;
					img2pix3g <= whitedmpix3g;
					img2pix3b <= whitedmpix3b;
					img2pix4r <= whitedmpix4r;
					img2pix4g <= whitedmpix4g;
					img2pix4b <= whitedmpix4b;

					-- Last data read for pipeline processing
					-- Trigger writing after pipeline delay
					pipelinedelay <= pipelinedelay(pipelinedelay'length-2 downto 0) & '1';

				else
				end if;

				-- Capture image 3
				-- This is white reference image in BayerGB12 CFA format
				if (read_done_c='1') then

					read_data_white <= unsigned(read_data);

					-- Increment row delay ram address
					if (ram2_addr=to_unsigned(648,10)) then
						ram2_addr <= to_unsigned(0,10);
						-- firstrowhandled <= '1';
						-- readrowodd <= not(readrowodd);
					else
						ram2_addr <= ram2_addr + to_unsigned(1,10);
					end if;

				else
				end if;

				-- Subtract dark from target
				targetsub1 <= read_data_target(59 downto 48) - read_data_dark(59 downto 48);
				targetsub2 <= read_data_target(43 downto 32) - read_data_dark(43 downto 32);
				targetsub3 <= read_data_target(27 downto 16) - read_data_dark(27 downto 16);
				targetsub4 <= read_data_target(11 downto 0) - read_data_dark(11 downto 0);

				-- Subtract dark from white
				whitesub1 <= read_data_white(59 downto 48) - read_data_dark(59 downto 48);
				whitesub2 <= read_data_white(43 downto 32) - read_data_dark(43 downto 32);
				whitesub3 <= read_data_white(27 downto 16) - read_data_dark(27 downto 16);
				whitesub4 <= read_data_white(11 downto 0) - read_data_dark(11 downto 0);


				-- Step 1 calculation result
				-- Change this, should not be between images,
				-- but point-wise multiplication with coefficients
				res1pix1r <= img1pix1r - img2pix1r;
				res1pix1g <= img1pix1g - img2pix1g;
				res1pix1b <= img1pix1b - img2pix1b;
				res1pix2r <= img1pix2r - img2pix2r;
				res1pix2g <= img1pix2g - img2pix2g;
				res1pix2b <= img1pix2b - img2pix2b;
				res1pix3r <= img1pix3r - img2pix3r;
				res1pix3g <= img1pix3g - img2pix3g;
				res1pix3b <= img1pix3b - img2pix3b;
				res1pix4r <= img1pix4r - img2pix4r;
				res1pix4g <= img1pix4g - img2pix4g;
				res1pix4b <= img1pix4b - img2pix4b;

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

	respix1r <= res1pix1r;
	respix1g <= res1pix1g;
	respix1b <= res1pix1b;

	respix2r <= res1pix2r;
	respix2g <= res1pix2g;
	respix2b <= res1pix2b;

	respix3r <= res1pix3r;
	respix3g <= res1pix3g;
	respix3b <= res1pix3b;

	respix4r <= res1pix4r;
	respix4g <= res1pix4g;
	respix4b <= res1pix4b;
	
end architecture;
