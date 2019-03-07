library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--use IEEE.fixed_pkg.all;
use work.types.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;

entity one_filter is
	port (
		clock : in std_logic;
		reset : in std_logic;
		
		b0_in : in to_coeff; 
		b1_in : in to_coeff; 
		b2_in : in to_coeff; 
		a1_in : in to_coeff; 
		a2_in : in to_coeff;
		
		
		x : in  std_logic_vector(FEED_SIZE - 1 downto 0);
		--y : out std_logic_vector(ADD_SIZE - 1 downto 0);
		
		y_resized : out sfixed(FEED_SIZE - 1 downto 0);
		
		ch_in         : in address;
		ch_delayed_in : in address;
		
		ch_delayed_out : out address;
		ch_out         : out address
	);
end entity one_filter;

architecture structure of one_filter is
	signal internal                               : address;
	signal b0_out, b1_out, b2_out, a1_out, a2_out : from_coeff; -- data out
	signal x1_out, x2_out, y1_out, y2_out         : from_feed;
	signal y : std_logic_vector(ADD_SIZE - 1 downto 0);
	signal y_fixed : sfixed(26 downto -15);
	
begin
	ch_delayed_out <= internal;
	
	ram_control : entity work.ram_control
		generic map (
			address => ADDR_SIZE
		)
		port map (
			clock   => clock, 
			addr_in => ch_in.address,
			en_in   => ch_in.en,
			
			addr_out_x => internal.address,
			en_out_x   => internal.en,
			
			addr_out => ch_out.address,
			en_out   => ch_out.en
		);
	
	bram_block : entity work.bram_block
		generic map (
			address => ADDR_SIZE
		)
		port map (
			clock => clock,
			
			b0_in  => b0_in,
			b0_out => b0_out,
			
			b1_in  => b1_in,
			b1_out => b1_out,
			
			b2_in  => b2_in,
			b2_out => b2_out,
			
			a1_in  => a1_in,
			a1_out => a1_out,
			
			a2_in  => a2_in,
			a2_out => a2_out, 
			
			x1_out => x1_out,
			x2_out => x2_out,
			y1_out => y1_out,
			y2_out => y2_out,
			
			x_in => x,
			y_in => to_slv(y_resized),
			
			read_addr_in => ch_in.address,
			read_en_in   => ch_in.en,
			
			write_addr_in => internal.address,
			write_en      => internal.en,
			
			write_addr_in_del => ch_delayed_in.address,
			write_en_del      => ch_delayed_in.en
			
		);
	
	filter : entity work.filter
		port map (
			b0 => b0_out.dob,
			b1 => b1_out.dob,
			b2 => b2_out.dob,
			a1 => a1_out.dob,
			a2 => a2_out.dob,
			
			Xn  => x,
			Xn1 => x1_out.dob,
			Xn2 => x2_out.dob,
			Yn1 => y1_out.dob,
			Yn2 => y2_out.dob,
			
			Yn => y,
			
			clock => clock,
			reset => reset
		);
	
	process(all) is
	begin
		if rising_edge(clock) then
			y_resized <= resize(arg => to_sfixed(y,y_fixed),size_res => y_resized, overflow_style => fixed_saturate, round_style => fixed_truncate);
		end if;
	end process; -- resize
	
end architecture structure;