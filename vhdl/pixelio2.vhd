-----------------------------------------------------------
-- pixelio2.vhd
--
-- Pixel IO for AXI 3
--
-- Copyright: Daniel Tisza, 2022, GPLv3 or later
--
-- ghdl -a -v pixelio2.vhd
-- ghdl -e -v pixelio2
-- ghdl -r pixelio2 --vcd=out.vcd
-- gtkwave
--
-- AMBA AXI and ACE Protocol Specification Version E
-- https://developer.arm.com/documentation/ihi0022/e/AMBA-AXI3-and-AXI4-Protocol-Specification
--
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Describe the I/O of this "chip"
entity pixelio2 is

	generic(
		C_M_AXI_ADDR_WIDTH	: integer	:= 32;
		C_M_AXI_ID_WIDTH	: integer	:= 6;
		C_M_AXI_DATA_WIDTH	: integer	:= 64;
		ARSIZE_AWSIZE_WIDTH : integer	:= 3;
		ARSIZE_AWSIZE_VALUE : integer	:= 3
	);

	port (
		
		----------------------------------------
		-- 5.6. PS-PL AXI interface signals
		-- page 139
		-- Zynq 7000 Technical reference manual
		----------------------------------------

		-- Clock and reset
		AXI_ACLK	: in std_logic;
		AXI_ARESETN	: in std_logic;

		-- AXI master read address channel "AR"
		AXI_ARADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		AXI_ARVALID	: out std_logic;
		AXI_ARREADY	: in std_logic;
		AXI_ARID	: out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
		AXI_ARLOCK	: out std_logic_vector(1 downto 0);
		AXI_ARCACHE	: out std_logic_vector(3 downto 0);
		AXI_ARPROT	: out std_logic_vector(2 downto 0);
		AXI_ARLEN	: out std_logic_vector(3 downto 0);
		AXI_ARSIZE	: out std_logic_vector(ARSIZE_AWSIZE_WIDTH-1 downto 0);
		AXI_ARBURST	: out std_logic_vector(1 downto 0);
		AXI_ARQOS	: out std_logic_vector(3 downto 0);

		-- AXI master read channel "R"
		AXI_RDATA	: in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
		AXI_RVALID	: in std_logic;
		AXI_RREADY	: out std_logic;
		AXI_RID	: in std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
		AXI_RLAST	: in std_logic;
		AXI_RRESP	: in std_logic_vector(1 downto 0);
		AXI_RCOUNT	: in std_logic_vector(7 downto 0);
		AXI_RACOUNT	: in std_logic_vector(2 downto 0);
		AXI_RDISSUECAP1EN : out std_logic;

		-- AXI master write address channel "AW"
		AXI_AWADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		AXI_AWVALID	: out std_logic;
		AXI_AWREADY	: in std_logic;
		AXI_AWID	: out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
		AXI_AWLOCK	: out std_logic;
		AXI_AWCACHE	: out std_logic_vector(3 downto 0);
		AXI_AWPROT	: out std_logic_vector(2 downto 0);
		AXI_AWLEN	: out std_logic_vector(3 downto 0);
		AXI_AWSIZE	: out std_logic_vector(ARSIZE_AWSIZE_WIDTH-1 downto 0);
		AXI_AWBURST	: out std_logic_vector(1 downto 0);
		AXI_AWQOS	: out std_logic_vector(3 downto 0);

		-- AXI master write data channel "W"
		AXI_WDATA	: out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
		AXI_WVALID	: out std_logic;
		AXI_WREADY	: in std_logic;
		AXI_WID	: out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
		AXI_WLAST	: out std_logic;
		AXI_WSTRB	: out std_logic_vector(7 downto 0);
		AXI_WCOUNT	: in std_logic_vector(7 downto 0);
		AXI_WACOUNT	: in std_logic_vector(5 downto 0);
		AXI_WRISSUECAP1EN : out std_logic;

		-- AXI master write response channel "B"
		AXI_BVALID	: in std_logic;
		AXI_BREADY	: out std_logic;
		AXI_BID	: in std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
		AXI_BRESP	: in std_logic_vector(1 downto 0);

		-- Read channel signals
		read_req : in std_logic;
		read_req_addr : in std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		read_done : out std_logic;
		read_data : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);

		-- Write channel signals
		write_ready : out std_logic;
		write_ena : in std_logic;
		write_addr : in std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		write_data : in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0)
	);

end pixelio2;

