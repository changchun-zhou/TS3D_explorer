library verilog;
use verilog.vl_types.all;
entity CTRLACT is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        TOP_Sta         : in     vl_logic;
        CFG_LenRow      : in     vl_logic_vector(3 downto 0);
        CFG_DepBlk      : in     vl_logic_vector(31 downto 0);
        CFG_NumBlk      : in     vl_logic_vector(31 downto 0);
        CFG_NumFrm      : in     vl_logic_vector(4 downto 0);
        CFG_NumPat      : in     vl_logic_vector(7 downto 0);
        CFG_NumLay      : in     vl_logic_vector(7 downto 0);
        CTRLACT_PlsFetch: out    vl_logic;
        CTRLACT_GetAct  : in     vl_logic;
        CTRLACT_FrtActRow: out    vl_logic;
        CTRLACT_LstActRow: out    vl_logic;
        CTRLACT_LstActBlk: out    vl_logic;
        CTRLACT_ValPsum : out    vl_logic;
        CTRLACT_FrtBlk  : out    vl_logic;
        CTRLACT_FnhFrm  : out    vl_logic
    );
end CTRLACT;
