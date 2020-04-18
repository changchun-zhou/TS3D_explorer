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
`include "../source/include/dw_params_presim.vh"
module  CTRLACT (
    input                                       clk     ,
    input                                       rst_n   ,
    input                                       Sta,// Restart ACT
    input [ 6                            -1 : 0 ] CFG_LoopPty,
    input [ `C_LOG_2(`LENROW)           - 1 : 0 ] CFG_LenRow, // +1 is real value
    input [ `BLK_WIDTH                  - 1 : 0 ] CFG_DepBlk,// +1 is real value
    input [ `BLK_WIDTH                  - 1 : 0 ] CFG_NumBlk,
    input [ `FRAME_WIDTH                - 1 : 0 ] CFG_NumFrm,
    input [ `PATCH_WIDTH                - 1 : 0 ] CFG_NumPat,
    input [ `FTRGRP_WIDTH             - 1 : 0 ] CFG_NumFtrGrp,
    input [ `LAYER_WIDTH                - 1 : 0 ] CFG_NumLay,
    output                                       CTRLACT_PlsFetch,
    input                                        CTRLACT_GetAct,
    output                                       CTRLACT_FrtActRow,
    output                                       CTRLACT_LstActRow,
    output                                       CTRLACT_LstActBlk,
    output                                       CTRLACT_ValPsum,
    output                                      CTRLACT_ValCol,
    output                                       CTRLACT_FrtBlk, /// glitch: PEC0 -> PEC2 second BLK -> first Blk
    output                                       CTRLACT_FnhPat,
    output                                       CTRLACT_FnhFtrGrp,
    output                                       CTRLACT_FnhLay,
    output                                       CTRLACT_FnhFrm,
    output                                       CTRLACT_EvenFrm,
    output                                          POOL_En,
    output                                         POOL_ValDelta,
    output                                         POOL_ValFrm,
    output                                         Next_Patch,
    output                                          Next_FtrGrp,
    output                                          Next_Layer,
    output                                          Reset_FtrGrp,
    output                                          Reset_FtrLay,
    output                                          Reset_Patch,
    output                                          Reset_IFM,
    output                                          Reset_OFM

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
wire                                                CTRLACT_FrtFrm;

wire                                         CTRLACT_FrtActPat;
reg                                          CTRLACT_FrtActPat_d;
wire                                         CTRLACT_LstActPat;

wire                                         CTRLACT_FrtActFtrGrp;
reg                                          CTRLACT_FrtActFtrGrp_d;
wire                                        CTRLACT_LstActFtrGrp;

wire                                         CTRLACT_FrtActLay;
reg                                          CTRLACT_FrtActLay_d;
wire                                         CTRLACT_LstActLay;

reg  [ `BLK_WIDTH                  - 1 : 0 ] CntBlk;
reg  [ `FRAME_WIDTH                - 1 : 0 ] CntFrm;
reg  [ `PATCH_WIDTH                - 1 : 0 ] CntPat;
reg [ `FTRGRP_WIDTH               - 1 : 0 ] CntFtrGrp;
reg  [ `LAYER_WIDTH                - 1 : 0 ] CntLay;
reg                                         Loop;
wire                                         Restart = 0; ////////////////////////////////

parameter PATCH = 3;
parameter FTRGRP = 2;
//=====================================================================================================================
// Logic Design :
//=====================================================================================================================PEB
assign POOL_En = ~CTRLACT_FrtBlk && ~CTRLACT_FrtFrm && CTRLACT_FrtActBlk ;
assign POOL_ValDelta = CntFrm >=2; // compute 2st frame; POOL delta 1st frame
assign POOL_ValFrm = ~CntFrm[0] && CntFrm >=2 ;//
//assign POOL_ValFrm =0;
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

