`timescale  1 ns / 100 ps
`include "../source/include/dw_params_presim.vh"
module ASIC_tb();

// ASIC Inputs
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;
reg   O_spi_sck_rd0_pad                    = 0 ;
reg   O_spi_cs_n_rd0_pad                   = 0 ;
reg   OE_req_rd0_pad                       = 0 ;

// ASIC Outputs
wire  config_req_rd0_pad                   ;
wire  near_full_rd0_pad                    ;

// ASIC Bidirs
wire  [ `PORT_DATAWIDTH    -1 : 0 ]  IO_spi_data_rd0_pad ;


initial
begin
    //$shm_open ("db_name", is_sequence_time, db_size, is_compression, incsize,incfiles);
    $shm_open ("dump.shm");
    $shm_probe( "AC");
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







ASIC  ASIC (
    .clk                     ( clk                                                ),
    .rst_n                   ( rst_n                                              ),
    .O_spi_sck_rd0_pad       ( O_spi_sck_rd0_pad                                  ),
    .O_spi_cs_n_rd0_pad      ( O_spi_cs_n_rd0_pad                                 ),
    .OE_req_rd0_pad          ( OE_req_rd0_pad                                     ),
    .config_req_rd0_pad      ( config_req_rd0_pad                                 ),
    .near_full_rd0_pad       ( near_full_rd0_pad                                  ),
    .IO_spi_data_rd0_pad     ( IO_spi_data_rd0_pad  [ `PORT_DATAWIDTH    -1 : 0 ] )
);
endmodule
