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
        hist1_i  : in  hist_t;
        hist2_i  : in  hist_t;

        done_o   : out std_logic;
        result_o : out distance_t
    );

end lbph_comp;


architecture Behavioral of lbph_comp is

    ---------------------------------------------------------------------------------
    -- Types
    ---------------------------------------------------------------------------------

    type diff_squared_array_t is array(0 to 255) of distance_t;
    
    ---------------------------------------------------------------------------------
    -- Signals
    ---------------------------------------------------------------------------------

    signal diff_squared_array : diff_squared_array_t;

begin

    ---------------------------------------------------------------------------------
    -- GENERATE
    -- generate 255 diff_squared_array to be able to compute the euclidean distance
    -- in one clock cycle.
    ---------------------------------------------------------------------------------

    gen_diff: for i in 0 to 255 generate
    begin

        diff_squared_array(i) <= squared_diff(hist1_i(i), hist2_i(i));
    end generate;


    ---------------------------------------------------------------------------------
    -- PROCESS
    ---------------------------------------------------------------------------------

    proc_euclidean : process(clk_i)

        variable sum : distance_t := (others => '0'); -- Enough for 256 x 32-bit max sum
    begin

        if rising_edge(clk_i) then 
        
            done_o <= '0';
            result_o <= (others => '0');
        
            if start_i = '1' and rst_i = '0' then 

                sum := (others => '0');
                for i in diff_squared_array'range loop
                
                    sum := sum + resize(diff_squared_array(i), sum'length);
                end loop;
        
                -- square root (not typically needed for LBPH matching)
                -- result_o <= sqrt(sum); -- Not synthesizable by default
                
                done_o <= '1';
                result_o <= sum;
            end if;         
        end if;
    end process proc_euclidean;

end Behavioral;
