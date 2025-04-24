library lbph;
use lbph.lbph_pkg.all;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;


entity lbph_comp is

    port (
        clk_i    : in  std_logic;
        rst_i    : in  std_logic;

        start_i  : in  std_logic;
        hist1_i  : in  concat_hist_t;
        hist2_i  : in  concat_hist_t;

        done_o   : out std_logic;
        result_o : out distance_t
    );

end lbph_comp;


architecture Behavioral of lbph_comp is

    ---------------------------------------------------------------------------------
    -- Types
    ---------------------------------------------------------------------------------

    type state_t is (IDLE, RUNNING, DONE);


    ---------------------------------------------------------------------------------
    -- Signals
    ---------------------------------------------------------------------------------

    signal current_state, next_state : state_t := IDLE;
    
    signal x_idx, y_idx     : integer range 0 to GRID_LEN_X - 1 := 0;
    signal result_reg       : distance_t := (others => '0');
    signal done_reg         : std_logic := '0';

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


    proc_state_logic : process(current_state, start_i, x_idx, y_idx)
    begin
    
        next_state <= current_state;
        
        case current_state is
            when IDLE =>
                if start_i = '1' then
                    next_state <= RUNNING;
                end if;

            when RUNNING =>
                if x_idx = GRID_LEN_X - 1 and y_idx = GRID_LEN_Y - 1 then
                    next_state <= DONE;
                end if;

            when DONE =>
                next_state <= IDLE;
        end case;
        
    end process;


    proc_state_data : process(clk_i)
    
        variable sum : distance_t;
    begin
        if rising_edge(clk_i) then
        
            case current_state is
                when IDLE =>
                
                    -- reset value --
                    result_reg <= (others => '0');
                    x_idx <= 0;
                    y_idx <= 0;
                    done_reg <= '0';

                when RUNNING =>
                
                    -- compute distance for this (y_idx, x_idx) histogram cell
                    sum := (others => '0');
                    for i in 0 to LBP_BINS - 1 loop
                        sum := sum + squared_diff(hist1_i(y_idx, x_idx)(i), hist2_i(y_idx, x_idx)(i));
                    end loop;
                    
                    result_reg <= result_reg + sum;

                    -- next position
                    if x_idx = GRID_LEN_X - 1 then
                        x_idx <= 0;
                        y_idx <= y_idx + 1;
                    else
                        x_idx <= x_idx + 1;
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
    result_o <= result_reg;

end Behavioral;
