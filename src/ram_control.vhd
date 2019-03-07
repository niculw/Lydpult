library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all; 
use work.types.all;

entity ram_control is
	generic (
		address : integer := ADDR_SIZE
	);
	port (
		clock : in std_logic; 
		
		addr_in : in std_logic_vector(address-1 downto 0); 
		en_in   : in std_logic; 
		
		addr_out_x : out std_logic_vector(address-1 downto 0); 
		en_out_x   : out std_logic; 
		
		addr_out : out std_logic_vector(address-1 downto 0); 
		en_out   : out std_logic
	); 
end entity ram_control; 

architecture rtl of ram_control is
	-- addr delays
	type addr_delay is array (integer range 0 to 8) of std_logic_vector(address-1 downto 0); 
	type en_delay is array (integer range 0 to 8) of std_logic; 
	signal addr_delay_s : addr_delay; 
	signal en_delay_s   : en_delay; 
	
begin
	addr_out_x <= addr_delay_s(0); 
	en_out_x   <= en_delay_s(0); 
	
	addr_out <= addr_delay_s(8); 
	en_out   <= en_delay_s(8); 
	
	process(all) is
	begin
		if rising_edge(clock) then
			for i in 8 downto 0 loop
					if (i = 0) then
						addr_delay_s(i) <= addr_in; 
						en_delay_s(i)   <= en_in; 
					else
						addr_delay_s(i) <= addr_delay_s(i-1); 
						en_delay_s(i)   <= en_delay_s(i-1); 
					end if; 
			end loop; 
		end if; 
	end process; 
	
end architecture rtl;