library verilog;
use verilog.vl_types.all;
entity PEL is
    generic(
        PSUM_WIDTH      : integer := 23
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        POOLPEB_EnRd    : in     vl_logic_vector(0 downto 0);
        POOLPEB_AddrRd  : in     vl_logic_vector(3 downto 0);
        PELPOOL_Dat     : out    vl_logic_vector;
        CTRLACT_FrtBlk  : in     vl_logic;
        CTRLACT_FrtActRow: in     vl_logic;
        CTRLACT_LstActRow: in     vl_logic;
        CTRLACT_LstActBlk: in     vl_logic;
        CTRLPEB_FnhFrm  : in     vl_logic;
        CTRLACT_RdyAct  : in     vl_logic;
        CTRLACT_GetAct  : in     vl_logic;
        CTRLACT_FlgAct  : in     vl_logic_vector(31 downto 0);
        CTRLACT_Act     : in     vl_logic_vector(255 downto 0);
        CTRLWEIPEC_RdyWei: in     vl_logic_vector(5 downto 0);
        PECCTRLWEI_GetWei: out    vl_logic_vector(5 downto 0);
        DISWEIPEC_Wei   : in     vl_logic_vector(2303 downto 0);
        DISWEIPEC_FlgWei: in     vl_logic_vector(287 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of PSUM_WIDTH : constant is 1;
end PEL;
