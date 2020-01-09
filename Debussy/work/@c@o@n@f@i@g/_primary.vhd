library verilog;
use verilog.vl_types.all;
entity CONFIG is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        CFG_LenRow      : out    vl_logic_vector(3 downto 0);
        CFG_DepBlk      : out    vl_logic_vector(31 downto 0);
        CFG_NumBlk      : out    vl_logic_vector(31 downto 0);
        CFG_NumFrm      : out    vl_logic_vector(4 downto 0);
        CFG_NumPat      : out    vl_logic_vector(7 downto 0);
        CFG_NumLay      : out    vl_logic_vector(7 downto 0)
    );
end CONFIG;
