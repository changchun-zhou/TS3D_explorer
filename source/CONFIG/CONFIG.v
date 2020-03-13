//======================================================
// Copyright (C) 2019 By zhoucc
// All Rights Reserved
//======================================================
// Module : CONFIG
// Author : CC zhou
// Contact :
// Date :   8 . 1 .2019
//=======================================================
// Description :
//========================================================
`include "../source/include/dw_params_presim.vh"
module  CONFIG (
    input                                              clk     ,
    input                                              rst_n   ,
    input                                               Rst_Layer,
    input                                               IFCFG_Val,
    input [`PORT_DATAWIDTH          -1 : 0 ] IFCFG,
    output [ `C_LOG_2(`LENROW)           - 1 : 0 ] CFG_LenRow, // +1 is real value
    output [ `BLK_WIDTH                  - 1 : 0 ] CFG_DepBlk,
    output [ `BLK_WIDTH                  - 1 : 0 ] CFG_NumBlk,
    output [ `FRAME_WIDTH                - 1 : 0 ] CFG_NumFrm,
    output [ `PATCH_WIDTH                - 1 : 0 ] CFG_NumPat,
    output [ `LAYER_WIDTH                - 1 : 0 ] CFG_NumLay,
    output [ 5 + 1+`POOL_KERNEL_WIDTH                -1 : 0] CFG_POOL
);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================





//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================
wire  [ `PORT_DATAWIDTH          - 1 : 0 ] fifo_out;




//=====================================================================================================================
// Logic Design :
//=====================================================================================================================

assign {CFG_LenRow,CFG_DepBlk,CFG_NumBlk,CFG_NumFrm,CFG_NumPat,CFG_NumLay,CFG_POOL} = fifo_out;




//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================
fifo_asic #(
    .DATA_WIDTH(`PORT_DATAWIDTH ),
    .ADDR_WIDTH(`NUM_CFG_WIDTH )
    ) fifo_CONFIG(
    .clk ( clk ),
    .rst_n ( rst_n ),
    .push(IFCFG_Val) ,
    .pop(Rst_Layer ) ,
    .data_in( IFCFG),
    .data_out (fifo_out ),
    .empty( ),
    .full ( )
    );

endmodule
