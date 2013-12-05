library verilog;
use verilog.vl_types.all;
entity ntsc_to_zbt is
    generic(
        COL_START       : integer := 30;
        ROW_START       : integer := 30
    );
    port(
        clk             : in     vl_logic;
        vclk            : in     vl_logic;
        fvh             : in     vl_logic_vector(2 downto 0);
        dataValid       : in     vl_logic;
        dataIn          : in     vl_logic_vector(18 downto 0);
        ntsc_addr       : out    vl_logic_vector(18 downto 0);
        ntsc_data       : out    vl_logic_vector(35 downto 0);
        ntsc_we         : out    vl_logic;
        switch          : in     vl_logic;
        frameNumber     : out    vl_logic
    );
end ntsc_to_zbt;
