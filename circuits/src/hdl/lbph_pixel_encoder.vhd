library lbph;
use lbph.lbph_pkg.all;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;


entity lbph_pixel_encoder is

    port (
        p0_i, p1_i, p2_i, p3_i, p4_i, p5_i, p6_i, p7_i, p8_i : in pixel_t;
        lbp_o                                                : out lbp_value_t
    );

end lbph_pixel_encoder;


architecture Behavioral of lbph_pixel_encoder is

    -- none
    
begin
    
    ---------------------------------------------------------------------------------
    -- COMBINATORY
    ---------------------------------------------------------------------------------

    lbp_o(7) <= '1' when p0_i >= p4_i else '0';
    lbp_o(6) <= '1' when p1_i >= p4_i else '0';
    lbp_o(5) <= '1' when p2_i >= p4_i else '0';
    lbp_o(4) <= '1' when p3_i >= p4_i else '0';
    lbp_o(3) <= '1' when p5_i >= p4_i else '0';
    lbp_o(2) <= '1' when p6_i >= p4_i else '0';
    lbp_o(1) <= '1' when p7_i >= p4_i else '0';
    lbp_o(0) <= '1' when p8_i >= p4_i else '0';

end Behavioral;
