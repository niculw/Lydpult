library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;

entity bram_block is
	generic (
		address : integer := ADDR_SIZE
			);
		port (
			clock : in std_logic;
			
			
			--------------------------------------------------------------------
			-- Coefficients
			--------------------------------------------------------------------
		
			b0_in  : in  to_coeff;
			b0_out : out from_coeff; -- data out
		
			b1_in  : in  to_coeff;
			b1_out : out from_coeff; -- data out
		
			b2_in  : in  to_coeff;
			b2_out : out from_coeff; -- data out
		
			a1_in  : in  to_coeff;
			a1_out : out from_coeff; -- data out
		
			a2_in  : in  to_coeff;
			a2_out : out from_coeff; -- data out
			
			
			--------------------------------------------------------------------
			-- Input/feedback
			--------------------------------------------------------------------
			x1_out : out from_feed;
			x2_out : out from_feed;
			y1_out : out from_feed;
			y2_out : out from_feed;
			--------------------------------------------------------------------
			-- signals in
			--------------------------------------------------------------------
			x_in : in std_logic_vector(FEED_SIZE-1 downto 0);
			y_in : in std_logic_vector(FEED_SIZE-1 downto 0);

			--------------------------------------------------------------------
			-- Address
			--------------------------------------------------------------------
			read_addr_in : in std_logic_vector(address - 1 downto 0);
			read_en_in   : in std_logic;
			-- delayed address for write
			write_addr_in : in std_logic_vector(address - 1 downto 0);
			write_en      : in std_logic;
			
			-- delayed write for y1 register
			write_addr_in_del : in std_logic_vector(address - 1 downto 0);
			write_en_del      : in std_logic
			
			
		);
		end entity bram_block;
		
		architecture structure of bram_block is
			
			type coeff_signals is array (integer range 0 to 4) of coeff;
			signal names : coeff_signals;

			type feed_signals is array (integer range 0 to 3) of feed;
			signal feed : feed_signals;			
		begin

			--------------------------------------------------------------------
			-- coeff
			--------------------------------------------------------------------
			-- connect inputs to signals
			names(0).to_block <= b0_in;
			names(1).to_block <= b1_in;
			names(2).to_block <= b2_in;
			names(3).to_block <= a1_in;
			names(4).to_block <= a2_in;
			
			-- connect signals to outputs
			b0_out <= names(0).from_block;
			b1_out <= names(1).from_block;
			b2_out <= names(2).from_block;
			a1_out <= names(3).from_block;
			a2_out <= names(4).from_block;

			--------------------------------------------------------------------
			-- feed
			--------------------------------------------------------------------
			-- connect signals to outputs
			x1_out <= feed(0).from_block;
			x2_out <= feed(1).from_block;
			y1_out <= feed(2).from_block;
			y2_out <= feed(3).from_block;


			-- connect inputs to signals
			feed_to_sig : for i in 0 to 3 generate
				y1 : if (i = 2) generate -- connect inputs to y1 bram
					feed(i).to_block.wea <= write_en_del;
					feed(i).to_block.addra <= write_addr_in_del;
					feed(i).to_block.dia <= y_in;
				else generate -- connect inputs to x1, x2, y2 bram
					feed(i).to_block.wea <= write_en;
					feed(i).to_block.addra <= write_addr_in;
					x1 : if (i = 0) generate
						feed(i).to_block.dia <= x_in; -- input for x1
					end generate x1;
					x2y2 : if (i = 1 or i = 3) generate
						feed(i).to_block.dia <= feed(i-1).from_block.dob; -- input for x2 and y2 is from previous
					end generate x2y2;
				end generate y1;
			end generate feed_to_sig;


			--------------------------------------------------------------------
			-- BRAM GENERATION
			--------------------------------------------------------------------
			-- generate 5 coefficent brams
			coeff_bram_gen : for i in 0 to 4 generate
				coeff_bram : entity work.memory3
					generic map(
						ADDR_SIZE => address,
						DATA_SIZE => COEFF_SIZE
					)
					port map(
						clk => clock,
						--port a write
						ena   => names(i).to_block.ena,
						wea   => names(i).to_block.wea,
						addra => names(i).to_block.addra,
						dia   => names(i).to_block.dia,
						doa   => open,
						--port b read
						enb   => read_en_in,
						web   => '0',
						addrb => read_addr_in,
						dib   => (others => '0'),
						dob   => names(i).from_block.dob
					);
			end generate coeff_bram_gen;
			
			-- generate 4 feedback/feedforward brams
			feed_bram_gen : for i in 0 to 3 generate
				feed_bram : entity work.memory3
					generic map(
						ADDR_SIZE => address,
						DATA_SIZE => FEED_SIZE
					)
					port map(
						clk => clock,
						--port a write
						ena   => '1',
						wea   => feed(i).to_block.wea,
						addra => feed(i).to_block.addra,
						dia   => feed(i).to_block.dia,
						doa   => open,
						--port b read
						enb   => read_en_in,
						web   => '0',
						addrb => read_addr_in,
						dib   => (others => '0'),
						dob   => feed(i).from_block.dob
					);
			end generate feed_bram_gen;

		end architecture structure;