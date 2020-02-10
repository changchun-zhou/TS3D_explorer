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
    input [ `BLK_WIDTH                  - 1 : 0 ] CFG_DepBlk,// +1 is real value
    input [ `BLK_WIDTH                  - 1 : 0 ] CFG_NumBlk,
    input [ `FRAME_WIDTH                - 1 : 0 ] CFG_NumFrm,
    input [ `PATCH_WIDTH                - 1 : 0 ] CFG_NumPat,
    input [ `LAYER_WIDTH                - 1 : 0 ] CFG_NumLay,
    output                                       CTRLACT_PlsFetch,
    input                                        CTRLACT_GetAct,
    output                                       CTRLACT_FrtActRow,
    output                                       CTRLACT_LstActRow,
    output                                       CTRLACT_LstActBlk,
    output                                       CTRLACT_ValPsum,
    output                                       CTRLACT_FrtBlk, /// glitch: PEC0 -> PEC2 second BLK -> first Blk
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
wire                                                CTRLACT_LstActFrm;
reg                                                 CTRLACT_FrtActFrm_d;
wire                                         CTRLACT_FrtActPat;
wire                                         CTRLACT_LstActPat;
wire                                         CTRLACT_FrtActLay;
wire                                         CTRLACT_LstActLay;
reg  [ `BLK_WIDTH                  - 1 : 0 ] CntBlk;
reg  [ `FRAME_WIDTH                - 1 : 0 ] CntFrm;
reg  [ `PATCH_WIDTH                - 1 : 0 ] CntPat;
reg  [ `LAYER_WIDTH                - 1 : 0 ] CntLay;

wire                                         Restart = 0; ////////////////////////////////
//=====================================================================================================================
// Logic Design :
//=====================================================================================================================



// For loop

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CntAct <= 0;
    end else if ( CTRLACT_LstActRow && CTRLACT_GetAct) begin
        CntAct <= 0;
    end else if( CTRLACT_GetAct) begin // pls
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

// always @ ( posedge clk or negedge rst_n ) begin
//     if ( !rst_n ) begin
//         CTRLACT_LstActRow <= 0;
//     end else if (  ) begin
//         CTRLACT_LstActRow <= ;
//     end
// end
assign CTRLACT_LstActRow = CntAct == CFG_LenRow;
assign CTRLACT_FrtActRow = CntAct == 0;

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CntRow <= 0;
    end else if ( CTRLACT_LstActBlk && CTRLACT_GetAct) begin //the last data of the blk
        CntRow <= 0;
    end else if ( CTRLACT_LstActRow && CTRLACT_GetAct) begin // the last data of the row has been fetched
        CntRow <= CntRow + 1;
    end
end
assign CTRLACT_ValPsum   = CntRow >= 2; // drop out first two rows;
assign CTRLACT_FrtActBlk = CntRow == 0 && CTRLACT_FrtActRow;
assign CTRLACT_LstActBlk = CntRow == CFG_LenRow && CTRLACT_LstActRow;

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CntBlk <= 0;
    end else if ( CTRLACT_LstActFrm && CTRLACT_GetAct ) begin
        CntBlk <= 0;
    end else if ( CTRLACT_LstActBlk && CTRLACT_GetAct ) begin
        CntBlk <= CntBlk + 1;
    end
end

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        CTRLACT_FrtActFrm_d <= 1;
    end else begin
        CTRLACT_FrtActFrm_d <= CTRLACT_FrtActFrm;
    end
end

assign CTRLACT_FrtBlk = ~(|CntBlk);// CntBlk == 0;
assign CTRLACT_FrtActFrm = CntBlk == 0 && CTRLACT_FrtActBlk;
assign CTRLACT_LstActFrm = CntBlk == CFG_NumBlk && CTRLACT_LstActBlk;
// paulse to exchange Pingpong SRAM_PEC2/3
assign CTRLACT_FnhFrm = CTRLACT_FrtActFrm && ~CTRLACT_FrtActFrm_d;  

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CntFrm <= 0;
    end else if ( CTRLACT_LstActPat && CTRLACT_GetAct) begin
        CntFrm <= 0;
    end else if ( CTRLACT_LstActFrm && CTRLACT_GetAct) begin
        CntFrm <= CntFrm + 1;
    end
end

assign CTRLACT_LstActPat = CntFrm == CFG_NumFrm && CTRLACT_LstActFrm;
assign CTRLACT_FrtActPat = CntFrm == 0 && CTRLACT_FrtActFrm;

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CntPat <= 0;
    end else if ( CTRLACT_FrtActLay && CTRLACT_GetAct ) begin
        CntPat <= 0; 
    end else if( CTRLACT_FrtActPat && CTRLACT_GetAct ) begin
        CntPat <= CntPat + 1;
    end
end

assign CTRLACT_FrtActLay = CntPat == 0 && CTRLACT_FrtActPat;
assign CTRLACT_LstActLay = CntPat == CFG_NumPat && CTRLACT_LstActPat;
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CntLay <= 0;
    end else if ( Restart ) begin
        CntLay <= 0;
    end else if ( CTRLACT_FrtActLay ) begin
        CntLay <= CntLay + 1;
    end
end
// assign FrtActEx =



//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================


endmodule