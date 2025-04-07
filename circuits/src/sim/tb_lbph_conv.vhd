library lbph;
use lbph.lbph_pkg.all;

library std;
use std.textio.all;
use std.env.finish;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;


entity tb_lbph_conv is
end entity;

architecture tb of tb_lbph_conv is

    ---------------------------------------------------------------------------------
    -- Constants
    ---------------------------------------------------------------------------------
    
    constant CLK_PERIOD : time := 2 ns;


    ---------------------------------------------------------------------------------
    -- Components
    ---------------------------------------------------------------------------------

    component lbph_conv is

        port (
            clk_i   : in std_logic;
            rst_i   : in std_logic;
            
            px_i    : in pixel_t;
            start_i : in std_logic;
            
            px_o    : out pixel_t;
            last_o  : out std_logic;
            valid_o : out std_logic
        );
    
    end component lbph_conv;


    ---------------------------------------------------------------------------------
    -- Signals
    ---------------------------------------------------------------------------------

    signal clk    : std_logic := '1';
    signal rst    : std_logic := '1';
    signal start  : std_logic := '0';
    signal px     : pixel_t   := (others => '1');
    
    signal px_out : pixel_t;
    signal last   : std_logic;
    signal valid  : std_logic;

begin

    -- Instantiate the Unit Under Test (UUT) --
    uut: lbph_conv
        port map (
            clk_i   => clk,
            rst_i   => rst,
            px_i    => px,
            start_i => start,
            px_o    => px_out,
            last_o  => last,
            valid_o => valid
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


            for y in 0 to IMG_HEIGHT-1 loop
                for x in 0 to IMG_WIDTH-1 loop

                    if y mod 2 = 0 then
                        px <= (others => '1');
                    else 
                        px <= (others => '0');
                    end if;

                    if valid = '1' then
                        assert px_out /= "00011000" or px_out /= "11111111"
                        report "mismatch at (" & integer'image(x) & ", " & integer'image(y) & ")" severity error;
                    end if;
                    
                    wait for CLK_PERIOD;

                end loop;
            end loop;

        -- Finished
        wait for CLK_PERIOD * 5;
        report "-- Simulation completed --" severity note;
        finish;

    end process;

end architecture;
