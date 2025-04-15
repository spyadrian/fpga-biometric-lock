library lbph;
use lbph.lbph_pkg.all;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;


entity lbph_histogram is

    port (
        clk_i        : in  std_logic;
        rst_i        : in  std_logic;
        
        start_i      : in  std_logic;
        lbp_image_i  : in  lbp_image_t;
        
        done_o       : out std_logic;
        histogram_o  : out grid_histogram_t
    );

end lbph_histogram;


architecture Behavioral of lbph_histogram is

    ---------------------------------------------------------------------------------
    -- Signals
    ---------------------------------------------------------------------------------

    signal x, y  : integer range 0 to IMG_WIDTH - 1 := 1;
    signal gx, gy : integer range 0 to GRID_LEN_X - 1;
    signal bin    : integer range 0 to LBP_BINS - 1;
    signal histogram : grid_histogram_t := (others => (others => (others => (others => '0'))));
    signal running : std_logic := '0';

begin

    histogram_o <= histogram;

    proc_histogram : process(clk_i, rst_i)
    begin
    
        if rst_i = '1' then
        
            x <= 1;
            y <= 1;
            running <= '0';
            done_o <= '0';
            
            histogram <= (others => (others => (others => (others => '0'))));

        elsif rising_edge(clk_i) then
        
            if start_i = '1' and running = '0' then
            
                x <= 1;
                y <= 1;
                running <= '1';
                done_o <= '0';
                histogram <= (others => (others => (others => (others => '0'))));

            elsif running = '1' then
            
                gx <= get_grid_x(x);
                gy <= get_grid_y(y);
                bin <= to_integer(unsigned(lbp_image_i(y, x)));
                histogram(gy, gx)(bin) <= histogram(gy, gx)(bin) + 1;

                if x < IMG_WIDTH - 2 then
                    x <= x + 1;
                else
                    x <= 1;
                    if y < IMG_HEIGHT - 2 then
                        y <= y + 1;
                    else
                        running <= '0';
                        done_o <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
