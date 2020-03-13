//======================================================
// Copyright (C) 2019 By zhoucc
// All Rights Reserved
//======================================================
// Module : ReqGBF
// Author : CC zhou
// Contact :
// Date : 3 .8 .2019
//=======================================================
// Description :
//========================================================
`include "../source/include/dw_params_presim.vh"
module ReqGBF #(
    parameter DEPTH  = 128,
    parameter CNT_WIDTH     = 4,
    parameter DEPTH_REQ = 64
) (
    input                   clk     ,
    input                   rst_n   ,
    input                   Reset,
    input   [ `C_LOG_2( DEPTH) - 1 : 0 ] AddrWr,
    input   [ `C_LOG_2( DEPTH) - 1 : 0 ] AddrRd,
    input                   EnWr,
    input                   EnRd,
    output                 Req
);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================





//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================
reg [ CNT_WIDTH - 1 : 0 ] CntWr;
reg [ CNT_WIDTH - 1 : 0 ] CntRd;




//=====================================================================================================================
// Logic Design :
//=====================================================================================================================
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        CntWr <= 0;
    end else if (Reset )begin
        CntWr <= 0;
    end else if ( (AddrWr == DEPTH -1) && EnWr ) begin // Depth of SRAM
        CntWr <= CntWr + 1;
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        CntRd <= 0;
    end else if (Reset )begin
        CntRd <= 0;
    end else if ( (AddrRd == DEPTH -1) && EnRd ) begin // Depth of SRAM
        CntRd <= CntRd + 1;
    end
end

assign Req = ( AddrWr + DEPTH * CntWr) -
            ( AddrRd + DEPTH * CntRd) <= DEPTH_REQ;// 1/2





//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================


endmodule
