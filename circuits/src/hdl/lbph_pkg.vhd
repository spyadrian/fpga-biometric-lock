library lbph;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;

package lbph_pkg is

    ---------------------------------------------------------------------------------
    -- Constants
    ---------------------------------------------------------------------------------

    constant IMG_HEIGHT : integer := 640;
    constant IMG_WIDTH  : integer := 480;

    constant GRID_LEN_X : integer := 8;
    constant GRID_LEN_Y : integer := 8; 

    constant GRID_WIDTH  : integer := 60;-- IMG_WIDTH / GRID_LEN_X;
    constant GRID_HEIGHT : integer := 80;-- IMG_HEIGHT / GRID_LEN_Y;

    constant PXL_SIZE : integer := 8;
    constant LBP_BINS : integer := 256;     -- number of colors

    constant MATCH_THRESHOLD : integer := 50; -- random value for the moment

    ---------------------------------------------------------------------------------
    -- Types
    ---------------------------------------------------------------------------------

    subtype pixel_t is std_logic_vector(PXL_SIZE - 1 downto 0);
    type image_t is array (0 to IMG_HEIGHT - 1, 0 to IMG_WIDTH - 1) of pixel_t;

    subtype lbp_value_t is unsigned(PXL_SIZE - 1 downto 0);
    type lbp_image_t is array (0 to IMG_HEIGHT - 1, 0 to IMG_WIDTH - 1) of lbp_value_t;

    subtype hist_bin_t is unsigned(15 downto 0);            -- 16-bit
    type histogram_t is array (0 to LBP_BINS - 1) of hist_bin_t;
    type grid_histogram_t is array (0 to GRID_LEN_Y - 1, 0 to GRID_LEN_X - 1) of histogram_t;

    subtype distance_t is unsigned(39 downto 0);            -- 40-bit (max of the sum)

    ---------------------------------------------------------------------------------
    -- Components
    ---------------------------------------------------------------------------------

    -- ...

    ---------------------------------------------------------------------------------
    -- Functions
    ---------------------------------------------------------------------------------

    function compute_lbp_value(image : image_t; x, y : integer) return lbp_value_t;
    function squared_diff(bin1, bin2 : hist_bin_t) return distance_t;
    
    function get_grid_x(x : integer) return integer;
    function get_grid_y(y : integer) return integer;

    ---------------------------------------------------------------------------------
    -- Procedures
    ---------------------------------------------------------------------------------

    -- ...


end lbph_pkg;


package body lbph_pkg is

    ---------------------------------------------------------------------------------
    -- Functions
    ---------------------------------------------------------------------------------
    
    function compute_lbp_value(image : image_t; x, y : integer) return lbp_value_t is
    
        variable lbp_value : lbp_value_t := (others => '0');
        variable center    : pixel_t;
    begin
        
        center := image(y, x);
    
        lbp_value(7) := '1' when image(y - 1, x - 1) >= center else '0';
        lbp_value(6) := '1' when image(y - 1, x    ) >= center else '0';
        lbp_value(5) := '1' when image(y - 1, x + 1) >= center else '0';
        lbp_value(4) := '1' when image(y    , x + 1) >= center else '0';
        lbp_value(3) := '1' when image(y + 1, x + 1) >= center else '0';
        lbp_value(2) := '1' when image(y + 1, x    ) >= center else '0';
        lbp_value(1) := '1' when image(y + 1, x - 1) >= center else '0';
        lbp_value(0) := '1' when image(y    , x - 1) >= center else '0';
    
        return lbp_value;
    end function;


    function squared_diff(bin1, bin2 : hist_bin_t) return distance_t is
    
        variable diff     : signed(16 downto 0);
        variable square   : signed(39 downto 0);
        variable distance : distance_t := (others => '0');
    begin
    
        diff := signed(resize(bin1, 17)) - signed(resize(bin2, 17));
        square := resize(diff * diff, 40);
        distance := unsigned(square);
        
        return distance;
    end function;


    function get_grid_x(x : integer) return integer is
    begin
    
        if x < GRID_WIDTH * 1 then
            return 0;
        elsif x < GRID_WIDTH * 2 then
            return 1;
        elsif x < GRID_WIDTH * 3 then
            return 2;
        elsif x < GRID_WIDTH * 4 then
            return 3;
        elsif x < GRID_WIDTH * 5 then
            return 4;
        elsif x < GRID_WIDTH * 6 then
            return 5;
        elsif x < GRID_WIDTH * 7 then
            return 6;
        else
            return 7;
        end if;
    
    end function;
    
    
    function get_grid_y(y : integer) return integer is
    begin
    
        if y < GRID_HEIGHT * 1 then
            return 0;
        elsif y < GRID_HEIGHT * 2 then
            return 1;
        elsif y < GRID_HEIGHT * 3 then
            return 2;
        elsif y < GRID_HEIGHT * 4 then
            return 3;
        elsif y < GRID_HEIGHT * 5 then
            return 4;
        elsif y < GRID_HEIGHT * 6 then
            return 5;
        elsif y < GRID_HEIGHT * 7 then
            return 6;
        else
            return 7;
        end if;
        
    end function;

    ---------------------------------------------------------------------------------
    -- Procedures
    ---------------------------------------------------------------------------------

    -- ...

end package body;

