//======================================================
// Copyright (C) 2019 By zhoucc
// All Rights Reserved
//======================================================
// Module : CTRLACT
// Author : CC zhou
// Contact : 
// Date :   6 . 1 .2019
//=======================================================
// Description :
//========================================================
`include "../include/dw_params_presim.vh"
module  CTRLACT (
    input                                       clk     ,
    input                                       rst_n   ,
    input                                       TOP_Sta,
    
    input [ `C_LOG_2(`LENROW)           - 1 : 0 ] CFG_LenRow, // +1 is real value
    input [ `BLK_WIDTH                  - 1 : 0 ] CFG_DepBlk,
    input [ `BLK_WIDTH                  - 1 : 0 ] CFG_NumBlk,
    input [ `FRAME_WIDTH                - 1 : 0 ] CFG_NumFrm,
    input [ `PATCH_WIDTH                - 1 : 0 ] CFG_NumPat,
    input [ `LAYER_WIDTH                - 1 : 0 ] CFG_NumLay,
    output                                       CTRLACT_PlsFetch,
    input                                        CTRLACT_GetAct,
    output                                       CTRLACT_FrtActRow,
    output                                       CTRLACT_LstActRow,
    output                                       CTRLACT_LstActBlk,

    // output                                       CTRLACT_FnhPat,
    // output                                       CTRLACT_FnhIfm,
    output                                       CTRLACT_FnhFrm

);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================





//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================
reg  [ `C_LOG_2(`LENROW)           - 1 : 0 ] CntAct;
reg  [ `C_LOG_2(`LENROW)           - 1 : 0 ] CntRow;
wire                                                CTRLACT_FrtActBlk;
wire                                                CTRLACT_FrtActFrm;
reg                                                 CTRLACT_FrtActFrm_d;
reg  [ `BLK_WIDTH                  - 1 : 0 ] CntBlk;
reg  [ `FRAME_WIDTH                - 1 : 0 ] CntFrm;
reg  [ `PATCH_WIDTH                - 1 : 0 ] CntPat;
reg  [ `LAYER_WIDTH                - 1 : 0 ] CntLay;
wire                                         FrtActPat;
wire                                         FrtActFrm;

wire                                         FrtActLay;
wire                                         Restart = 0; ////////////////////////////////
//=====================================================================================================================
// Logic Design :
//=====================================================================================================================



// For loop

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CntAct <= 0;
    end else if ( CTRLACT_LstActRow ) begin
        CntAct <= 0;
    end else if( CTRLACT_PlsFetch) begin
        CntAct <= CntAct + 1;
    end
end

// always @ ( posedge clk or negedge rst_n ) begin
//     if ( ~rst_n ) begin
//         CTRLACT_PlsFetch <= 0;
//     end else if ( TOP_Sta || CTRLACT_GetAct ) begin
//          <= ;
//     end
// end

assign CTRLACT_PlsFetch = TOP_Sta || ( CTRLACT_GetAct && 1'b1);//////////////////

assign CTRLACT_LstActRow = CntAct == CFG_LenRow;
assign CTRLACT_FrtActRow = CntAct == 0;

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CntRow <= 0;
    end else if ( CTRLACT_FrtActBlk ) begin
        CntRow <= 0;
    end else if ( CTRLACT_FrtActRow ) begin
        CntRow <= CntRow + 1;
    end
end

assign CTRLACT_FrtActBlk = CntRow == 0 && CTRLACT_FrtActRow;
assign CTRLACT_LstActBlk = CntRow == CFG_LenRow && CTRLACT_FrtActRow;

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CntBlk <= 0;
    end else if ( CTRLACT_FrtActFrm  ) begin
        CntBlk <= 0;
    end else if ( CTRLACT_FrtActBlk ) begin
        CntBlk <= CntBlk + 1;
    end
end

assign CTRLACT_FrtActFrm = CntBlk == 0 && CTRLACT_FrtActBlk;

// paulse to exchange Pingpong SRAM_PEC2/3
assign CTRLACT_FnhFrm = CTRLACT_FrtActFrm && ~CTRLACT_FrtActFrm_d;  

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CntFrm <= 0;
    end else if ( FrtActPat ) begin
        CntFrm <= 0;
    end else if ( CTRLACT_FrtActFrm ) begin
        CntFrm <= CntFrm + 1;
    end
end

assign FrtActPat = CntFrm == 0 && CTRLACT_FrtActFrm;

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CntPat <= 0;
    end else if ( FrtActLay ) begin
        CntPat <= 0; 
    end else if( FrtActPat ) begin
        CntPat <= CntPat + 1;
    end
end

assign FrtActLay = CntPat == 0 && FrtActPat;

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CntLay <= 0;
    end else if ( Restart ) begin
        CntLay <= 0;
    end else if ( FrtActLay ) begin
        CntLay <= CntLay + 1;
    end
end
// assign FrtActEx =



//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================


endmodule