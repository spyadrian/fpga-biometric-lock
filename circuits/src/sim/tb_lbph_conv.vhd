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
            clk_i     : in std_logic;
            rst_i     : in std_logic;
            
            px_i      : in pixel_t;
            start_i   : in std_logic;
            
            lbp_val_o : out lbp_value_t;
            first_o   : out std_logic;
            last_o    : out std_logic;
            valid_o   : out std_logic
        );
    
    end component lbph_conv;


    ---------------------------------------------------------------------------------
    -- Signals
    ---------------------------------------------------------------------------------

    signal clk         : std_logic := '1';
    signal rst         : std_logic := '1';
    signal start       : std_logic := '0';
    signal px          : pixel_t   := (others => '1');
    
    signal lbp_val_out : lbp_value_t;
    signal first       : std_logic;
    signal last        : std_logic;
    signal valid       : std_logic;

begin

    -- Instantiate the Unit Under Test (UUT) --
    uut: lbph_conv
        port map (
            clk_i     => clk,
            rst_i     => rst,
            px_i      => px,
            start_i   => start,
            lbp_val_o => lbp_val_out,
            first_o   => first,
            last_o    => last,
            valid_o   => valid
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

                    if first = '1' then

                        assert y = 2 and x = 3
                        report "mismatch first flag for : x = " & integer'image(x) & "; y = " & integer'image(y) severity error;
                    end if;

                    if y mod 2 = 0 then
                        px <= (others => '1');
                    else 
                        px <= (others => '0');
                    end if;

                    if valid = '1' then
                        assert lbp_val_out /= "00011000" or lbp_val_out /= "11111111"
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
