library verilog;
use verilog.vl_types.all;
entity PEC is
    generic(
        PSUM_WIDTH      : integer := 23
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        CTRLWEIPEC_RdyWei: in     vl_logic;
        PECCTRLWEI_GetWei: out    vl_logic;
        DISWEIPEC_Wei   : in     vl_logic_vector(2303 downto 0);
        DISWEIPEC_FlgWei: in     vl_logic_vector(287 downto 0);
        LSTPEC_FrtActRow: in     vl_logic;
        LSTPEC_LstActRow: in     vl_logic;
        LSTPEC_LstActBlk: in     vl_logic;
        NXTPEC_FrtActRow: out    vl_logic;
        NXTPEC_LstActRow: out    vl_logic;
        NXTPEC_LstActBlk: out    vl_logic;
        LSTPEC_RdyAct   : in     vl_logic;
        LSTPEC_GetAct   : out    vl_logic;
        PEBPEC_FlgAct   : in     vl_logic_vector(31 downto 0);
        PEBPEC_Act      : in     vl_logic_vector(255 downto 0);
        NXTPEC_RdyAct   : out    vl_logic;
        NXTPEC_GetAct   : in     vl_logic;
        PECMAC_FlgAct   : out    vl_logic_vector(31 downto 0);
        PECMAC_Act      : out    vl_logic_vector(255 downto 0);
        PECRAM_EnWr     : out    vl_logic;
        PECRAM_AddrWr   : out    vl_logic_vector(3 downto 0);
        PECRAM_DatWr    : out    vl_logic_vector;
        PECRAM_EnRd     : out    vl_logic;
        PECRAM_AddrRd   : out    vl_logic_vector(3 downto 0);
        RAMPEC_DatRd    : in     vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of PSUM_WIDTH : constant is 1;
end PEC;