assign CTRLACT_PlsFetch = Sta || ( CTRLACT_GetAct && 1'b1);//////////////////
assign CTRLACT_LstActRow = CntAct == CFG_LenRow;
assign CTRLACT_FrtActRow = CntAct == 0;
assign CTRLACT_ValCol = CntAct >= 2;
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CntRow <= 0;
    end else if ( CTRLACT_LstActBlk && CTRLACT_GetAct) begin //the last data of the blk
        CntRow <= 0;
    end else if ( CTRLACT_LstActRow && CTRLACT_GetAct) begin // the last data of the row has been fetched
        CntRow <= CntRow + 1;
    end
end
assign CTRLACT_ValPsum   =  CntRow >= 2 ; // drop out first two rows; After config act10, it's waiting for writing RAM
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

assign CTRLACT_FrtBlk = ~(|CntBlk);// CntBlk == 0;
assign CTRLACT_FrtActFrm = CntBlk == 0 && CTRLACT_FrtActBlk;
assign CTRLACT_LstActFrm = CntBlk == CFG_NumBlk && CTRLACT_LstActBlk;
// paulse to exchange Pingpong SRAM_PEC2/3
assign CTRLACT_FnhFrm = CTRLACT_FrtActFrm && ~CTRLACT_FrtActFrm_d;
assign CTRLACT_EvenFrm = ~CntFrm[0];
assign CTRLACT_FrtFrm = ~(|CntFrm);
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

assign CTRLACT_FnhPat = CTRLACT_FrtActPat && ~CTRLACT_FrtActPat_d;

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CntPat <= 0;
    end else if ( CTRLACT_LstActLay && CTRLACT_GetAct ) begin
        CntPat <= 0;
    end else if( CTRLACT_LstActPat && CTRLACT_GetAct && Loop == PATCH ) begin
        CntPat <= CntPat + 1;
    end
end

assign CTRLACT_LstActFtrGrp = CntFrm == CFG_NumFrm && CTRLACT_LstActFrm;
assign CTRLACT_FrtActFtrGrp = CntFrm == 0 && CTRLACT_FrtActFrm;
assign CTRLACT_FnhFtrGrp = CTRLACT_FrtActFtrGrp && ~CTRLACT_FrtActFtrGrp_d;
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CntFtrGrp <= 0;
    end else if ( CTRLACT_LstActLay && CTRLACT_GetAct ) begin
        CntFtrGrp <= 0;
    end else if( CTRLACT_LstActFtrGrp && CTRLACT_GetAct && Loop == FTRGRP ) begin
        CntFtrGrp <= CntFtrGrp + 1;
    end
end
wire PatchLoop_First = CFG_LoopPty[5:4] > CFG_LoopPty[3:2];
wire FtrGrpLoop_First = CFG_LoopPty[5:4] < CFG_LoopPty[3:2];

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
       Loop  <= 0;
    end else if ( PatchLoop_First &&  CntPat != CFG_NumPat
                   || FtrGrpLoop_First && CntFtrGrp == CFG_NumFtrGrp  ) begin
       Loop  <= PATCH ;
    end else if (FtrGrpLoop_First && CntFtrGrp != CFG_NumFtrGrp
                    || PatchLoop_First &&  CntPat == CFG_NumPat ) begin
       Loop <= FTRGRP;
    end
end


// Paulse
assign Next_FtrGrp =  PatchLoop_First && CntPat ==  CFG_NumPat && CTRLACT_FnhPat
                                  || FtrGrpLoop_First && CTRLACT_FnhFtrGrp;
assign Next_Patch = PatchLoop_First && CTRLACT_FnhPat
                                  || FtrGrpLoop_First && CntFtrGrp == CFG_NumFtrGrp && CTRLACT_FnhFtrGrp;
assign Next_Layer = CntPat == CFG_NumPat && CntFtrGrp == CFG_NumFtrGrp && ( CTRLACT_FnhPat || CTRLACT_FnhFtrGrp );// CTRLACT_FnhFtrGrp

assign Reset_FtrGrp =  CTRLACT_FnhFrm; // Must be high when Reset_FtrLay && ~Next_FtrGrp  // Reset a Filter Group
assign Reset_FtrLay = FtrGrpLoop_First && Next_Patch;//Reset all Filter when new Patch

assign Reset_Patch = CTRLACT_FnhFtrGrp; // ** Must be high when Reset_IFM && ~Next_Patch;
assign Reset_IFM = PatchLoop_First && Next_FtrGrp ; // Reset IFM When new FilterGroup

assign Reset_OFM = 0;


assign CTRLACT_FrtActLay = CntPat == 0 && ( CTRLACT_FrtActPat||CTRLACT_FrtActFtrGrp );

// Loop Patch && finish all Filter Groups || Loop Filter Group && finish all Patches
assign CTRLACT_LstActLay = PatchLoop_First  &&  CntFtrGrp == CFG_NumFtrGrp  && CntPat == CFG_NumPat && CTRLACT_LstActPat
                                               || FtrGrpLoop_First  &&   CntPat == CFG_NumPat && CntFtrGrp == CFG_NumFtrGrp && CTRLACT_LstActFtrGrp;

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
assign CTRLACT_FnhLay = CTRLACT_FrtActLay && CTRLACT_FrtActLay_d;

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        CTRLACT_FrtActFrm_d <= 1;
    end else begin
        CTRLACT_FrtActFrm_d <= CTRLACT_FrtActFrm;
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        CTRLACT_FrtActPat_d <= 1;
    end else begin
        CTRLACT_FrtActPat_d <= CTRLACT_FrtActPat;
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        CTRLACT_FrtActFtrGrp_d <= 1;
    end else begin
        CTRLACT_FrtActFtrGrp_d <= CTRLACT_FrtActFtrGrp;
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        CTRLACT_FrtActLay_d <= 1;
    end else begin
        CTRLACT_FrtActLay_d <= CTRLACT_FrtActLay;
    end
end
//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================


endmodule
