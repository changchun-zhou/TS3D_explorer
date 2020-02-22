//======================================================
// Copyright (C) 2019 By zhoucc
// All Rights Reserved
//======================================================
// Module : POOL
// Author : CC zhou
// Contact : 
// Date : 3 .2 .2019
//=======================================================
// Description :
//========================================================
module POOL(
    input                   clk     ,
    input                   rst_n   ,
    input [ 1+`POOL_KERNEL_WIDTH -1 : 0]                  CFG_POOL      ,
 //   input 						PEBPOOL_ValRow,
    output  [ 1			        -1 : 0] POOLPEL_EnRd,// 4 bit ID of PEB
    output  [ `C_LOG_2(`LENPSUM * `LENPSUM)         -1 : 0] POOLPEL_AddrRd,
    input [ PSUM_WIDTH * `BLOCK_DEPTH      -1 : 0] PELPOOL_Dat,
               
);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================





//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================





//=====================================================================================================================
// Logic Design :
//=====================================================================================================================
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		POOLPEB_EnRd <= 0;
	end else if( PEBPOOL_ValRow && pool_write_ready) begin
		POOLPEB_EnRd <= 1;
 	end
end



//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================
// ==================================================================

  assign pool_write_req =  POOLPEB_EnRd  ;
  assign pool_write_data = lrn_enable_local ? norm_out : pe_write_data;
  assign pool_read_ready = 1'b1;
  pooling #(
    // INPUT PARAMETERS
    .OP_WIDTH                 ( `DATA_WIDTH                 ),
    .NUM_PE                   ( `LENPSUM                   )
  ) pool_DUT (
    // PORTS
    .clk                      ( clk                      ),
    .reset                    ( !rst_n                    ),
    .ready                    (                          ),//output
    .cfg                      ( CFG_POOL               ),
    .ctrl                     ( pool_ctrl_d              ),
    .read_data                ( pool_read_data           ),//output
    .read_req                 ( pool_read_req            ),//
    .read_ready               ( pool_read_ready          ),//output
    .write_data               ( PELPOOL_Dat          ),
    .write_req                ( pool_write_req           ),push
    .write_ready              ( pool_write_ready         )//output  not full
  );
// ==================================================================


endmodule