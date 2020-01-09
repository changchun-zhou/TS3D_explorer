library verilog;
use verilog.vl_types.all;
entity FLGOFFSET is
    generic(
        DATA_WIDTH      : integer := 32;
        ADDR_WIDTH      : integer := 5
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        Act             : in     vl_logic_vector;
        Wei             : in     vl_logic_vector;
        ValFlg          : in     vl_logic;
        OffsetAct       : out    vl_logic_vector;
        OffsetWei       : out    vl_logic_vector;
        SetOut          : out    vl_logic_vector;
        ValOffset       : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of ADDR_WIDTH : constant is 1;
end FLGOFFSET;
