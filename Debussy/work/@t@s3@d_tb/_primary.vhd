library verilog;
use verilog.vl_types.all;
entity TS3D_tb is
    generic(
        PSUM_WIDTH      : integer := 23
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of PSUM_WIDTH : constant is 1;
end TS3D_tb;
