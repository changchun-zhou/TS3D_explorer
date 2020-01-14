library verilog;
use verilog.vl_types.all;
entity MACAW is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        PECMAC_Sta      : in     vl_logic;
        MACPEC_Fnh      : out    vl_logic;
        PECMAC_FlgAct   : in     vl_logic_vector(31 downto 0);
        PECMAC_Act      : in     vl_logic_vector(255 downto 0);
        PECMAC_FlgWei   : in     vl_logic_vector(31 downto 0);
        PECMAC_Wei      : in     vl_logic_vector(255 downto 0);
        MACMAC_Mac      : in     vl_logic_vector(14 downto 0);
        MACCNV_Mac      : out    vl_logic_vector(14 downto 0)
    );
end MACAW;
