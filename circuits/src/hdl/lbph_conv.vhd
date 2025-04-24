library lbph;
use lbph.lbph_pkg.all;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;


entity lbph_conv is

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

end lbph_conv;

architecture Behavioral of lbph_conv is

    ---------------------------------------------------------------------------------
    -- Components
    ---------------------------------------------------------------------------------

    component fifo_generator_0
    
        port (
            clk       : in  std_logic;
            srst      : in  std_logic;
            
            din       : in  pixel_t;
            wr_en     : in  std_logic;
            rd_en     : in  std_logic;
            
            dout      : out pixel_t;
            full      : out std_logic;
            empty     : out std_logic;
            prog_full : out std_logic
        );
      
    end component;
    
    component lbph_pixel_encoder
        
        port (
            p0_i, p1_i, p2_i, p3_i, p4_i, p5_i, p6_i, p7_i, p8_i : in pixel_t;
            lbp_o                                                : out lbp_value_t
        );
        
    end component;
    
    
    ---------------------------------------------------------------------------------
    -- Types
    ---------------------------------------------------------------------------------
    
    type state_t is (IDLE, LOADING);

    
    ---------------------------------------------------------------------------------
    -- Signals
    ---------------------------------------------------------------------------------

    signal current_state, next_state : state_t := IDLE;
    
    signal count, x, y : integer;
    signal lbp_val : lbp_value_t;
    signal in_border, mx_filled, last, first_tmp : std_logic;
    
    signal p0, p1, p2, p3, p4, p5, p6, p7, p8 : pixel_t;

    signal f1_wr_en, f1_full, f1_empty, f1_prog_full_to_rd_en : std_logic;
    signal f2_wr_en, f2_full, f2_empty, f2_prog_full_to_rd_en : std_logic;

begin

    ---------------------------------------------------------------------------------
    -- GENERATE
    ---------------------------------------------------------------------------------

    FIFO_1 : fifo_generator_0 -- fifo prog_full is set to 480 - 3 /!\
        port map (
            clk       => clk_i,
            srst      => rst_i,
            din       => p3,
            wr_en     => f1_wr_en,
            rd_en     => f1_prog_full_to_rd_en,
            dout      => p2,
            full      => f1_full,
            empty     => f1_empty,
            prog_full => f1_prog_full_to_rd_en
        );

    FIFO_2 : fifo_generator_0
        port map (
            clk       => clk_i,
            srst      => rst_i,
            din       => p6,
            wr_en     => f2_wr_en,
            rd_en     => f2_prog_full_to_rd_en,
            dout      => p5,
            full      => f2_full,
            empty     => f2_empty,
            prog_full => f2_prog_full_to_rd_en
        );
        
    lbp : lbph_pixel_encoder
        port map (
            p0_i  => p0,
            p1_i  => p1,
            p2_i  => p2,
            p3_i  => p3,
            p4_i  => p4,
            p5_i  => p5,
            p6_i  => p6,
            p7_i  => p7,
            p8_i  => p8,
            lbp_o => lbp_val
        );
        
        
    ---------------------------------------------------------------------------------
    -- PROCESS
    ---------------------------------------------------------------------------------

    proc_state : process (clk_i)
    begin
    
        if rising_edge(clk_i) then
            if rst_i = '1' then
                current_state <= IDLE;
            else
                current_state <= next_state;
            end if;
        end if;
    
    end process;


    proc_handler : process(current_state, start_i, last)
    begin
    
        next_state <= current_state;
        
        case current_state is
            when IDLE =>
                if start_i = '1' then
                    next_state <= LOADING;
                end if;
                
            when LOADING =>
                if last = '1' then
                    next_state <= IDLE;
                end if;
                
        end case;
    end process;


    proc_compute : process (clk_i) 
    begin
        
        if rising_edge(clk_i) then
            case current_state is
                
                when IDLE =>
                
                    -- reset value --
                    p0 <= (others => '0');
                    p1 <= (others => '0');
                 -- p2 <= (others => '0');
                    p3 <= (others => '0');
                    p4 <= (others => '0');
                 -- p5 <= (others => '0');
                    p6 <= (others => '0');
                    p7 <= (others => '0');
                 -- p8 <= (others => '0');
                    
                    f1_wr_en <= '0';
                    f2_wr_en <= '0';
                    
                    first_tmp <= '1';
                    count <= 0;
                    x <= 0;
                    y <= 0;
                                      
    
                when LOADING =>
                
                    -- enable --
                    f1_wr_en <= '1';
                    f2_wr_en <= '1';
                
                    -- conv --
                    p0 <= p1;
                    p1 <= p2;
                 -- p2 <= p3; in FIFO1
                    p3 <= p4;
                    p4 <= p5;
                 -- p5 <= p6; in FIFO2
                    p6 <= p7;
                    p7 <= p8;
                 -- p8 <= px_i;
                    
                    -- first --
                    if valid_o = '1' and first_tmp = '1' then
                    
                        first_tmp <= '0';
                    end if;
                    
                    -- count --
                    count <= count + 1;
                    
                    if count > IMG_WIDTH then       -- skip first pixel (FIFO not fill yet)
                        if x = IMG_WIDTH - 1 then
                        
                            x <= 0;
                            y <= y + 1;
                        else 
                        
                            x <= x + 1;
                            y <= y;
                        end if;
                    
                    else 
                        x <= 0;
                        y <= 0;
                    end if;
                    
            end case;
        end if;   
    end process;


    ---------------------------------------------------------------------------------
    -- COMBINATORY
    ---------------------------------------------------------------------------------

    p8 <= px_i;
    in_border <= '1' when x = 0 or y = 0 or x = IMG_WIDTH - 1 or y = IMG_HEIGHT - 1 else '0';
    mx_filled <= '1' when count > (2 * IMG_WIDTH + 1) else '0';
    
    last      <= '1' when y = IMG_HEIGHT - 3 and x = IMG_WIDTH - 2 else '0';
    last_o    <= last;
    valid_o   <= '1' when in_border = '0' and mx_filled = '1' else '0';
    lbp_val_o <= unsigned(p0) when in_border = '0' and mx_filled = '1' else (others => '0');
    first_o <= '1' when valid_o = '1' and first_tmp = '1' else '0';

end Behavioral;
