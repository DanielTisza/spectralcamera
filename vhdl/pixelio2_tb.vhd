-----------------------------------------------------------
-- pixelio2.vhd
--
-- Pixel IO for AXI 3
--
-- Copyright: Daniel Tisza, 2022, GPLv3 or later
--
-- ghdl -a -v pixelio2_tb.vhd
-- ghdl -e -v pixelio2_tb
-- ghdl -r pixelio2_tb --vcd=out.vcd
-- gtkwave
--
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Describe the I/O of this "chip"
entity pixelio2_tb is

	generic(
		C_M_AXI_ADDR_WIDTH	: integer	:= 32;
		C_M_AXI_ID_WIDTH	: integer	:= 6;
		C_M_AXI_DATA_WIDTH	: integer	:= 64
	);

	port (
		
		----------------------------------------
		-- 5.6. PS-PL AXI interface signals
		-- page 139
		-- Zynq 7000 Technical reference manual
		----------------------------------------

		-- Clock and reset

		-- AXI_ACLK	: in std_logic;
		-- AXI_ARESETN	: in std_logic;

		-- AXI master read address
		AXI_ARADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		AXI_ARVALID	: out std_logic;
		-- AXI_ARREADY	: in std_logic;
		AXI_ARID	: out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
		AXI_ARLOCK	: out std_logic_vector(1 downto 0);
		AXI_ARCACHE	: out std_logic_vector(3 downto 0);
		AXI_ARPROT	: out std_logic_vector(2 downto 0);
		AXI_ARLEN	: out std_logic_vector(3 downto 0);
		AXI_ARSIZE	: out std_logic_vector(1 downto 0);
		AXI_ARBURST	: out std_logic_vector(1 downto 0);
		AXI_ARQOS	: out std_logic_vector(3 downto 0);

		-- AXI master read
		AXI_RDATA	: in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
		AXI_RVALID	: in std_logic;
		AXI_RREADY	: out std_logic;
		AXI_RID	: in std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
		AXI_RLAST	: in std_logic;
		AXI_RRESP	: in std_logic_vector(1 downto 0);
		AXI_RCOUNT	: in std_logic_vector(7 downto 0);
		AXI_RACOUNT	: in std_logic_vector(2 downto 0);
		AXI_RDISSUECAP1EN : out std_logic;

		-- AXI master write address
		AXI_AWADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		AXI_AWVALID	: out std_logic;
		-- AXI_AWREADY	: in std_logic;
		AXI_AWID	: out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
		AXI_AWLOCK	: out std_logic;
		AXI_AWCACHE	: out std_logic_vector(3 downto 0);
		AXI_AWPROT	: out std_logic_vector(2 downto 0);
		AXI_AWLEN	: out std_logic_vector(3 downto 0);
		AXI_AWSIZE	: out std_logic_vector(1 downto 0);
		AXI_AWBURST	: out std_logic_vector(1 downto 0);
		AXI_AWQOS	: out std_logic_vector(3 downto 0);

		-- AXI master write
		AXI_WDATA	: out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
		AXI_WVALID	: out std_logic;
		AXI_WREADY	: in std_logic;
		AXI_WID	: out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
		AXI_WLAST	: out std_logic;
		AXI_WSTRB	: out std_logic_vector(7 downto 0);
		AXI_WCOUNT	: in std_logic_vector(7 downto 0);
		AXI_WACOUNT	: in std_logic_vector(5 downto 0);
		AXI_WRISSUECAP1EN : out std_logic;

		-- AXI master write response
		AXI_BVALID	: in std_logic;
		AXI_BREADY	: out std_logic;
		AXI_BID	: in std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
		AXI_BRESP	: in std_logic_vector(1 downto 0)
	);

end pixelio2_tb;

