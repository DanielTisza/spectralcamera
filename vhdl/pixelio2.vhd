-----------------------------------------------------------
-- pixelio2.vhd
--
-- Pixel IO for AXI 3
--
-- Copyright: Daniel Tisza, 2022, GPLv3 or later
--
-- ghdl -a pixelio2.vhd
-- ghdl -e pixelio2
-- ghdl -r pixelio2
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
		C_M_AXI_DATA_WIDTH	: integer	:= 64
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

		-- AXI master read address
		AXI_ARADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		AXI_ARVALID	: out std_logic;
		AXI_ARREADY	: in std_logic;
		AXI_ARID	: out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
		AXI_ARLOCK	: out std_logic_vector(1 downto 0);
		AXI_ARCACHE	: out std_logic_vector(3 downto 0);
		AXI_ARPROT	: out std_logic_vector(2 downto 0);
		AXI_ARLEN	: out std_logic_vector(3 downto 0);
		AXI_ARSIZE	: out std_logic_vector(2 downto 0);
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
		AXI_AWREADY	: in std_logic;
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

end pixelio2;

-- Describe the contents of this "chip"
architecture rtl of pixelio2 is

	signal AXI_ARVALID_int : std_logic;
	signal AXI_ARADDR_int : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);

	signal AXI_AWVALID_int : std_logic;
	signal AXI_AWADDR_int : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);

	signal AXI_WVALID_int : std_logic;
	signal AXI_WDATA_int : std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);

begin
	
	
	io_proc : process(
		AXI_ARESETN,
		AXI_ACLK
	)
	begin

		if (AXI_ARESETN='0') then

			AXI_ARVALID_int <= '0';
			AXI_ARADDR_int <= (others => '0');

			AXI_AWVALID_int <= '0';
			AXI_AWADDR_int <= (others => '0');

			AXI_WVALID_int <= '0';			
			AXI_WDATA_int <= (others => '0');

		else

			if (AXI_ACLK'event and AXI_ACLK='1') then

				AXI_ARVALID_int <= AXI_ARVALID_int;
				AXI_ARADDR_int <= AXI_ARADDR_int;

				AXI_AWVALID_int <= AXI_AWVALID_int;
				AXI_AWADDR_int <= AXI_AWADDR_int;
				
				AXI_WVALID_int <= AXI_WVALID_int;
				AXI_WDATA_int <= AXI_WDATA_int;

			else		
			end if;
			
		end if;

	end process;

	-- Connect internal signals to interface signals

	AXI_ARVALID <= AXI_ARVALID_int;
	AXI_ARADDR <= AXI_ARADDR_int;

	AXI_AWVALID <= AXI_AWVALID_int;
	AXI_AWADDR <= AXI_AWADDR_int;

	AXI_WVALID <= AXI_WVALID_int;
	AXI_WDATA <= AXI_WDATA_int;

	
end architecture;
