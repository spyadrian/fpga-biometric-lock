library lbph;
use lbph.lbph_pkg.all;

library std;
use std.textio.all;
use std.env.finish;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;


entity tb_lbph_histogram is
end entity;

architecture tb of tb_lbph_histogram is

    ---------------------------------------------------------------------------------
    -- Constants
    ---------------------------------------------------------------------------------
    
    constant CLK_PERIOD : time := 2 ns;


    ---------------------------------------------------------------------------------
    -- Components
    ---------------------------------------------------------------------------------

    component lbph_histogram is

        port (
            clk_i         : in std_logic;
            rst_i         : in std_logic;
            
            start_i       : in std_logic;
            valid_i       : in std_logic;
            lbp_val_i     : in lbp_value_t;
            
            done_o        : out std_logic;
            concat_hist_o : out concat_hist_t
        );
    
    end component lbph_histogram;


    ---------------------------------------------------------------------------------
    -- Signals
    ---------------------------------------------------------------------------------

    signal clk         : std_logic := '1';
    signal rst         : std_logic := '1';

    signal start       : std_logic := '0';
    signal valid       : std_logic := '0';
    signal lbp_val     : lbp_value_t := (others => '0');

    signal done        : std_logic;
    signal hist        : concat_hist_t;

begin

    -- Instantiate the Unit Under Test (UUT) --
    uut : lbph_histogram
        port map (
            clk_i         => clk,
            rst_i         => rst,
            start_i       => start,
            valid_i       => valid,
            lbp_val_i     => lbp_val,
            done_o        => done,
            concat_hist_o => hist
        );


    -- clk generation --
    clk <= not clk after CLK_PERIOD / 2;

    -- reset behavior --
    rst <= '1', '0' after CLK_PERIOD * 4;

    -- stimulus process --
    stim_proc : process
    begin
        wait until rst = '0';
        wait for CLK_PERIOD;

        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';

        img_loop: for y in 0 to IMG_HEIGHT + 10 loop -- to stop when flag done is 1
            row_loop: for x in 0 to IMG_WIDTH - 2 - 1 loop

                if done = '1' then
                    valid <= '0';
                    exit img_loop;
                end if;

                if y mod 2 = 0 then
                    lbp_val <= (others => '1');
                else 
                    lbp_val <= (others => '0');
                end if;

                valid <= '1';
                wait for CLK_PERIOD;                
            end loop;
        end loop;  
              
        -- print
--        report "done : " & std_logic'image(done);
--        report "hist(0,0)(0)   : " & integer'image(to_integer(hist(0,0)(0)));
--        report "hist(0,0)(255) : " & integer'image(to_integer(hist(0,0)(255)));
--        report "hist(1,1)(0)   : " & integer'image(to_integer(hist(1,1)(0)));
--        report "hist(1,1)(255) : " & integer'image(to_integer(hist(1,1)(255)));
--        report "hist(7,7)(0)   : " & integer'image(to_integer(hist(7,7)(0)));
--        report "hist(7,7)(255) : " & integer'image(to_integer(hist(7,7)(255)));

        -- assert
        assert hist(0,0)(0) = 2301 and  hist(0,0)(255) = 2360
        report "mismatch at for hist(0,0)" severity error;

        assert hist(1,1)(0) = 2400 and hist(1,1)(255) = 2400
        report "mismatch at for hist(1,1)" severity error;

        assert hist(7,7)(0) = 2360 and hist(7,7)(255) = 2301 -- /!\ it missmatch : only hint the final IDLE that reset only one cycle after
        report "mismatch at for hist(7,7)" severity error;

        -- Finished
        wait for CLK_PERIOD * 5;
        report "-- Simulation completed --" severity note;
        finish;

    end process;

end architecture;
