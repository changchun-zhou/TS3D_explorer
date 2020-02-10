library verilog;
use verilog.vl_types.all;
entity DISWEI is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        CTRLWEI_PlsFetch: in     vl_logic;
        DISWEI_RdyWei   : out    vl_logic;
        DISWEIPEC_Wei   : out    vl_logic_vector(2303 downto 0);
        DISWEIPEC_FlgWei: out    vl_logic_vector(287 downto 0);
        GBFWEI_Val      : in     vl_logic;
        GBFWEI_EnRd     : out    vl_logic;
        GBFWEI_AddrRd   : out    vl_logic_vector(5 downto 0);
        GBFWEI_DatRd    : in     vl_logic_vector(71 downto 0);
        GBFFLGWEI_Val   : in     vl_logic;
        GBFFLGWEI_EnRd  : out    vl_logic;
        GBFFLGWEI_AddrRd: out    vl_logic_vector(5 downto 0);
        GBFFLGWEI_DatRd : in     vl_logic_vector(287 downto 0)
    );
end DISWEI;
