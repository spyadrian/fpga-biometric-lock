library lbph;
use lbph.lbph_pkg.all;

library std;
use std.textio.all;
use std.env.finish;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;


entity tb_lbph_comp is
end entity;

architecture tb of tb_lbph_comp is

    ---------------------------------------------------------------------------------
    -- Constants
    ---------------------------------------------------------------------------------
    
    constant CLK_PERIOD : time := 20 ns;

    ---------------------------------------------------------------------------------
    -- Components
    ---------------------------------------------------------------------------------

    component lbph_comp is

        port (
            clk_i    : in  std_logic;
            rst_i    : in  std_logic;
    
            start_i  : in  std_logic;
            hist1_i  : in  concat_hist_t;
            hist2_i  : in  concat_hist_t;
    
            done_o   : out std_logic;
            result_o : out distance_t
        );

    end component lbph_comp;


    ---------------------------------------------------------------------------------
    -- Signals
    ---------------------------------------------------------------------------------

    signal clk      : std_logic := '1';
    signal rst      : std_logic := '1';
    signal start    : std_logic := '0';

    signal hist1    : concat_hist_t := (others => (others => (others => (others => '0'))));
    signal hist2    : concat_hist_t := (others => (others => (others => (others => '0'))));

    signal done     : std_logic;
    signal result   : distance_t;

begin

   -- Instantiate the Unit Under Test (UUT) --
    uut: lbph_comp
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
    
        variable b1, b2   : bin_t;
    begin
        wait until rst = '0';
        wait for CLK_PERIOD;

        -- Fill histograms with known values: mirror patterns
        for y in 0 to GRID_LEN_Y - 1 loop
            for x in 0 to GRID_LEN_X - 1 loop
                for i in 0 to LBP_BINS - 1 loop

                    b1 := to_unsigned(i, 13);               -- 0 to 255
                    b2 := to_unsigned(255 - i, 13);         -- 255 to 0
                    hist1(y, x)(i) <= b1;
                    hist2(y, x)(i) <= b2;
                end loop;
            end loop;
        end loop;

        -- Start computation
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';

        -- Wait for done
        wait until done = '1';
        wait for CLK_PERIOD;

        -- Check result
        assert result = to_unsigned(357908480, result'length)
            report "Test failed! result = " & integer'image(to_integer(result)) & ", expected = 357908480"
            severity failure;

        -- Finished
        wait for CLK_PERIOD * 5;
        report "-- Simulation completed --" severity note;
        finish;

    end process;

end architecture;
