//======================================================
// Copyright (C) 2019 By zhoucc
// All Rights Reserved
//======================================================
// Module : CNVROW
// Author : CC zhou
// Contact :
// Date : 3 .1 .2019
//=======================================================
// Description :
//========================================================
`include "../include/dw_params_presim.vh"

module CNVROW #(
    parameter ADDR_GET =(`LENROW - 1)
     ) (
    input                                       clk     ,
    input                                       rst_n   ,
    input                                       PECMAC_Sta      ,
    input                                       PECCNV_PlsAcc ,//All CNV finish
    input                                       PECCNV_FnhRow, //All CNV finish a Row
    output                                      MACPEC_Fnh0,
    output                                      MACPEC_Fnh1,
    output                                      MACPEC_Fnh2,
    input [ `BLOCK_DEPTH                -1 : 0] PECMAC_FlgAct,
    input [ `DATA_WIDTH * `BLOCK_DEPTH  -1 : 0] PECMAC_Act,
    input [ `BLOCK_DEPTH                -1 : 0] PECMAC_FlgWei0,
    input [ `BLOCK_DEPTH                -1 : 0] PECMAC_FlgWei1,
    input [ `BLOCK_DEPTH                -1 : 0] PECMAC_FlgWei2,
    input [ `DATA_WIDTH * `BLOCK_DEPTH  -1 : 0] PECMAC_Wei0,
    input [ `DATA_WIDTH * `BLOCK_DEPTH  -1 : 0] PECMAC_Wei1,
    input [ `DATA_WIDTH * `BLOCK_DEPTH  -1 : 0] PECMAC_Wei2,
    input [  `PSUM_WIDTH       -1 : 0] CNVIN_Psum,
    output  [  `PSUM_WIDTH  -1 : 0] CNVOUT_Psum
);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================




//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================
reg [ `C_LOG_2( `LENROW)                       -1 : 0] Addr;
wire [ `DATA_WIDTH * 2 + `C_LOG_2(`BLOCK_DEPTH*3)   -1 : 0] MACCNV_Mac_0;
wire [ `DATA_WIDTH * 2 + `C_LOG_2(`BLOCK_DEPTH*3)   -1 : 0] MACCNV_Mac0;
wire [ `DATA_WIDTH * 2 + `C_LOG_2(`BLOCK_DEPTH*3)   -1 : 0] MACCNV_Mac1;
wire [ `DATA_WIDTH * 2 + `C_LOG_2(`BLOCK_DEPTH*3)   -1 : 0] MACCNV_Mac2;

reg [ `PSUM_WIDTH * `LENROW      - 1 : 0 ] CNVOUT_Psum_Array;

//=====================================================================================================================
// Logic Design :
//=====================================================================================================================
assign         CNVOUT_Psum  = CNVOUT_Psum_Array[ `PSUM_WIDTH * ADDR_GET +: `PSUM_WIDTH];
always @ ( posedge clk or negedge rst_n ) begin
     if ( ~rst_n ) begin
        CNVOUT_Psum_Array  <= 0;
     end else if ( PECCNV_PlsAcc ) begin
        CNVOUT_Psum_Array <= { CNVOUT_Psum_Array, MACCNV_Mac2 + CNVIN_Psum};// shift
     end
 end
/*
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        Addr <= `LENROW - 1; // correspond to real feature map position
    end else if ( PECCNV_FnhRow ) begin
        Addr <= `LENROW - 1;
    end else if ( PECCNV_PlsAcc ) begin
        Addr <= Addr - 1;
    end
end
*/


//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================

assign MACCNV_Mac_0 = 0;
MACAW MACAW0
    (
        .clk           (clk),
        .rst_n         (rst_n),
        .PECMAC_Sta    (PECMAC_Sta),
        .MACPEC_Fnh    (MACPEC_Fnh0),
        .PECMAC_FlgAct (PECMAC_FlgAct),
        .PECMAC_Act    (PECMAC_Act),
        .PECMAC_FlgWei (PECMAC_FlgWei0),
        .PECMAC_Wei    (PECMAC_Wei0),
        // .PECMAC_AddrBaseWei( PECMAC_AddrBaseWei0 ),
        .MACMAC_Mac    (MACCNV_Mac_0),
        .MACCNV_Mac    (MACCNV_Mac0)
    );

MACAW MACAW1
    (
        .clk           (clk),
        .rst_n         (rst_n),
        .PECMAC_Sta    (PECMAC_Sta),
        .MACPEC_Fnh    (MACPEC_Fnh1),
        .PECMAC_FlgAct (PECMAC_FlgAct),
        .PECMAC_Act    (PECMAC_Act),
        .PECMAC_FlgWei (PECMAC_FlgWei1),
        .PECMAC_Wei    (PECMAC_Wei1),
        // .PECMAC_AddrBaseWei( PECMAC_AddrBaseWei1 ),
        .MACMAC_Mac    ( MACCNV_Mac0),
        .MACCNV_Mac    (MACCNV_Mac1)
    );
MACAW MACAW2
    (
        .clk           (clk),
        .rst_n         (rst_n),
        .PECMAC_Sta    (PECMAC_Sta),
        .MACPEC_Fnh    (MACPEC_Fnh2),
        .PECMAC_FlgAct (PECMAC_FlgAct),
        .PECMAC_Act    (PECMAC_Act),
        .PECMAC_FlgWei (PECMAC_FlgWei2),
        .PECMAC_Wei    (PECMAC_Wei2),
        // .PECMAC_AddrBaseWei( PECMAC_AddrBaseWei2 ),
        .MACMAC_Mac    ( MACCNV_Mac1),
        .MACCNV_Mac    (MACCNV_Mac2)
    );

endmodule
