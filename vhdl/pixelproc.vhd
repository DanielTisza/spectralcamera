-----------------------------------------------------------
-- pixelproc.vhd
--
-- Pixel processor from RAM
--
-- Copyright: Daniel Tisza, 2022, GPLv3 or later
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Describe the I/O of this "chip"
entity pixelproc is

	port (
		addrb : out std_logic_vector(31 downto 0);
		clkb : in std_logic;
		doutb : out std_logic_vector(511 downto 0);	
		dinb : in std_logic_vector(511 downto 0);
		enb : out std_logic;
		rstbn : in std_logic;
		rstb : out std_logic;
		web : out std_logic_vector(63 downto 0)
	);

end pixelproc;

-- Describe the contents of this "chip"
architecture rtl of pixelproc is

	-- RAM definitions
	-- subtype bram_addr_type is std_logic_vector(31 downto 0);
	-- subtype bram_word_type is std_logic_vector(31 downto 0);
				
	signal doutb_int : std_logic_vector(511 downto 0);	
	
	-- Internal variables
	subtype ram_addr_type is unsigned(31 downto 0);
	
	signal ram_addr : ram_addr_type;
	signal ram_rd_addr : ram_addr_type;
	
	signal dinb_rdaddr_0 : std_logic_vector(31 downto 0);
	signal dinb_rdaddr_1 : std_logic_vector(31 downto 0);

begin
	
	------------------------------------------
	-- Use RAM
	------------------------------------------
	rw_proc : process(
		rstbn,clkb,dinb,doutb_int,
		ram_addr,ram_rd_addr,
		dinb_rdaddr_0,dinb_rdaddr_1
	)
	begin
	
		-- Connect to outputs
		addrb <= std_logic_vector(ram_addr);
		doutb <= doutb_int;	
		
		if (rstbn='0') then
		
			ram_addr <= to_unsigned(0,32);
			ram_rd_addr <= to_unsigned(0,32);
			doutb_int <= X"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
			enb <= '0';
			web <= X"0000000000000000";
			rstb <=	'1';
			
			dinb_rdaddr_0 <= X"00000000";
			dinb_rdaddr_1 <= X"00000000";
		
		else
		
			if (clkb'event and clkb='1') then
			
				-- Default actions				
				-- doutb_int <= doutb_int;
				-- web <= X"0";
				enb <= '1';
				rstb <=	'0';
				
				dinb_rdaddr_0 <= dinb_rdaddr_0;
				dinb_rdaddr_1 <= dinb_rdaddr_1;
								
				-- Increment address by 4
				-- ram_addr <= ram_addr + to_unsigned(4,32);
				
				ram_addr <= to_unsigned(0,32);

				-- Delay read address by one clock cycle
				ram_rd_addr <= ram_addr;
				
				web <= X"FFFFFFFFFFFFFFFF";
				-- doutb_int <= X"1234ABCD";
				-- doutb_int <= X"1234ABCD000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
				doutb_int <=    X"1234ABCD111111112222222233333333444444445555555566666666777777778888888899999999AAAAAAAABBBBBBBBCCCCCCCCDDDDDDDDEEEEEEEEFFFFFFFF";


				-- -- Wrap to beginning (0x8000 - 4) = 0x7FFC = 32764
				-- if (ram_addr=to_unsigned(32764,32)) then
					-- ram_addr <= to_unsigned(0,32);
				-- else
				-- end if;
				
				-- -- Read from address 0 and save value 
				-- if (ram_rd_addr=to_unsigned(0,32)) then
					-- dinb_rdaddr_0 <= dinb;
				-- else
				-- end if;
				
				-- -- Read from address 4 and save value
				-- if (ram_rd_addr=to_unsigned(4,32)) then
					-- dinb_rdaddr_1 <= dinb;
				-- else
				-- end if;
				
				
				-- -- Write to address 8
				-- if (ram_addr=to_unsigned(8,32)) then
					-- web <= X"F";
					-- doutb_int <= dinb_rdaddr_0 and dinb_rdaddr_1;
				-- else
				-- end if;
				
				-- -- Write to address 12 (0xC) a constant value
				-- if (ram_addr=to_unsigned(12,32)) then
					-- web <= X"F";
					-- doutb_int <= X"1234ABCD";
				-- else
				-- end if;
				
				
				-- -- Write to address 16 (0x10)
				-- if (ram_addr=to_unsigned(16,32)) then
					-- web <= X"F";
					-- doutb_int <= std_logic_vector( unsigned(dinb_rdaddr_0) + unsigned(dinb_rdaddr_0) );
				-- else
				-- end if;
				
				-- -- Write to address 20 (0x14)
				-- if (ram_addr=to_unsigned(20,32)) then
					-- web <= X"F";
					-- doutb_int <= std_logic_vector( unsigned(dinb_rdaddr_0) + unsigned(dinb_rdaddr_1) );
				-- else
				-- end if;
				
				-- -- Write to address 24 (0x18)
				-- if (ram_addr=to_unsigned(24,32)) then
					-- web <= X"F";
					-- doutb_int <= std_logic_vector( unsigned(dinb_rdaddr_0) + unsigned(dinb_rdaddr_1) );
				-- else
				-- end if;
			
			else
			end if;
			
		end if;
	end process;
	
	
end architecture;
