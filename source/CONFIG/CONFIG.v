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
`include "../include/dw_params_presim.vh"
module  CONFIG (
    input                                              clk     ,
    input                                              rst_n   ,
    output reg [ `C_LOG_2(`LENROW)           - 1 : 0 ] CFG_LenRow, // +1 is real value
    output reg [ `BLK_WIDTH                  - 1 : 0 ] CFG_DepBlk,
    output reg [ `BLK_WIDTH                  - 1 : 0 ] CFG_NumBlk,
    output reg [ `FRAME_WIDTH                - 1 : 0 ] CFG_NumFrm,
    output reg [ `PATCH_WIDTH                - 1 : 0 ] CFG_NumPat,
    output reg [ `LAYER_WIDTH                - 1 : 0 ] CFG_NumLay                      
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
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        CFG_LenRow <= 16;
        CFG_DepBlk <= 32;
        CFG_NumBlk <= 2;
        CFG_NumFrm <= 8;
        CFG_NumPat <= 1;
        CFG_NumLay <= 8;
    // end else if (  ) begin
    //      <= ;
    end
end





//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================


endmodule