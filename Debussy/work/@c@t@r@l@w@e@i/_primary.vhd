library verilog;
use verilog.vl_types.all;
entity CTRLWEI is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        TOP_Sta         : in     vl_logic;
        CTRLWEIPEC_RdyWei: out    vl_logic_vector(5 downto 0);
        PECCTRLWEI_GetWei: in     vl_logic_vector(5 downto 0);
        DISWEI_RdyWei   : in     vl_logic;
        CTRLWEI_PlsFetch: out    vl_logic
    );
end CTRLWEI;
