library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--use IEEE.fixed_pkg.all;
use work.types.all;

Library UNISIM;
use UNISIM.vcomponents.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;

entity filter is
	port (
		b0 : in std_logic_vector(COEFF_SIZE - 1 downto 0);
		b1 : in std_logic_vector(COEFF_SIZE - 1 downto 0);
		b2 : in std_logic_vector(COEFF_SIZE - 1 downto 0);
		a1 : in std_logic_vector(COEFF_SIZE - 1 downto 0);
		a2 : in std_logic_vector(COEFF_SIZE - 1 downto 0);
		
		Xn  : in std_logic_vector(FEED_SIZE - 1 downto 0);
		Xn1 : in std_logic_vector(FEED_SIZE - 1 downto 0);
		Xn2 : in std_logic_vector(FEED_SIZE - 1 downto 0);
		Yn1 : in std_logic_vector(FEED_SIZE - 1 downto 0);
		Yn2 : in std_logic_vector(FEED_SIZE - 1 downto 0);
		
		Yn : out std_logic_vector(ADD_SIZE - 1 downto 0);
		
		clock : in std_logic;
		reset : in std_logic 
	);
end entity filter;

architecture struct of filter is
	
	signal result0, result1, result2, result2_delay0, result2_delay1, result3, result4 : std_logic_vector(ADD_SIZE - 1 downto 0);
	signal add0, add1, add1_delay0, add1_delay1, add2                                  : std_logic_vector(ADD_SIZE - 1 downto 0);
	