-- Describe the contents of this "chip"
architecture rtl of pixelio2 is

	-- AXI master read address channel "AR"
	signal AXI_ARVALID_int : std_logic;
	signal AXI_ARADDR_int : unsigned(C_M_AXI_ADDR_WIDTH-1 downto 0);

	-- AXI master read channel "R"
	signal AXI_RDATA_int : std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal AXI_RREADY_int : std_logic;
	
	-- AXI master write address channel "AW"
	signal AXI_AWVALID_int : std_logic;
	signal AXI_AWADDR_int : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);

	-- AXI master write data channel "W"
	signal AXI_WVALID_int : std_logic;
	signal AXI_WDATA_int : std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal AXI_WSTRB_int : std_logic_vector(7 downto 0);
	signal AXI_WLAST_int : std_logic;

	-- AXI master write response channel "B"
	signal AXI_BREADY_int : std_logic;

	-- Read channel signals
	signal readstatebits : std_logic_vector(7 downto 0);
	signal read_done_int : std_logic;

	-- Write channel signals
	signal statebits : std_logic_vector(7 downto 0);
	signal write_ready_int : std_logic;

begin
	
	io_proc : process(
		AXI_ARESETN,
		AXI_ACLK,
		AXI_AWREADY,
		AXI_WREADY,
		AXI_BVALID
	)
	begin

		if (AXI_ARESETN='0') then

			-- AXI master read address channel "AR"
			AXI_ARVALID_int <= '0';
			AXI_ARADDR_int <= to_unsigned(0, C_M_AXI_ADDR_WIDTH);

			-- AXI master read channel "R"
			AXI_RDATA_int <= (others => '0');
			AXI_RREADY_int <= '0';

			-- AXI master write address channel "AW"
			AXI_AWVALID_int <= '0';
			AXI_AWADDR_int <= (others => '0');

			-- AXI master write data channel "W"
			AXI_WVALID_int <= '0';			
			AXI_WDATA_int <= (others => '0');
			AXI_WSTRB_int <= (others => '0');
			AXI_WLAST_int <= '0';

			-- AXI master write response channel "B"
			AXI_BREADY_int <= '0';
			
			-- Read channel signals
			readstatebits <= "00000001";
			read_done_int <= '0';

			-- Write channel signals
			statebits <= "00000001";
			write_ready_int <= '0';

		else

			if (AXI_ACLK'event and AXI_ACLK='1') then

				-- AXI master read address channel "AR"
				AXI_ARVALID_int <= AXI_ARVALID_int;
				AXI_ARADDR_int <= AXI_ARADDR_int;

				-- AXI master read channel "R"
				AXI_RDATA_int <= AXI_RDATA_int;
				AXI_RREADY_int <= AXI_RREADY_int;

				-- AXI master write address channel "AW"
				AXI_AWVALID_int <= AXI_AWVALID_int;
				AXI_AWADDR_int <= AXI_AWADDR_int;
				
				-- AXI master write data channel "W"
				AXI_WVALID_int <= AXI_WVALID_int;
				AXI_WDATA_int <= AXI_WDATA_int;
				AXI_WSTRB_int <= AXI_WSTRB_int;
				AXI_WLAST_int <= AXI_WLAST_int;

				-- AXI master write response channel "B"
				AXI_BREADY_int <= AXI_BREADY_int;

				-- Read channel signals
				readstatebits <= readstatebits;
				read_done_int <= '0';

				-- Write channel signals
				statebits <= statebits;
				write_ready_int <= write_ready_int;
				
				--------------------------------------
				-- Read from DDR memory
				-- 0x3C000008, 64-bits (8 bytes)
				--------------------------------------
				case readstatebits is

					when "00000001" =>

						-- Initial state
						-- Indicate not ready to read address channel
						-- Indicate not ready to read data channel

						AXI_ARVALID_int <= '0';
						AXI_RREADY_int <= '0';
						readstatebits <= "00000010";

					when "00000010" =>

						-- Waiting for indication that read address has been set
						-- and we can start reading
						-- Indicate ready to read address channel

						if (read_req='1') then
							AXI_ARADDR_int <= unsigned(read_req_addr);
							AXI_ARVALID_int <= '1';
							readstatebits <= "00000100";
						else
						end if;

					when "00000100" =>

						-- Waiting for indication that read address channel
						-- has accepted read address

						-- Indicate to read data channel that we are ready to 
						-- accept read data

						if (AXI_ARREADY='1') then
							AXI_ARVALID_int <= '0';
							AXI_RREADY_int <= '1';
							readstatebits <= "00001000";

						else
						end if;

					when "00001000" =>

						-- Waiting for indication from read data channel
						-- that read data is valid and it is the last read data
						-- in a read burst

						-- Indicate that the read has completed

						if (AXI_RVALID='1' and AXI_RLAST='1') then

							AXI_RDATA_int <= AXI_RDATA;
							read_done_int <= '1';
							readstatebits <= "00000001";

						else
						end if;

					when others =>
						null;

				end case;
				

				--------------------------------------
				-- Write to DDR memory
				--------------------------------------

				-- This can probably be removed and value assigned directly
				-- to corresponding output signal
				AXI_WSTRB_int <= X"FF";

				case statebits is

					when "00000001" =>

						-- Waiting for write request
						-- Indicate to write address channel that 
						-- write address is valid
						
						write_ready_int <= '1';

						if (write_ena='1') then

							AXI_AWADDR_int <= write_addr;
							AXI_WDATA_int <= write_data;
							AXI_AWVALID_int <= '1';
							statebits <= "00000010";
							write_ready_int <= '0';
						else	
						end if;

					when "00000010" =>

						-- Waiting for write address channel to indicate that
						-- write address was accepted

						-- Indicate to write data channel that write data
						-- is valid and this is last write data in the
						-- write burst

						if (AXI_AWREADY='1') then

							AXI_AWVALID_int <= '0';
							AXI_WVALID_int <= '1';
							AXI_WLAST_int <= '1';
							statebits <= "00000100";
						else
						end if;


					when "00000100" =>

						-- Waiting for write data channel to indicate that 
						-- write data was accepted
						
						-- Turn off indications for write data channel that
						-- write data valid and last write data in write burst

						if (AXI_WREADY='1') then

							AXI_WVALID_int <= '0';
							AXI_WLAST_int <= '0';
							statebits <= "00001000";
						else
						end if;

					when "00001000" =>

						-- Waiting for write response channel to indicate
						-- valid write response

						if (AXI_BVALID='1') then

							AXI_BREADY_int <= '1';
							statebits <= "00010000";
						else
						end if;

					when "00010000" =>

						AXI_BREADY_int <= '0';
						statebits <= "00000001";

					when others =>
						null;

				end case;


			else		
			end if;
			
		end if;

	end process;

	-- Default values

	AXI_AWBURST <= "01"; 	-- Zynq 7000 supports incrementing burst
	AXI_AWLEN <= X"0"; -- 1 transfer in the burst (1-16 data beats)
	AXI_AWSIZE <= std_logic_vector(to_unsigned(ARSIZE_AWSIZE_VALUE, ARSIZE_AWSIZE_WIDTH)); -- "11"; -- 8 octets/bytes per beat (would increment address by 8) (64 bits)

	AXI_ARBURST <= "01";	-- Zynq 7000 supports incrementing burst
	AXI_ARLEN <= X"0"; 		-- 1 transfer in the burst (1-16 data beats)
	AXI_ARSIZE <= std_logic_vector(to_unsigned(ARSIZE_AWSIZE_VALUE, ARSIZE_AWSIZE_WIDTH)); -- "11";	-- 8 octets/bytes per beat (would increment address by 8) (64 bits)


	-- Zynq TRM p. 299
	-- 10.2.3 AXI Feature Support and Limitations (DDRI)
	-- AWPROT/ARPROT[1] bit is used for trust zone support, AWPROT/ARPROT[0], and
	-- AWPROT/ARPROT[2] bits are ignored and do not have any effect.
	--
	-- Zynq UltraScale MPSoC Cache Coherency
	-- AxPROT[1] should be 1 for non-secure access for Linux
	-- AXI_AWPROT <= "010";
	AXI_AWPROT <= "000";

	AXI_ARPROT <= "000";

	-- Zynq TRM p. 299
	-- 10.2.3 AXI Feature Support and Limitations (DDRI)
	-- ARCACHE[3:0]/AWCACHE[3:0] (cache support) are ignored, and do not have any effect.
	AXI_ARCACHE <= (others => '0');
	AXI_AWCACHE <= (others => '0');

	AXI_AWID <= (others => '0');
	AXI_AWLOCK <= '0';
	AXI_AWQOS <= (others => '0');
	AXI_WID <= (others => '0');

	AXI_ARID <= (others => '0');
	AXI_ARLOCK <= (others => '0');
	AXI_ARQOS <= (others => '0');

	-- Connect internal signals to interface signals

	-- AXI read address
	AXI_ARVALID <= AXI_ARVALID_int;
	AXI_ARADDR <= std_logic_vector(AXI_ARADDR_int);

	-- AXI read
	AXI_RREADY <= AXI_RREADY_int;

	-- AXI write address
	AXI_AWVALID <= AXI_AWVALID_int;
	AXI_AWADDR <= AXI_AWADDR_int;

	-- AXI write
	AXI_WVALID <= AXI_WVALID_int;
	AXI_WDATA <= AXI_WDATA_int;
	AXI_WLAST <= AXI_WLAST_int;
	AXI_WSTRB <= AXI_WSTRB_int;

	-- AXI write result
	AXI_BREADY <= AXI_BREADY_int;

	-- Other signals
	read_done <= read_done_int;
	read_data <= AXI_RDATA_int;
	write_ready <= write_ready_int;
	
end architecture;
