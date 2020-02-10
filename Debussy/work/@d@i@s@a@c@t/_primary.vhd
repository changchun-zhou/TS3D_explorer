library verilog;
use verilog.vl_types.all;
entity DISACT is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        CTRLACT_PlsFetch: in     vl_logic;
        DISACT_RdyAct   : out    vl_logic;
        DISACT_FlgAct   : out    vl_logic_vector(31 downto 0);
        DISACT_Act      : in     vl_logic_vector(255 downto 0);
        GBFACT_Val      : in     vl_logic;
        GBFACT_EnRd     : out    vl_logic;
        GBFACT_AddrRd   : out    vl_logic_vector(9 downto 0);
        GBFACT_DatRd    : in     vl_logic_vector(7 downto 0);
        GBFFLGACT_Val   : in     vl_logic;
        GBFFLGACT_EnRd  : out    vl_logic;
        GBFFLGACT_AddrRd: out    vl_logic_vector(9 downto 0);
        GBFFLGACT_DatRd : in     vl_logic_vector(31 downto 0)
    );
end DISACT;