begin
	MULT_b0_xn : MULT_MACRO
		generic map (
			DEVICE  => "7SERIES", -- Target Device    :     "VIRTEX5", "7SERIES", "SPARTAN6" 
			LATENCY => 3, -- Desired clock cycle latency, 0-4
			WIDTH_A => FEED_SIZE, -- Multiplier A-input bus width, 1-25 
			WIDTH_B => COEFF_SIZE) -- Multiplier B-input bus width, 1-18
		port map (
			P   => result0, -- Multiplier ouput bus, width determined by WIDTH_P generic 
			A   => Xn, -- Multiplier input A bus, width determined by WIDTH_A generic 
			B   => b0, -- Multiplier input B bus, width determined by WIDTH_B generic 
			CE  => '1', -- 1-bit active high input clock enable
			CLK => clock, -- 1-bit positive edge clock input
			RST => reset -- 1-bit input active high reset
		);
	
	MULT_b1_xn1 : MULT_MACRO
		generic map (
			DEVICE  => "7SERIES", -- Target Device    :     "VIRTEX5", "7SERIES", "SPARTAN6" 
			LATENCY => 3, -- Desired clock cycle latency, 0-4
			WIDTH_A => FEED_SIZE, -- Multiplier A-input bus width, 1-25 
			WIDTH_B => COEFF_SIZE) -- Multiplier B-input bus width, 1-18
		port map (
			P   => result1, -- Multiplier ouput bus, width determined by WIDTH_P generic 
			A   => Xn1, -- Multiplier input A bus, width determined by WIDTH_A generic 
			B   => b1, -- Multiplier input B bus, width determined by WIDTH_B generic 
			CE  => '1', -- 1-bit active high input clock enable
			CLK => clock, -- 1-bit positive edge clock input
			RST => reset -- 1-bit input active high reset
		);
	
	MULT_b2_xn2 : MULT_MACRO
		generic map (
			DEVICE  => "7SERIES", -- Target Device    :     "VIRTEX5", "7SERIES", "SPARTAN6" 
			LATENCY => 3, -- Desired clock cycle latency, 0-4
			WIDTH_A => FEED_SIZE, -- Multiplier A-input bus width, 1-25 
			WIDTH_B => COEFF_SIZE) -- Multiplier B-input bus width, 1-18
		port map (
			P   => result2, -- Multiplier ouput bus, width determined by WIDTH_P generic 
			A   => Xn2, -- Multiplier input A bus, width determined by WIDTH_A generic 
			B   => b2, -- Multiplier input B bus, width determined by WIDTH_B generic 
			CE  => '1', -- 1-bit active high input clock enable
			CLK => clock, -- 1-bit positive edge clock input
			RST => reset -- 1-bit input active high reset
		);
	
	MULT_a1_yn1 : MULT_MACRO
		generic map (
			DEVICE  => "7SERIES", -- Target Device    :     "VIRTEX5", "7SERIES", "SPARTAN6" 
			LATENCY => 3, -- Desired clock cycle latency, 0-4
			WIDTH_A => FEED_SIZE, -- Multiplier A-input bus width, 1-25 
			WIDTH_B => COEFF_SIZE) -- Multiplier B-input bus width, 1-18
		port map (
			P   => result3, -- Multiplier ouput bus, width determined by WIDTH_P generic 
			A   => Yn1, -- Multiplier input A bus, width determined by WIDTH_A generic 
			B   => a1, -- Multiplier input B bus, width determined by WIDTH_B generic 
			CE  => '1', -- 1-bit active high input clock enable
			CLK => clock, -- 1-bit positive edge clock input
			RST => reset -- 1-bit input active high reset
		);
	
	MULT_a2_yn2 : MULT_MACRO
		generic map (
			DEVICE  => "7SERIES", -- Target Device    :     "VIRTEX5", "7SERIES", "SPARTAN6" 
			LATENCY => 3, -- Desired clock cycle latency, 0-4
			WIDTH_A => FEED_SIZE, -- Multiplier A-input bus width, 1-25 
			WIDTH_B => COEFF_SIZE) -- Multiplier B-input bus width, 1-18
		port map (
			P   => result4, -- Multiplier ouput bus, width determined by WIDTH_P generic 
			A   => Yn2, -- Multiplier input A bus, width determined by WIDTH_A generic 
			B   => a2, -- Multiplier input B bus, width determined by WIDTH_B generic 
			CE  => '1', -- 1-bit active high input clock enable
			CLK => clock, -- 1-bit positive edge clock input
			RST => reset -- 1-bit input active high reset
		);
	
	ADDSUB_MACRO_inst1 : ADDSUB_MACRO
		generic map (
			DEVICE  => "7SERIES", -- Target Device   :    "VIRTEX5", "7SERIES", "SPARTAN6" 
			LATENCY => 2, -- Desired clock cycle latency, 0-2
			WIDTH   => ADD_SIZE) -- Input / Output bus width, 1-48
		port map (
			CARRYOUT => open, -- 1-bit carry-out output signal
			RESULT   => add0, -- Add/sub result output, width defined by WIDTH generic
			A        => result0, -- Input A bus, width defined by WIDTH generic
			ADD_SUB  => '1', -- 1-bit add/sub input, high selects add, low selects subtract
			B        => result1, -- Input B bus, width defined by WIDTH generic
			CARRYIN  => '0', -- 1-bit carry-in input
			CE       => '1', -- 1-bit clock enable input
			CLK      => clock, -- 1-bit clock input
			RST      => reset -- 1-bit active high synchronous reset
		);
	
	ADDSUB_MACRO_inst2 : ADDSUB_MACRO
		generic map (
			DEVICE  => "7SERIES", -- Target Device   :    "VIRTEX5", "7SERIES", "SPARTAN6" 
			LATENCY => 2, -- Desired clock cycle latency, 0-2
			WIDTH   => ADD_SIZE) -- Input / Output bus width, 1-48
		port map (
			CARRYOUT => open, -- 1-bit carry-out output signal
			RESULT   => add1, -- Add/sub result output, width defined by WIDTH generic
			A        => result3, -- Input A bus, width defined by WIDTH generic
			ADD_SUB  => '1', -- 1-bit add/sub input, high selects add, low selects subtract
			B        => result4, -- Input B bus, width defined by WIDTH generic
			CARRYIN  => '0', -- 1-bit carry-in input
			CE       => '1', -- 1-bit clock enable input
			CLK      => clock, -- 1-bit clock input
			RST      => reset -- 1-bit active high synchronous reset
		);
	
	ADDSUB_MACRO_inst3 : ADDSUB_MACRO
		generic map (
			DEVICE  => "7SERIES", -- Target Device   :    "VIRTEX5", "7SERIES", "SPARTAN6" 
			LATENCY => 2, -- Desired clock cycle latency, 0-2
			WIDTH   => ADD_SIZE) -- Input / Output bus width, 1-48
		port map (
			CARRYOUT => open, -- 1-bit carry-out output signal
			RESULT   => add2, -- Add/sub result output, width defined by WIDTH generic
			A        => add0, -- Input A bus, width defined by WIDTH generic
			ADD_SUB  => '1', -- 1-bit add/sub input, high selects add, low selects subtract
			B        => result2_delay1, -- Input B bus, width defined by WIDTH generic
			CARRYIN  => '0', -- 1-bit carry-in input
			CE       => '1', -- 1-bit clock enable input
			CLK      => clock, -- 1-bit clock input
			RST      => reset -- 1-bit active high synchronous reset
		);
	
	ADDSUB_MACRO_inst4 : ADDSUB_MACRO
		generic map (
			DEVICE  => "7SERIES", -- Target Device   :    "VIRTEX5", "7SERIES", "SPARTAN6" 
			LATENCY => 2, -- Desired clock cycle latency, 0-2
			WIDTH   => ADD_SIZE) -- Input / Output bus width, 1-48
		port map (
			CARRYOUT => open, -- 1-bit carry-out output signal
			RESULT   => Yn, -- Add/sub result output, width defined by WIDTH generic
			A        => add2, -- Input A bus, width defined by WIDTH generic
			ADD_SUB  => '1', -- 1-bit add/sub input, high selects add, low selects subtract
			B        => add1_delay1, -- Input B bus, width defined by WIDTH generic
			CARRYIN  => '0', -- 1-bit carry-in input
			CE       => '1', -- 1-bit clock enable input
			CLK      => clock, -- 1-bit clock input
			RST      => reset -- 1-bit active high synchronous reset
		);
	
	process(all) is
	begin
		if rising_edge(clock) then
			result2_delay1 <= result2_delay0;
			result2_delay0 <= result2;
			
			add1_delay1 <= add1_delay0;
			add1_delay0 <= add1;
		end if;
	end process; 
end architecture struct;