library verilog;
use verilog.vl_types.all;
entity vram_display is
    port(
        reset           : in     vl_logic;
        clk             : in     vl_logic;
        hcount          : in     vl_logic_vector(10 downto 0);
        vcount          : in     vl_logic_vector(9 downto 0);
        vr_pixel        : out    vl_logic_vector(17 downto 0);
        vram_addr       : out    vl_logic_vector(18 downto 0);
        vram_read_data  : in     vl_logic_vector(35 downto 0)
    );
end vram_display;
