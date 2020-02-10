library verilog;
use verilog.vl_types.all;
entity PEB is
    generic(
        PSUM_WIDTH      : integer := 23
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        CTRLPEB_FrtBlk  : in     vl_logic;
        CTRLPEB_FnhFrm  : in     vl_logic;
        NXTPEB_FrtBlk   : out    vl_logic;
        POOLPEB_EnRd    : in     vl_logic;
        POOLPEB_AddrRd  : in     vl_logic_vector(3 downto 0);
        PEBPOOL_Dat     : out    vl_logic_vector;
        CTRLWEIPEC_RdyWei0: in     vl_logic;
        CTRLWEIPEC_RdyWei1: in     vl_logic;
        CTRLWEIPEC_RdyWei2: in     vl_logic;
        PECCTRLWEI_GetWei0: out    vl_logic;
        PECCTRLWEI_GetWei1: out    vl_logic;
        PECCTRLWEI_GetWei2: out    vl_logic;
        DISWEIPEC_Wei   : in     vl_logic_vector(2303 downto 0);
        DISWEIPEC_FlgWei: in     vl_logic_vector(287 downto 0);
        LSTPEC_FrtActRow0: in     vl_logic;
        LSTPEC_LstActRow0: in     vl_logic;
        LSTPEC_LstActBlk0: in     vl_logic;
        LSTPEC_ValPsum0 : in     vl_logic;
        NXTPEC_FrtActRow2: out    vl_logic;
        NXTPEC_LstActRow2: out    vl_logic;
        NXTPEC_LstActBlk2: out    vl_logic;
        NXTPEC_ValPsum2 : out    vl_logic;
        LSTPEB_RdyAct   : in     vl_logic;
        LSTPEB_GetAct   : out    vl_logic;
        LSTPEB_FlgAct   : in     vl_logic_vector(31 downto 0);
        LSTPEB_Act      : in     vl_logic_vector(255 downto 0);
        NXTPEB_RdyAct   : out    vl_logic;
        NXTPEB_GetAct   : in     vl_logic;
        NXTPEB_FlgAct   : out    vl_logic_vector(31 downto 0);
        NXTPEB_Act      : in     vl_logic_vector(255 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of PSUM_WIDTH : constant is 1;
end PEB;
