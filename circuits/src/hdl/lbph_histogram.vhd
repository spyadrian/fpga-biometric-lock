library lbph;
use lbph.lbph_pkg.all;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity lbph_histogram is

    port (
        clk_i         : in std_logic;
        rst_i         : in std_logic;

        start_i       : in std_logic;
        valid_i       : in std_logic;
        lbp_val_i     : in lbp_value_t;

        done_o        : out std_logic;
        concat_hist_o : out concat_hist_t
    );

end lbph_histogram;

architecture Behavioral of lbph_histogram is

    ---------------------------------------------------------------------------------
    -- Types
    ---------------------------------------------------------------------------------
    
    type state_t is (IDLE, RUNNING, DONE);
    
    
    ---------------------------------------------------------------------------------
    -- Signals
    ---------------------------------------------------------------------------------
    
    signal current_state, next_state : state_t := IDLE;

    signal x, y         : integer range 1 to IMG_WIDTH - 2 := 1;
    signal gx, gy       : integer range 0 to GRID_LEN_X - 1 := 0;
    signal bin          : integer range 0 to LBP_BINS - 1 := 0;

    signal hist         : concat_hist_t := (others => (others => (others => (others => '0'))));
    signal done_reg     : std_logic := '0';

begin

    ---------------------------------------------------------------------------------
    -- PROCESS
    ---------------------------------------------------------------------------------

    proc_state_reg : process(clk_i)
    begin
    
        if rising_edge(clk_i) then
            if rst_i = '1' then
                current_state <= IDLE;
            else
                current_state <= next_state;
            end if;
        end if;
        
    end process;


    proc_state_logic : process(current_state, start_i, x, y)
    begin
    
        next_state <= current_state;
        
        case current_state is
            when IDLE =>
                if start_i = '1' then
                    next_state <= RUNNING;
                end if;

            when RUNNING =>
                if y = IMG_HEIGHT - 2 and x = IMG_WIDTH - 2 then
                    next_state <= DONE;
                end if;

            when DONE =>
                next_state <= IDLE;
        end case;
        
    end process;


    proc_state_data : process(clk_i)
    
        variable gx_v, gy_v : integer;
        variable bin_v : integer;
    begin
        if rising_edge(clk_i) then

            case current_state is
                when IDLE =>
                
                    -- reset value --
                    hist <= (others => (others => (others => (others => '0'))));
                    x <= 1;
                    y <= 1;
                    done_reg <= '0';

                when RUNNING =>
                
                    if valid_i = '1' then
                    
--                        gx <= get_grid_x(x);
--                        gy <= get_grid_y(y);
--                        bin <= to_integer(lbp_val_i);

--                        hist(get_grid_y(y), get_grid_x(x))(to_integer(lbp_val_i)) 
--                            <= hist(get_grid_y(y), get_grid_x(x))(to_integer(lbp_val_i)) + 1;
                        gx_v := get_grid_x(x);
                        gy_v := get_grid_y(y);
                        bin_v := to_integer(lbp_val_i);
                        hist(gy_v, gx_v)(bin_v) <= hist(gy_v, gx_v)(bin_v) + 1;

                        if x = IMG_WIDTH - 2 then
                            x <= 1;
                            y <= y + 1;
                        else
                            x <= x + 1;
                        end if;
                    end if;

                when DONE =>
                    done_reg <= '1';
                    
            end case;

        end if;
    end process;


    ---------------------------------------------------------------------------------
    -- COMBINATORY
    ---------------------------------------------------------------------------------

    done_o <= done_reg;
    concat_hist_o <= hist;


end Behavioral;
