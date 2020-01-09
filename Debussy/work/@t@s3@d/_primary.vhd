library verilog;
use verilog.vl_types.all;
entity TS3D is
    generic(
        PSUM_WIDTH      : integer := 23
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        POOLPEB_EnRd    : in     vl_logic_vector(15 downto 0);
        POOLPEB_AddrRd  : in     vl_logic_vector(3 downto 0);
        PEBPOOL_Dat     : out    vl_logic_vector;
        GBFWEI_Val      : in     vl_logic;
        GBFWEI_EnWr     : in     vl_logic;
        GBFWEI_AddrWr   : in     vl_logic_vector(1 downto 0);
        GBFWEI_DatWr    : in     vl_logic_vector(71 downto 0);
        GBFFLGWEI_Val   : in     vl_logic;
        GBFFLGWEI_EnWr  : in     vl_logic;
        GBFFLGWEI_AddrWr: in     vl_logic_vector(1 downto 0);
        GBFFLGWEI_DatWr : in     vl_logic_vector(287 downto 0);
        GBFACT_Val      : in     vl_logic;
        GBFACT_EnWr     : in     vl_logic;
        GBFACT_AddrWr   : in     vl_logic_vector(2 downto 0);
        GBFACT_DatWr    : in     vl_logic_vector(7 downto 0);
        GBFFLGACT_Val   : in     vl_logic;
        GBFFLGACT_EnWr  : in     vl_logic;
        GBFFLGACT_AddrWr: in     vl_logic_vector(2 downto 0);
        GBFFLGACT_DatWr : in     vl_logic_vector(31 downto 0);
        GBFVNACT_Val    : in     vl_logic;
        GBFVNACT_EnWr   : in     vl_logic;
        GBFVNACT_AddrWr : in     vl_logic_vector(2 downto 0);
        GBFVNACT_DatWr  : in     vl_logic_vector(4 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of PSUM_WIDTH : constant is 1;
end TS3D;
