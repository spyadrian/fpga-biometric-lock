library lbph;
use lbph.lbph_pkg.all;

library std;
use std.textio.all;
use std.env.finish;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;


entity tb_lbph is
end entity;

architecture tb of tb_lbph is

    ---------------------------------------------------------------------------------
    -- Constants
    ---------------------------------------------------------------------------------
    
    constant CLK_PERIOD : time := 2 ns;


    ---------------------------------------------------------------------------------
    -- Components
    ---------------------------------------------------------------------------------

    component lbph is
    
        port (
            clk_i       : in  std_logic;
            rst_i       : in  std_logic;
    
            px_i        : in  pixel_t;
            start_i     : in  std_logic;
            ref_hist_i  : in  concat_hist_t;    -- could be a generic
    
            done_o      : out std_logic;
            result_o    : out std_logic
        );
        
    end component;


    ---------------------------------------------------------------------------------
    -- Types
    ---------------------------------------------------------------------------------
    
    type linear_image_t is array (0 to NUM_PIXELS - 1) of pixel_t;


    ---------------------------------------------------------------------------------
    -- Signals
    ---------------------------------------------------------------------------------

    signal clk         : std_logic := '1';
    signal rst         : std_logic := '1';
    
    signal px_i        : pixel_t := (others => '0');
    signal start_i     : std_logic := '0';
    signal ref_hist_i  : concat_hist_t := (others => (others => (others => (others => '0'))));

    signal done_o      : std_logic;
    signal result_o    : std_logic;

    signal test_image : linear_image_t := (others => std_logic_vector(to_unsigned(128, PXL_SIZE))); -- flat mid-gray image

begin

    -- Instantiate the Unit Under Test (UUT) --
    uut : lbph
        port map (
            clk_i       => clk,
            rst_i       => rst,
            px_i        => px_i,
            start_i     => start_i,
            ref_hist_i  => ref_hist_i,
            done_o      => done_o,
            result_o    => result_o
        );

    -- clk generation --
    clk <= not clk after CLK_PERIOD / 2;
    
    -- reset behavior --
    rst <= '1', '0' after CLK_PERIOD * 4;

    -- stimulus process --
    stim_proc : process
    
        variable b1 : bin_t;
    begin
        wait until rst = '0';
        wait for CLK_PERIOD;

        -- fill ref histogram
        for y in 0 to GRID_LEN_Y - 1 loop
            for x in 0 to GRID_LEN_X - 1 loop
                for i in 0 to LBP_BINS - 1 loop

                    b1 := to_unsigned(i, 13);               -- 0 to 255
                    ref_hist_i(y, x)(i) <= b1;
                end loop;
            end loop;
        end loop;

        -- start
        start_i <= '1';
        wait for CLK_PERIOD;
        start_i <= '0';

        -- Feed the image one pixel at a time
        for i in 0 to NUM_PIXELS - 1 loop
            px_i <= test_image(i);
            wait for CLK_PERIOD;            
        end loop;

        -- Wait
        wait until done_o = '1';
        wait for CLK_PERIOD;
        
        -- check
        report "Result: " & std_logic'image(result_o);

        -- Finished
        wait for CLK_PERIOD * 5;
        report "-- Simulation completed --" severity note;
        finish;

    end process;

end architecture;
