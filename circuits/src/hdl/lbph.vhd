library lbph;
use lbph.lbph_pkg.all;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;


entity lbph is

    port (
        clk_i       : in  std_logic;
        rst_i       : in  std_logic;

        px_i        : in  pixel_t;
        start_i     : in  std_logic;
        ref_hist_i  : in  concat_hist_t;    -- could be a generic

        done_o      : out std_logic;
        result_o    : out std_logic
    );
    
end lbph;

architecture Behavioral of lbph is

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
    
    end component;

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
    
    end component;

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
    
    end component;


    ---------------------------------------------------------------------------------
    -- Types
    ---------------------------------------------------------------------------------
    
    type state_t is (IDLE, RUNNING, DONE);

    
    ---------------------------------------------------------------------------------
    -- Signals
    ---------------------------------------------------------------------------------

    signal current_state, next_state : state_t := IDLE;

    -- lbph_conv
    signal lbp_val     : lbp_value_t;
    signal valid_lbp   : std_logic;
    signal first_lbp   : std_logic;
    signal last_lbp    : std_logic;

    -- histogram
    signal hist_done   : std_logic;
    signal concat_hist : concat_hist_t;

    -- comp
    signal result_comp : distance_t;
    
    -- reg for timing
    signal reg_lbp_val   : lbp_value_t := (others => '0');
    signal reg_valid_lbp : std_logic := '0';

begin

    ---------------------------------------------------------------------------------
    -- GENERATE
    ---------------------------------------------------------------------------------

    conv_inst : lbph_conv
        port map (
            clk_i     => clk_i,
            rst_i     => rst_i,
            px_i      => px_i,
            start_i   => start_i,
            lbp_val_o => lbp_val,
            first_o   => first_lbp,
            last_o    => last_lbp,
            valid_o   => valid_lbp
        );

    histo_inst : lbph_histogram
        port map (
            clk_i         => clk_i,
            rst_i         => rst_i,
            start_i       => first_lbp,
            valid_i       => reg_valid_lbp,
            lbp_val_i     => reg_lbp_val,
            done_o        => hist_done,
            concat_hist_o => concat_hist
        );

    comp_inst : lbph_comp
        port map (
            clk_i    => clk_i,
            rst_i    => rst_i,
            start_i  => hist_done,
            hist1_i  => concat_hist,
            hist2_i  => ref_hist_i,
            done_o   => done_o,
            result_o => result_comp
        );


    ---------------------------------------------------------------------------------
    -- PROCESS
    ---------------------------------------------------------------------------------

    -- handle register for timing
    reg_stage : process(clk_i)
    begin
        if rising_edge(clk_i) then
            if rst_i = '1' then
                reg_lbp_val   <= (others => '0');
                reg_valid_lbp <= '0';
            else
                reg_lbp_val   <= lbp_val;
                reg_valid_lbp <= valid_lbp;
            end if;
        end if;
    end process;


    ---------------------------------------------------------------------------------
    -- COMBINATORY
    ---------------------------------------------------------------------------------

    result_o <= '1' when result_comp < MATCH_THRESHOLD else '0';


end Behavioral;
