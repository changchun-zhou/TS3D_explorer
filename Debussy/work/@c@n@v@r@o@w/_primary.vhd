library verilog;
use verilog.vl_types.all;
entity CNVROW is
    generic(
        PSUM_WIDTH      : integer := 23
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        PECMAC_Sta      : in     vl_logic;
        PECCNV_PlsAcc   : in     vl_logic;
        PECCNV_FnhRow   : in     vl_logic;
        MACPEC_Fnh0     : out    vl_logic;
        MACPEC_Fnh1     : out    vl_logic;
        MACPEC_Fnh2     : out    vl_logic;
        PECMAC_FlgAct   : in     vl_logic_vector(31 downto 0);
        PECMAC_Act      : in     vl_logic_vector(255 downto 0);
        PECMAC_FlgWei0  : in     vl_logic_vector(31 downto 0);
        PECMAC_FlgWei1  : in     vl_logic_vector(31 downto 0);
        PECMAC_FlgWei2  : in     vl_logic_vector(31 downto 0);
        PECMAC_Wei0     : in     vl_logic_vector(255 downto 0);
        PECMAC_Wei1     : in     vl_logic_vector(255 downto 0);
        PECMAC_Wei2     : in     vl_logic_vector(255 downto 0);
        CNVIN_Psum      : in     vl_logic_vector;
        CNVOUT_Psum     : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of PSUM_WIDTH : constant is 1;
end CNVROW;