-- Describe the contents of this "chip"
architecture rtl of pixelio2_tb is

	signal AXI_ARVALID_int : std_logic;
	signal AXI_ARADDR_int : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);

	signal AXI_AWVALID_int : std_logic;
	signal AXI_AWADDR_int : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);

	signal AXI_WVALID_int : std_logic;
	signal AXI_WDATA_int : std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal AXI_WSTRB_int : std_logic_vector(7 downto 0);
	signal AXI_BREADY_int : std_logic;

	signal AXI_WLAST_int : std_logic;

	signal AXI_RDATA_int : std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal AXI_RREADY_int : std_logic;

	signal statebits : std_logic_vector(7 downto 0);
	signal readstatebits : std_logic_vector(7 downto 0);

	signal termA : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);
	signal result : unsigned(C_M_AXI_DATA_WIDTH-1 downto 0);

	-- Testbench signals
	signal AXI_ACLK	: std_logic;
	signal AXI_ARESETN : std_logic;
	signal AXI_AWREADY : std_logic;
	signal AXI_ARREADY : std_logic;

	signal finished : std_logic;
	signal clk : std_logic;
	signal reset : std_logic;
	signal tb_awready : std_logic;
	signal tb_arready : std_logic;

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

			-- AXI master read address
			AXI_ARVALID_int <= '0';
			AXI_ARADDR_int <= (others => '0');

			-- AXI master write address
			AXI_AWVALID_int <= '0';
			AXI_AWADDR_int <= (others => '0');

			-- AXI master write
			AXI_WVALID_int <= '0';			
			AXI_WDATA_int <= (others => '0');
			AXI_WSTRB_int <= (others => '0');
			AXI_WLAST_int <= '0';

			-- AXI master write response
			AXI_BREADY_int <= '0';

			AXI_RDATA_int <= (others => '0');
			AXI_RREADY_int <= '0';

			statebits <= "00000001";
			readstatebits <= "00000001";

			termA <= to_unsigned(0, C_M_AXI_DATA_WIDTH);
			result <= to_unsigned(0, C_M_AXI_DATA_WIDTH);

		else

			if (AXI_ACLK'event and AXI_ACLK='1') then

				-- AXI master read address
				AXI_ARVALID_int <= AXI_ARVALID_int;
				AXI_ARADDR_int <= AXI_ARADDR_int;

				-- AXI master read
				AXI_RDATA_int <= AXI_RDATA_int;
				AXI_RREADY_int <= AXI_RREADY_int;

				-- AXI master write address
				AXI_AWVALID_int <= AXI_AWVALID_int;
				AXI_AWADDR_int <= AXI_AWADDR_int;
				
				-- AXI master write
				AXI_WVALID_int <= AXI_WVALID_int;
				AXI_WDATA_int <= AXI_WDATA_int;
				AXI_WSTRB_int <= AXI_WSTRB_int;
				AXI_WLAST_int <= AXI_WLAST_int;

				-- AXI master write response
				AXI_BREADY_int <= AXI_BREADY_int;

				-- Computations
				termA <= unsigned(AXI_RDATA_int);
				result <= termA + termA;

				-- Read data A from 0x3C000000, 64-bits (8 bytes)
				-- Read data B from 0x3C000008, 64-bits (8 bytes)
				-- Perform operation on C = A + B

				--------------------------------------
				-- Read data B from 0x3C000008, 64-bits (8 bytes)
				--------------------------------------
				readstatebits <= readstatebits;

				if (readstatebits="00000001") then

					AXI_ARVALID_int <= '0';
					AXI_RREADY_int <= '0';
					readstatebits <= "00000010";

				elsif (readstatebits="00000010") then

					AXI_ARADDR_int <= X"3C000008";
					AXI_ARVALID_int <= '1';
					readstatebits <= "00000100";

				elsif (readstatebits="00000100") then			

					-- Wait for ready
					if (AXI_ARREADY='1') then
						AXI_ARVALID_int <= '0';
						AXI_RREADY_int <= '1';
						readstatebits <= "00001000";

					else
					end if;

				elsif (readstatebits="00001000") then	

					-- Receive read data
					if (AXI_RVALID='1') then
						AXI_RDATA_int <= AXI_RDATA;
					else
					end if;

					-- Received last read data
					if (AXI_RLAST='1') then
						readstatebits <= "00000001";
					else
					end if;

				end if;
				
				--------------------------------------
				-- Write result C to 0x3C000000
				--------------------------------------

				AXI_AWADDR_int <= X"3C000000";

				-- AXI_WDATA_int <= X"0123456789ABCDEF";
				AXI_WDATA_int <= std_logic_vector(result);

				AXI_WSTRB_int <= X"FF";

				statebits <= statebits;

				if (statebits="00000001") then

					AXI_AWVALID_int <= '1';
					statebits <= "00000010";

				elsif (statebits="00000010") then

					-- Wait for ready
					if (AXI_AWREADY='1') then
						AXI_AWVALID_int <= '0';
						AXI_WVALID_int <= '1';
						AXI_WLAST_int <= '1';
						statebits <= "00000100";

					else
					end if;


				elsif (statebits="00000100") then

					if (AXI_WREADY='1') then
						AXI_WVALID_int <= '0';
						AXI_WLAST_int <= '0';
						statebits <= "00001000";
					else
					end if;

				elsif (statebits="00001000") then

					if (AXI_BVALID='1') then
						AXI_BREADY_int <= '1';
						statebits <= "00010000";
					else
					end if;

				elsif (statebits="00010000") then

					AXI_BREADY_int <= '0';
					statebits <= "00000001";

				end if;

			else		
			end if;
			
		end if;

	end process;

	-- Default values
	
	AXI_AWBURST <= "01"; 	-- Zynq 7000 supports incrementing burst
	AXI_AWLEN <= X"0"; 		-- 1 transfer in the burst (1-16 data beats)
	AXI_AWSIZE <= "11"; -- 8 octets/bytes per beat (would increment address by 8) (64 bits)

	AXI_ARBURST <= "01";	-- Zynq 7000 supports incrementing burst
	AXI_ARLEN <= X"0"; 		-- 1 transfer in the burst (1-16 data beats)
	AXI_ARSIZE <= "11";	-- 8 octets/bytes per beat (would increment address by 8) (64 bits)


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
	AXI_ARADDR <= AXI_ARADDR_int;

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
	
	------------------------------------------------
	-- Test bench part
	------------------------------------------------

	AXI_ARESETN <= not(reset);
	AXI_ACLK <= clk;
	AXI_AWREADY <= tb_awready;
	AXI_ARREADY <= tb_arready;

	-- Generate reset pulse for global reset
	testbench_reset_proc : process
	begin
	
		reset <= '1';
		wait for 5 us;
		reset <= '0';
		wait;
	
	end process;

	-- Generate finished signal
	testbench_finish_proc : process
	begin
	
		-- Initial finished state
		finished <= '0';
		
		-- Set finished after a delay
		wait for 50 us;
		finished <= '1';
		
		-- Wait a while after finishing
		wait for 3 us;
		wait;
	
	end process;
	
	-- Generate clock signal
	testbench_clock_proc : process
	begin
	
		-- Initial clock signal state
		clk <= '0';
		
		clockloop : loop
		
			-- Clock ticks
			wait for 1 us;
			clk <= not(clk);
			
			-- Exit loop when finished
			if (finished='1') then
				exit;
			else
			end if;
		
		end loop clockloop;
		
		wait;
	
	end process;

	-- Generate finished signal
	testbench_awready_proc : process
	begin
	
		-- Initial axi_wready
		tb_awready <= '0';
		
		-- Set finished after a delay
		wait for 10 us;
		tb_awready <= '1';

		wait for 2 us;
		tb_awready <= '0';
		
		-- Wait a while after finishing
		wait;
	
	end process;

	-- Generate finished signal
--	testbench_wready_proc : process
--	begin
--	
--		-- Initial axi_wready
--		tb_wready <= '0';
--		
--		-- Set finished after a delay
--		wait for 10 us;
--		tb_wready <= '1';
--
--		wait for 2 us;
--		tb_wready <= '0';
--		
--		-- Wait a while after finishing
--		wait;
--	
--	end process;

	-- Generate finished signal
	testbench_arready_proc : process
	begin
	
		-- Initial axi_wready
		tb_arready <= '0';
		
		-- Set finished after a delay
		wait for 10 us;
		tb_arready <= '1';

		wait for 2 us;
		tb_arready <= '0';
		
		-- Wait a while after finishing
		wait;

	end process;
	
end architecture;
