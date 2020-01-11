module TS3D_tb;
parameter PSUM_WIDTH = (`DATA_WIDTH *2 + `C_LOG_2(`CHANNEL_DEPTH) + 2 );

// TS3D Inputs
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;
reg   [ `NUMPEB                    -1 : 0]  POOLPEB_EnRd = 0 ;
reg   [ `C_LOG_2(`LENPSUM)         -1 : 0]  POOLPEB_AddrRd = 0 ;
reg   GBFWEI_Val                           = 1 ;
reg   GBFWEI_EnWr                          = 0 ;
reg   [ `GBFWEI_ADDRWIDTH           -1 : 0]  GBFWEI_AddrWr = 0 ;
reg   [ `GBFWEI_DATAWIDTH           -1 : 0]  GBFWEI_DatWr = 0 ;
reg   GBFFLGWEI_Val                        = 1 ;
reg   GBFFLGWEI_EnWr                       = 0 ;
reg   [ `GBFWEI_ADDRWIDTH           -1 : 0]  GBFFLGWEI_AddrWr = 0 ;
reg   [ `GBFFLGWEI_DATAWIDTH        -1 : 0]  GBFFLGWEI_DatWr = 0 ;
reg   GBFACT_Val                           = 1 ;
reg   GBFACT_EnWr                          = 0 ;
reg   [ `GBFACT_ADDRWIDTH          -1 : 0]  GBFACT_AddrWr = 0 ;
reg   [ `DATA_WIDTH                -1 : 0]  GBFACT_DatWr = 0 ;
reg   GBFFLGACT_Val                        = 1 ;
reg   GBFFLGACT_EnWr                       = 0 ;
reg   [ `GBFACT_ADDRWIDTH          -1 : 0]  GBFFLGACT_AddrWr = 0 ;
reg   [ `BLOCK_DEPTH               -1 : 0]  GBFFLGACT_DatWr = 0 ;
reg   GBFVNACT_Val                         = 1 ;
reg   GBFVNACT_EnWr                        = 0 ;
reg   [ `GBFACT_ADDRWIDTH          -1 : 0]  GBFVNACT_AddrWr = 0 ;
reg   [ `C_LOG_2(`BLOCK_DEPTH)     -1 : 0]  GBFVNACT_DatWr = 0 ;

// TS3D Outputs
wire  [ PSUM_WIDTH * `LENPSUM      -1 : 0]  PELPOOL_Dat ;

// TS3D Bidirs



// initial
// begin
//     //$shm_open ("db_name", is_sequence_time, db_size, is_compression, incsize,incfiles);
//     $shm_open ("dump.shm");
//     $shm_probe( "AC");
// end

initial begin
/*    $fsdbDumpfile("TS3D_tb.fsdb");
    $fsdbDumpvars();
    $dumpfile("TS3D_tb.vcd");
    $dumpvars;*/
    repeat(8000) @(posedge clk);
    $finish;
end

initial
begin
    clk= 1;
    forever #5  clk=~clk;
end

initial
begin
    rst_n  =  1;
    #25  rst_n  =  0;
    #100 rst_n  =  1;
end

TS3D  u_TS3D (
    .clk                     ( clk                                                     ),
    .rst_n                   ( rst_n                                                   ),
    .POOLPEB_EnRd            ( POOLPEB_EnRd      [ `NUMPEB                    -1 : 0]  ),
    .POOLPEB_AddrRd          ( POOLPEB_AddrRd    [ `C_LOG_2(`LENPSUM)         -1 : 0]  ),
    .GBFWEI_Val              ( GBFWEI_Val                                              ),
    .GBFWEI_EnWr             ( GBFWEI_EnWr                                             ),
    .GBFWEI_AddrWr           ( GBFWEI_AddrWr     [ `GBFWEI_ADDRWIDTH           -1 : 0] ),
    .GBFWEI_DatWr            ( GBFWEI_DatWr      [ `GBFWEI_DATAWIDTH           -1 : 0] ),
    .GBFFLGWEI_Val           ( GBFFLGWEI_Val                                           ),
    .GBFFLGWEI_EnWr          ( GBFFLGWEI_EnWr                                          ),
    .GBFFLGWEI_AddrWr        ( GBFFLGWEI_AddrWr  [ `GBFWEI_ADDRWIDTH           -1 : 0] ),
    .GBFFLGWEI_DatWr         ( GBFFLGWEI_DatWr   [ `GBFFLGWEI_DATAWIDTH        -1 : 0] ),
    .GBFACT_Val              ( GBFACT_Val                                              ),
    .GBFACT_EnWr             ( GBFACT_EnWr                                             ),
    .GBFACT_AddrWr           ( GBFACT_AddrWr     [ `GBFACT_ADDRWIDTH          -1 : 0]  ),
    .GBFACT_DatWr            ( GBFACT_DatWr      [ `DATA_WIDTH                -1 : 0]  ),
    .GBFFLGACT_Val           ( GBFFLGACT_Val                                           ),
    .GBFFLGACT_EnWr          ( GBFFLGACT_EnWr                                          ),
    .GBFFLGACT_AddrWr        ( GBFFLGACT_AddrWr  [ `GBFACT_ADDRWIDTH          -1 : 0]  ),
    .GBFFLGACT_DatWr         ( GBFFLGACT_DatWr   [ `BLOCK_DEPTH               -1 : 0]  ),
    .GBFVNACT_Val            ( GBFVNACT_Val                                            ),
    .GBFVNACT_EnWr           ( GBFVNACT_EnWr                                           ),
    .GBFVNACT_AddrWr         ( GBFVNACT_AddrWr   [ `GBFACT_ADDRWIDTH          -1 : 0]  ),
    .GBFVNACT_DatWr          ( GBFVNACT_DatWr    [ `C_LOG_2(`BLOCK_DEPTH)     -1 : 0]  ),

    .PELPOOL_Dat             ( PELPOOL_Dat       [ PSUM_WIDTH * `LENPSUM      -1 : 0]  )
);
endmodule
