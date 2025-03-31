library lbph;
use lbph.lbph_pkg.all;

library std;
use std.textio.all;
use std.env.finish;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;


entity tb_euclidean_distance is
end entity;

architecture tb of tb_euclidean_distance is

    ---------------------------------------------------------------------------------
    -- Constants
    ---------------------------------------------------------------------------------
    
    constant CLK_PERIOD : time := 20 ns;

    ---------------------------------------------------------------------------------
    -- Components
    ---------------------------------------------------------------------------------

    component euclidean_distance is

        port (
            clk_i    : in  std_logic;
            rst_i    : in  std_logic;
    
            start_i  : in  std_logic;
            hist1_i  : in  histogram_t;
            hist2_i  : in  histogram_t;
    
            done_o   : out std_logic;
            result_o : out distance_t
        );
    
    end component euclidean_distance;

    ---------------------------------------------------------------------------------
    -- Signals
    ---------------------------------------------------------------------------------

    signal clk      : std_logic := '1';
    signal rst      : std_logic := '1';
    signal start    : std_logic := '0';
    signal hist1    : histogram_t := (others => (others => '0'));
    signal hist2    : histogram_t := (others => (others => '0'));
    signal done     : std_logic;
    signal result   : distance_t;

begin

   -- Instantiate the Unit Under Test (UUT) --
    uut: euclidean_distance
        port map (
            clk_i    => clk,
            rst_i    => rst,
            start_i  => start,
            hist1_i  => hist1,
            hist2_i  => hist2,
            done_o   => done,
            result_o => result
        );

    -- clk generation --
    clk <= not clk after CLK_PERIOD / 2;
    
    -- reset behavior --
    rst <= '1', '0' after CLK_PERIOD * 4;

    -- stimulus process --
    stim_proc : process
        variable L : line;
    begin
        wait until rst = '0';
        wait for CLK_PERIOD;

        -- Initialize histograms with test data
        -- Let's use some arbitrary values for testing
        for i in 0 to LBP_BINS - 1 loop
            hist1(i) <= to_unsigned(i, hist1(i)'length);  -- 0, 1, 2, ..., 255
            hist2(i) <= to_unsigned(255 - i, hist2(i)'length);  -- 255, 254, ..., 0
        end loop;

        -- Start computation
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';

        -- Wait and Check
        wait until done = '1';
        assert result = x"0000555500"
            report "Test failed! result_o = " & integer'image(to_integer(result))
            severity failure;

        -- Finished
        wait for CLK_PERIOD * 5;
        report "-- Simulation completed --" severity note;
        finish;

    end process;

end architecture;
