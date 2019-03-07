library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package types is
	constant ADDR_SIZE : integer := 9;
	constant FEED_SIZE : integer := 24;
	constant COEFF_SIZE : integer := 18;
	constant ADD_SIZE : integer := 42; 
	

	type address is record
		address : std_logic_vector(ADDR_SIZE - 1 downto 0);
		en : std_logic;
	end record;

	type to_coeff is record
		--port a
		ena   : std_logic;
		wea   : std_logic;
		addra : std_logic_vector(ADDR_SIZE - 1 downto 0);
		dia   : std_logic_vector(COEFF_SIZE - 1 downto 0);
		--port b
		enb   : std_logic;
		web   : std_logic;
		addrb : std_logic_vector(ADDR_SIZE - 1 downto 0);
		dib   : std_logic_vector(COEFF_SIZE - 1 downto 0); 
	end record;
	
	type from_coeff is record
		--port a
		doa : std_logic_vector(COEFF_SIZE - 1 downto 0);
		--port b
		dob : std_logic_vector(COEFF_SIZE - 1 downto 0); 
	end record;
	
	type coeff is record
		to_block   : to_coeff;
		from_block : from_coeff;
	end record;

	type to_feed is record
		--port a
		ena   : std_logic;
		wea   : std_logic;
		addra : std_logic_vector(ADDR_SIZE - 1 downto 0);
		dia   : std_logic_vector(FEED_SIZE - 1 downto 0);
		--port b
		enb   : std_logic;
		web   : std_logic;
		addrb : std_logic_vector(ADDR_SIZE - 1 downto 0);
		dib   : std_logic_vector(FEED_SIZE - 1 downto 0); 
	end record;
	
	type from_feed is record
		--port a
		doa : std_logic_vector(FEED_SIZE - 1 downto 0);
		--port b
		dob : std_logic_vector(FEED_SIZE - 1 downto 0); 
	end record;
	
	type feed is record
		to_block   : to_feed;
		from_block : from_feed;
	end record;
	
	
end package types;

package body types is
	
end package body types;