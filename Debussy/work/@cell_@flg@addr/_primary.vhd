library verilog;
use verilog.vl_types.all;
entity Cell_FlgAddr is
    port(
        FlgAct          : in     vl_logic;
        FlgWei          : in     vl_logic;
        UpIn            : in     vl_logic;
        DownIn          : in     vl_logic;
        UpOut           : out    vl_logic;
        DownOut         : out    vl_logic;
        Set             : out    vl_logic
    );
end Cell_FlgAddr;
