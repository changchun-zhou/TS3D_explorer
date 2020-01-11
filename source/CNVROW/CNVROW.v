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
    parameter PSUM_WIDTH = (`DATA_WIDTH *2 + `C_LOG_2(`CHANNEL_DEPTH) + 2 )
 
) (
    input                   clk     ,
    input                   rst_n   ,
    input                   PECMAC_Sta      ,
    input                   PECCNV_PlsAcc ,//All CNV finish
    input                   PECCNV_FnhRow, //All CNV finish a Row

    input                   MACPEC_Fnh0,
    input                   MACPEC_Fnh1,
    input                   MACPEC_Fnh2,

    input [ `CHANNEL_DEPTH              - 1 : 0 ] PECMAC_FlgAct,
    input [ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ] PECMAC_Act,
    input [ `CHANNEL_DEPTH              - 1 : 0 ] PECMAC_FlgWei0,
    input [ `CHANNEL_DEPTH              - 1 : 0 ] PECMAC_FlgWei1,
    input [ `CHANNEL_DEPTH              - 1 : 0 ] PECMAC_FlgWei2,

    input [ `DATA_WIDTH * `BLOCK_DEPTH * `KERNEL_SIZE- 1 : 0 ] PECMAC_Wei,
    // input [ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ] PECMAC_Wei1,
    // input [ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ] PECMAC_Wei2,

    input [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE) - 1 : 0 ] PECMAC_AddrBaseWei0,
    input [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE) - 1 : 0 ] PECMAC_AddrBaseWei1,
    input [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE) - 1 : 0 ] PECMAC_AddrBaseWei2,

    input [  PSUM_WIDTH * `LENPSUM       - 1 : 0 ] CNVIN_Psum,
    output reg [  PSUM_WIDTH * `LENPSUM       - 1 : 0 ] CNVOUT_Psum                         
);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================




//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================
reg [ `C_LOG_2(PSUM_WIDTH * `LENPSUM)   - 1 : 0 ] Addr;

wire [ `DATA_WIDTH + `C_LOG_2(`CHANNEL_DEPTH*3)- 1 : 0 ] MACCNV_Mac0;
wire [ `DATA_WIDTH + `C_LOG_2(`CHANNEL_DEPTH*3)- 1 : 0 ] MACCNV_Mac1;
wire [ `DATA_WIDTH + `C_LOG_2(`CHANNEL_DEPTH*3)- 1 : 0 ] MACCNV_Mac2;



//=====================================================================================================================
// Logic Design :
//=====================================================================================================================

always @ ( posedge clk or negedge rst_n ) begin
     if ( ~rst_n ) begin
        CNVOUT_Psum  <= 0;
     end else if ( PECCNV_PlsAcc ) begin
        CNVOUT_Psum  <= MACCNV_Mac2 + CNVIN_Psum[ PSUM_WIDTH*Addr +: PSUM_WIDTH ];
     end
 end 

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        Addr <= 0;
    end else if ( PECCNV_FnhRow ) begin
        Addr <= 0;
    end else if ( PECCNV_PlsAcc ) begin
        Addr <= Addr + 1;
    end
end

// always @ ( posedge clk or negedge rst_n ) begin
//     if ( ~rst_n ) begin
//          <= ;
//     end else if (  ) begin
//          <= ;
//     end
// end

//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================


MACAW MACAW0
    (
        .clk           (clk),
        .rst_n         (rst_n),
        .PECMAC_Sta    (PECMAC_Sta),
        .MACPEC_Fnh    (MACPEC_Fnh0),
        .PECMAC_FlgAct (PECMAC_FlgAct),
        .PECMAC_Act    (PECMAC_Act),
        .PECMAC_FlgWei (PECMAC_FlgWei0),
        .PECMAC_Wei    (PECMAC_Wei),
        .PECMAC_AddrBaseWei( PECMAC_AddrBaseWei0 ),
        .MACMAC_Mac    ( 15'd0),
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
        .PECMAC_Wei    (PECMAC_Wei),
        .PECMAC_AddrBaseWei( PECMAC_AddrBaseWei1 ),
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
        .PECMAC_Wei    (PECMAC_Wei),
        .PECMAC_AddrBaseWei( PECMAC_AddrBaseWei2 ),
        .MACMAC_Mac    ( MACCNV_Mac1),
        .MACCNV_Mac    (MACCNV_Mac2)
    );

endmodule