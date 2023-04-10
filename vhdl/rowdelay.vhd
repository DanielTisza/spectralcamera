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

		-- Writing channel signals
		write_ready : in std_logic;
		write_ena : out std_logic;
		write_addr : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		write_data : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0)

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
	signal src1A : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal src2A : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal src3A : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);

	-- Delayed signals
	signal src1B : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal src2B : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal src3B : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);

	-- Computations
	signal result1 : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal result2 : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal result3 : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);

	-- Destination data to DDR memory
	signal write_addr_int : unsigned(C_M_AXI_ADDR_WIDTH-1 downto 0);
	signal write_data_int : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal write_ena_int : std_logic;

	signal pipelinedelay : std_logic_vector(3 downto 0);
	signal dstoffset : unsigned(23 downto 0);


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
	
	-- RAM1 signals
	signal ram1_addr : ram_addr_type;
	signal ram1_rd_data : ram_word_type;
	signal ram1_wr_data : ram_word_type;
	signal ram1_wr : std_logic;

	signal firstrowhandled : std_logic;
	signal readrowodd : std_logic;

	signal pix1r : unsigned(11 downto 0);
	signal pix1g : unsigned(11 downto 0);
	signal pix1b : unsigned(11 downto 0);

	signal pix2r : unsigned(11 downto 0);
	signal pix2g : unsigned(11 downto 0);
	signal pix2b : unsigned(11 downto 0);

	signal pix3r : unsigned(11 downto 0);
	signal pix3g : unsigned(11 downto 0);
	signal pix3b : unsigned(11 downto 0);

	signal pix4r : unsigned(11 downto 0);
	signal pix4g : unsigned(11 downto 0);
	signal pix4b : unsigned(11 downto 0);

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

	

begin

	------------------------------------------
	-- rowdelayram1
	------------------------------------------
	rowdelayram1 : rowdelayram port map(

		-- Clock and reset
		clk => clk,
	
		-- RAM signals
		wr => read_done_a,
		addr => std_logic_vector(ram1_addr),
		wr_data => ram1_wr_data,
		rd_data => ram1_rd_data
	);
	
	ram1_wr_data <= read_data(59 downto 48) & read_data(43 downto 32) & read_data(27 downto 16) & read_data(11 downto 0);
	ram1_wr <= read_done_a;
	src1A <= unsigned(ram1_rd_data);

	------------------------------------------
	-- rowdelayram1
	------------------------------------------
	cfarows2rgb1 : cfarows2rgb port map(
	
		-- Clock and reset
		clk => clk,
		resetn => resetn,

		-- Input data signals
		readrowodd => readrowodd,
		ram1_rd_data => ram1_rd_data,
		read_data => read_data,

		-- Output data signals
		pix1r => pix1r,
		pix1g => pix1g,
		pix1b => pix1b,

		pix2r => pix2r,
		pix2g => pix2g,
		pix2b => pix2b,

		pix3r => pix3r,
		pix3g => pix3g,
		pix3b => pix3b,

		pix4r => pix4r,
		pix4g => pix4g,
		pix4b => pix4b
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

			-- Direct read
			src2A <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			src3A <= to_unsigned(0, C_M_AXI_DATA_WIDTH);

			-- Delayed signals
			src1B <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			src2B <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			src3B <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			
			-- Computations
			result1 <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			result2 <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			result3 <= to_unsigned(0, C_M_AXI_DATA_WIDTH);

			pipelinedelay <= (others => '0');
			dstoffset <= to_unsigned(0, 24);

			-- Writing channel signals
			write_addr_int <= to_unsigned(0, C_M_AXI_ADDR_WIDTH);
			write_data_int <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			write_ena_int <= '0';

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

		else

			if (clk'event and clk='1') then

				ram1_addr <= ram1_addr;

				-- Direct read
				src2A <= src2A;
				src3A <= src3A;

				-- Delayed signals
				src1B <= src1B;
				src2B <= src2B;
				src3B <= src3B;

				-- Computations
				result1 <= src1A + src1B;
				result2 <= src2A + src2B;
				result3 <= src3A + src3B;

				-- Destination data to DDR memory
				write_addr_int <= write_addr_int;
				write_data_int <= result1 + result2 + result3;
				write_ena_int <= '0';

				pipelinedelay <= pipelinedelay(pipelinedelay'length-2 downto 0) & pipelinedelay(pipelinedelay'length-1);
				dstoffset <= dstoffset;

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

				-- Capture image read data 
				if (read_done_a='1' or read_done_b='1' or read_done_c='1') then

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

				-- Capture image 1
				-- Image 1 pixel data for four pixels in 36-bit RGB format
				if (read_done_a='1') then
					read_done_img1_delayed <= '1';
				else
				end if;

				if (read_done_img1_delayed='1') then

					img1pix1r <= pix1r;
					img1pix1g <= pix1g;
					img1pix1b <= pix1b;
					img1pix2r <= pix2r;
					img1pix2g <= pix2g;
					img1pix2b <= pix2b;
					img1pix3r <= pix3r;
					img1pix3g <= pix3g;
					img1pix3b <= pix3b;
					img1pix4r <= pix4r;
					img1pix4g <= pix4g;
					img1pix4b <= pix4b;

				else
				end if;

				-- Capture image 2
				-- Image 2 pixel data for four pixels in 36-bit RGB format
				if (read_done_b='1') then
					read_done_img2_delayed <= '1';
				else
				end if;

				if (read_done_img2_delayed='1') then

					img2pix1r <= pix1r;
					img2pix1g <= pix1g;
					img2pix1b <= pix1b;
					img2pix2r <= pix2r;
					img2pix2g <= pix2g;
					img2pix2b <= pix2b;
					img2pix3r <= pix3r;
					img2pix3g <= pix3g;
					img2pix3b <= pix3b;
					img2pix4r <= pix4r;
					img2pix4g <= pix4g;
					img2pix4b <= pix4b;

				else
				end if;
				

				if (read_done_c='1') then
					src3A <= unsigned(read_data);
				else
				end if;

				-- Trigger writing after pipeline delay
				-- pipelinedelay <= pipelinedelay(pipelinedelay'length-2 downto 0) & '1';

				--------------------------------------
				-- Wait for pipeline data to become available
				--------------------------------------
				if (pipelinedelay(pipelinedelay'length-1)='1') then

					-- Wait for write interface to be available
					if (write_ready='1') then

						-- This signaling can be reworked later
						pipelinedelay <= (others => '0');

						-- Set address and request write
						write_addr_int <= to_unsigned(1051982592, C_M_AXI_ADDR_WIDTH) + dstoffset; --X"3EB3FB00"
						write_ena_int <= '1';

						-- Calculate offset for next write address
						dstoffset <= dstoffset + to_unsigned(8, 4);

						-- Detect when all data has been written
						if (dstoffset=to_unsigned(10059552, 24)) then  --X"997F20"
							dstoffset <= to_unsigned(0, 24);
						else
						end if;

					else

						-- This is fatal error, if pipeline data has arrived
						-- but writing is not available.
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

	-- Write channel signals
	write_addr <= std_logic_vector(write_addr_int);
	write_data <= std_logic_vector(write_data_int);
	write_ena <= write_ena_int;
	
end architecture;
