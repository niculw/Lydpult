-- Testbench automatically generated online
-- at http://vhdl.lapinoo.net
-- Generation date : 28.2.2019 11:47:07 GMT

library ieee;
use ieee.std_logic_1164.all;
use work.types.all;

entity filter_testbench is
end filter_testbench;

architecture tb of filter_testbench is

    component one_filter
        port (clock          : in std_logic;
              reset          : in std_logic;
              b0_in          : in to_coeff;
              b1_in          : in to_coeff;
              b2_in          : in to_coeff;
              a1_in          : in to_coeff;
              a2_in          : in to_coeff;
              x              : in std_logic_vector (feed_size - 1 downto 0);
              y_resized      : out sfixed (feed_size - 1 downto 0);
              ch_in          : in address;
              ch_delayed_in  : in address;
              ch_delayed_out : out address;
              ch_out         : out address);
    end component;

    signal clock          : std_logic;
    signal reset          : std_logic;
    signal b0_in          : to_coeff;
    signal b1_in          : to_coeff;
    signal b2_in          : to_coeff;
    signal a1_in          : to_coeff;
    signal a2_in          : to_coeff;
    signal x              : std_logic_vector (feed_size - 1 downto 0);
    signal y_resized      : sfixed (feed_size - 1 downto 0);
    signal ch_in          : address;
    signal ch_delayed_in  : address;
    signal ch_delayed_out : address;
    signal ch_out         : address;

    constant TbPeriod : time := 1000 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : one_filter
    port map (clock          => clock,
              reset          => reset,
              b0_in          => b0_in,
              b1_in          => b1_in,
              b2_in          => b2_in,
              a1_in          => a1_in,
              a2_in          => a2_in,
              x              => x,
              y_resized      => y_resized,
              ch_in          => ch_in,
              ch_delayed_in  => ch_delayed_in,
              ch_delayed_out => ch_delayed_out,
              ch_out         => ch_out);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clock is really your main clock signal
    clock <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        b0_in <= "011000110000100110";
        b1_in <= "111011001101111011";
        b2_in <= "001001101001000111";
        a1_in <= "111011001110000011";
        a2_in <= "000000110010110100";
        x <= (others => '0');
        ch_in <= '0';
        ch_delayed_in <= '0';

        -- Reset generation
        -- EDIT: Check that reset is really your reset signal
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;

        -- EDIT Add stimuli here
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.