//======================================================
// Copyright (C) 2019 By zhoucc
// All Rights Reserved
//======================================================
// Module : PEC
// Author : CC zhou
// Contact : 
// Date : 4 .1 .2019
//=======================================================
// Description :
//========================================================
`include "../include/dw_params_presim.vh"
module PEC #(
    parameter PSUM_WIDTH = (`DATA_WIDTH *2 + `C_LOG_2(`BLOCK_DEPTH) + 2 )
    )(
    input                                                       clk     ,
    input                                                       rst_n   ,
    input                                                       CTRLWEIPEC_RdyWei  ,
    output                                                      PECCTRLWEI_GetWei  ,//=CTRLWEIPEC_RdyWei paulse
    input [ `DATA_WIDTH * `BLOCK_DEPTH * `KERNEL_SIZE   -1 : 0] DISWEIPEC_Wei,
    input [ 1 * `BLOCK_DEPTH * `KERNEL_SIZE             -1 : 0] DISWEIPEC_FlgWei,
    // input [ `C_LOG_2( `BLOCK_DEPTH) * `KERNEL_SIZE      -1 : 0] DISWEIPEC_ValNumWei,
    // input [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE)      -1 : 0] DISWEI_AddrBase,
    input                                                       LSTPEC_FrtActRow   ,// because read and write simultaneously
    input                                                       LSTPEC_LstActRow   ,//
    input                                                       LSTPEC_LstActBlk   ,//
    output reg                                                  NXTPEC_FrtActRow   ,
    output reg                                                  NXTPEC_LstActRow   ,
    output reg                                                  NXTPEC_LstActBlk   ,
    // output                  PEC_FnhBlk,
    input                                                       LSTPEC_RdyAct,// level
    output                                                      LSTPEC_GetAct,// PAULSE
    input [ `BLOCK_DEPTH                                -1 : 0] PEBPEC_FlgAct,
    input [ `DATA_WIDTH * `BLOCK_DEPTH                  -1 : 0] PEBPEC_Act,
    output                                                      NXTPEC_RdyAct,// To Next PEC: THIS PEC's ACT is NOT ever gotten
    input                                                       NXTPEC_GetAct,// THIS PEC's ACT is gotten
    output reg [ `BLOCK_DEPTH                           -1 : 0] PECMAC_FlgAct,
    output reg [ `DATA_WIDTH * `BLOCK_DEPTH             -1 : 0] PECMAC_Act,

    output                                                      PECRAM_EnWr,
    output reg [ `C_LOG_2(`LENPSUM)                     -1 : 0] PECRAM_AddrWr,
    output [  PSUM_WIDTH * `LENPSUM                     -1 : 0] PECRAM_DatWr,
    output                                                      PECRAM_EnRd,
    output reg [ `C_LOG_2(`LENPSUM)                     -1 : 0] PECRAM_AddrRd,
    input  [ PSUM_WIDTH * `LENPSUM                      -1 : 0] RAMPEC_DatRd 

);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================






//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================
wire                                CfgMac;
wire                                CfgWei;
reg                                 CfgWei_d;

wire                                MACPEC_Fnh0;
wire                                MACPEC_Fnh1;
wire                                MACPEC_Fnh2;
wire                                MACPEC_Fnh3;
wire                                MACPEC_Fnh4;
wire                                MACPEC_Fnh5;
wire                                MACPEC_Fnh6;
wire                                MACPEC_Fnh7;
wire                                MACPEC_Fnh8;


reg                                         PECMAC_Sta;

wire                                PECCNV_PlsAcc;// level
reg                                 PECCNV_PlsAcc_d;// level
wire                                PlsFnhAll;
wire                                FnhRow;
wire                                StaRow;
wire                                FnhBlk;
wire                                PECCNV_FnhRow;

wire [  PSUM_WIDTH * `LENPSUM       - 1 : 0 ] PECCNV_Psum;
wire [  PSUM_WIDTH * `LENPSUM       - 1 : 0 ] CNVOUT_Psum0;
wire [  PSUM_WIDTH * `LENPSUM       - 1 : 0 ] CNVOUT_Psum1;
wire [  PSUM_WIDTH * `LENPSUM       - 1 : 0 ] CNVOUT_Psum2;

reg  [ `DATA_WIDTH * `BLOCK_DEPTH * `KERNEL_SIZE- 1 : 0 ] WeiArray;
reg  [ 1 * `BLOCK_DEPTH * `KERNEL_SIZE- 1 : 0 ] FlgWei;
reg  [ `C_LOG_2( `BLOCK_DEPTH) * `KERNEL_SIZE   - 1 : 0 ] ValNumWei;
wire [ `C_LOG_2( `BLOCK_DEPTH)                  - 1 : 0 ] ValNumWei0;
wire [ `C_LOG_2( `BLOCK_DEPTH)                  - 1 : 0 ] ValNumWei1;
wire [ `C_LOG_2( `BLOCK_DEPTH)                  - 1 : 0 ] ValNumWei2;
wire [ `C_LOG_2( `BLOCK_DEPTH)                  - 1 : 0 ] ValNumWei3;
wire [ `C_LOG_2( `BLOCK_DEPTH)                  - 1 : 0 ] ValNumWei4;
wire [ `C_LOG_2( `BLOCK_DEPTH)                  - 1 : 0 ] ValNumWei5;
wire [ `C_LOG_2( `BLOCK_DEPTH)                  - 1 : 0 ] ValNumWei6;
wire [ `C_LOG_2( `BLOCK_DEPTH)                  - 1 : 0 ] ValNumWei7;
// reg  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE) - 1 : 0 ] PECMAC_AddrBaseWei0;
// reg  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE) - 1 : 0 ] PECMAC_AddrBaseWei1;
// reg  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE) - 1 : 0 ] PECMAC_AddrBaseWei2;
// reg  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE) - 1 : 0 ] PECMAC_AddrBaseWei3;
// reg  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE) - 1 : 0 ] PECMAC_AddrBaseWei4;
// reg  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE) - 1 : 0 ] PECMAC_AddrBaseWei5;
// reg  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE) - 1 : 0 ] PECMAC_AddrBaseWei6;
// reg  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE) - 1 : 0 ] PECMAC_AddrBaseWei7;
// reg  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE) - 1 : 0 ] PECMAC_AddrBaseWei8;

wire [ 1 * `BLOCK_DEPTH                         - 1 : 0 ] PECMAC_FlgWei0;
wire [ 1 * `BLOCK_DEPTH                         - 1 : 0 ] PECMAC_FlgWei1;
wire [ 1 * `BLOCK_DEPTH                         - 1 : 0 ] PECMAC_FlgWei2;
wire [ 1 * `BLOCK_DEPTH                         - 1 : 0 ] PECMAC_FlgWei3;
wire [ 1 * `BLOCK_DEPTH                         - 1 : 0 ] PECMAC_FlgWei4;
wire [ 1 * `BLOCK_DEPTH                         - 1 : 0 ] PECMAC_FlgWei5;
wire [ 1 * `BLOCK_DEPTH                         - 1 : 0 ] PECMAC_FlgWei6;
wire [ 1 * `BLOCK_DEPTH                         - 1 : 0 ] PECMAC_FlgWei7;
wire [ 1 * `BLOCK_DEPTH                         - 1 : 0 ] PECMAC_FlgWei8;

reg  [ `DATA_WIDTH * `BLOCK_DEPTH               -1 : 0] PECMAC_Wei0;
reg  [ `DATA_WIDTH * `BLOCK_DEPTH               -1 : 0] PECMAC_Wei1;
reg  [ `DATA_WIDTH * `BLOCK_DEPTH               -1 : 0] PECMAC_Wei2;
reg  [ `DATA_WIDTH * `BLOCK_DEPTH               -1 : 0] PECMAC_Wei3;
reg  [ `DATA_WIDTH * `BLOCK_DEPTH               -1 : 0] PECMAC_Wei4;
reg  [ `DATA_WIDTH * `BLOCK_DEPTH               -1 : 0] PECMAC_Wei5;
reg  [ `DATA_WIDTH * `BLOCK_DEPTH               -1 : 0] PECMAC_Wei6;
reg  [ `DATA_WIDTH * `BLOCK_DEPTH               -1 : 0] PECMAC_Wei7;
reg  [ `DATA_WIDTH * `BLOCK_DEPTH               -1 : 0] PECMAC_Wei8;
//=====================================================================================================================
// Logic Design :
//=====================================================================================================================
// FSM : ACT is ever gotten or not
localparam IDLE     = 2'b00;
localparam CFGWEI   = 2'b01;
localparam CFGACT   = 2'b11;
localparam WAITGET  = 2'b10;


reg [ 2 - 1 : 0  ] next_state;
reg [ 2 - 1 : 0  ] state;

always @(*) begin
    case (state)
      IDLE  :   if ( 1'b1 )
                    next_state <= CFGWEI;
                else 
                    next_state <= IDLE;  // avoid Latch
      CFGWEI:   if ( CTRLWEIPEC_RdyWei )
                    next_state <= CFGACT;
                else 
                    next_state <= CFGWEI;
      CFGACT:   if( LSTPEC_RdyAct && PECCNV_PlsAcc)
                    next_state <= WAITGET;
                else 
                    next_state <= CFGACT;
      WAITGET  :if( FnhBlk )
                    next_state <= IDLE;// wait config new weights
                else if( NXTPEC_GetAct )
                    next_state <= CFGACT;
                else 
                    next_state <= WAITGET;

      default: next_state <= IDLE;
    endcase
end

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

assign CfgMac = next_state == WAITGET && state == CFGACT;

assign CfgWei = next_state == CFGACT && state == CFGWEI;
assign PECCTRLWEI_GetWei = next_state == CFGACT && state == CFGWEI;//==CTRLWEIPEC_RdyWei

// finished in DISWEI
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        WeiArray          <= 0;
        FlgWei              <= 0;
        // ValNumWei           <= 0;
        // PECMAC_AddrBaseWei0 <= 0;
        // PECMAC_AddrBaseWei1 <= 0;
        // PECMAC_AddrBaseWei2 <= 0;
        // PECMAC_AddrBaseWei3 <= 0;
        // PECMAC_AddrBaseWei4 <= 0;
        // PECMAC_AddrBaseWei5 <= 0;
        // PECMAC_AddrBaseWei6 <= 0;
        // PECMAC_AddrBaseWei7 <= 0;
        // PECMAC_AddrBaseWei8 <= 0;
    end else if ( CfgWei ) begin
        // WeiArray          <= DISWEIPEC_Wei;
        PECMAC_Wei0 <= DISWEIPEC_Wei[ `DATA_WIDTH * `BLOCK_DEPTH * 0 +: `DATA_WIDTH * `BLOCK_DEPTH];
        PECMAC_Wei1 <= DISWEIPEC_Wei[ `DATA_WIDTH * `BLOCK_DEPTH * 1 +: `DATA_WIDTH * `BLOCK_DEPTH];
        PECMAC_Wei2 <= DISWEIPEC_Wei[ `DATA_WIDTH * `BLOCK_DEPTH * 2 +: `DATA_WIDTH * `BLOCK_DEPTH];
        PECMAC_Wei3 <= DISWEIPEC_Wei[ `DATA_WIDTH * `BLOCK_DEPTH * 3 +: `DATA_WIDTH * `BLOCK_DEPTH];
        PECMAC_Wei4 <= DISWEIPEC_Wei[ `DATA_WIDTH * `BLOCK_DEPTH * 4 +: `DATA_WIDTH * `BLOCK_DEPTH];
        PECMAC_Wei5 <= DISWEIPEC_Wei[ `DATA_WIDTH * `BLOCK_DEPTH * 5 +: `DATA_WIDTH * `BLOCK_DEPTH];
        PECMAC_Wei6 <= DISWEIPEC_Wei[ `DATA_WIDTH * `BLOCK_DEPTH * 6 +: `DATA_WIDTH * `BLOCK_DEPTH];
        PECMAC_Wei7 <= DISWEIPEC_Wei[ `DATA_WIDTH * `BLOCK_DEPTH * 7 +: `DATA_WIDTH * `BLOCK_DEPTH];
        PECMAC_Wei8 <= DISWEIPEC_Wei[ `DATA_WIDTH * `BLOCK_DEPTH * 8 +: `DATA_WIDTH * `BLOCK_DEPTH];
        FlgWei              <= DISWEIPEC_FlgWei;
        // ValNumWei           <= DISWEIPEC_ValNumWei;
        // PECMAC_AddrBaseWei0 <= DISWEI_AddrBase;//
        // PECMAC_AddrBaseWei1 <= DISWEI_AddrBase + ValNumWei0;
        // PECMAC_AddrBaseWei2 <= DISWEI_AddrBase + ValNumWei0 + ValNumWei1;
        // PECMAC_AddrBaseWei3 <= DISWEI_AddrBase + ValNumWei0 + ValNumWei1 + ValNumWei2;
        // PECMAC_AddrBaseWei4 <= DISWEI_AddrBase + ValNumWei0 + ValNumWei1 + ValNumWei2 + ValNumWei3;
        // PECMAC_AddrBaseWei5 <= DISWEI_AddrBase + ValNumWei0 + ValNumWei1 + ValNumWei2 + ValNumWei3 + ValNumWei4;
        // PECMAC_AddrBaseWei6 <= DISWEI_AddrBase + ValNumWei0 + ValNumWei1 + ValNumWei2 + ValNumWei3 + ValNumWei4 + ValNumWei5;
        // PECMAC_AddrBaseWei7 <= DISWEI_AddrBase + ValNumWei0 + ValNumWei1 + ValNumWei2 + ValNumWei3 + ValNumWei4 + ValNumWei5 + ValNumWei6;
        // PECMAC_AddrBaseWei8 <= DISWEI_AddrBase + ValNumWei0 + ValNumWei1 + ValNumWei2 + ValNumWei3 + ValNumWei4 + ValNumWei5 + ValNumWei6 + ValNumWei7;
    end 
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        CfgWei_d <= 0;
    end else begin
        CfgWei_d <= CfgWei;
    end
end
// always @ ( posedge clk or negedge rst_n ) begin
//     if ( !rst_n ) begin
//         PECMAC_Wei0 <= 0;
//         PECMAC_Wei1 <= 0;
//         PECMAC_Wei2 <= 0;
//         PECMAC_Wei3 <= 0;
//         PECMAC_Wei4 <= 0;
//         PECMAC_Wei5 <= 0;
//         PECMAC_Wei6 <= 0;
//         PECMAC_Wei7 <= 0;
//         PECMAC_Wei8 <= 0;
//     end else if (CfgWei_d)   begin
//         PECMAC_Wei0 <= WeiArray[ `DATA_WIDTH * PECMAC_AddrBaseWei0 +: `DATA_WIDTH * `BLOCK_DEPTH];
//         PECMAC_Wei1 <= WeiArray[ `DATA_WIDTH * PECMAC_AddrBaseWei1 +: `DATA_WIDTH * `BLOCK_DEPTH];
//         PECMAC_Wei2 <= WeiArray[ `DATA_WIDTH * PECMAC_AddrBaseWei2 +: `DATA_WIDTH * `BLOCK_DEPTH];
//         PECMAC_Wei3 <= WeiArray[ `DATA_WIDTH * PECMAC_AddrBaseWei3 +: `DATA_WIDTH * `BLOCK_DEPTH];
//         PECMAC_Wei4 <= WeiArray[ `DATA_WIDTH * PECMAC_AddrBaseWei4 +: `DATA_WIDTH * `BLOCK_DEPTH];
//         PECMAC_Wei5 <= WeiArray[ `DATA_WIDTH * PECMAC_AddrBaseWei5 +: `DATA_WIDTH * `BLOCK_DEPTH];
//         PECMAC_Wei6 <= WeiArray[ `DATA_WIDTH * PECMAC_AddrBaseWei6 +: `DATA_WIDTH * `BLOCK_DEPTH];
//         PECMAC_Wei7 <= WeiArray[ `DATA_WIDTH * PECMAC_AddrBaseWei7 +: `DATA_WIDTH * `BLOCK_DEPTH];
//         PECMAC_Wei8 <= WeiArray[ `DATA_WIDTH * PECMAC_AddrBaseWei8 +: `DATA_WIDTH * `BLOCK_DEPTH];
//     end
// end

assign PECMAC_FlgWei0 = FlgWei[ `BLOCK_DEPTH * 0 +: `BLOCK_DEPTH];
assign PECMAC_FlgWei1 = FlgWei[ `BLOCK_DEPTH * 1 +: `BLOCK_DEPTH];
assign PECMAC_FlgWei2 = FlgWei[ `BLOCK_DEPTH * 2 +: `BLOCK_DEPTH];
assign PECMAC_FlgWei3 = FlgWei[ `BLOCK_DEPTH * 3 +: `BLOCK_DEPTH];
assign PECMAC_FlgWei4 = FlgWei[ `BLOCK_DEPTH * 4 +: `BLOCK_DEPTH];
assign PECMAC_FlgWei5 = FlgWei[ `BLOCK_DEPTH * 5 +: `BLOCK_DEPTH];
assign PECMAC_FlgWei6 = FlgWei[ `BLOCK_DEPTH * 6 +: `BLOCK_DEPTH];
assign PECMAC_FlgWei7 = FlgWei[ `BLOCK_DEPTH * 7 +: `BLOCK_DEPTH];
assign PECMAC_FlgWei8 = FlgWei[ `BLOCK_DEPTH * 8 +: `BLOCK_DEPTH];

// assign ValNumWei0 = DISWEIPEC_ValNumWei[`C_LOG_2( `BLOCK_DEPTH) * 0 +: `C_LOG_2( `BLOCK_DEPTH)];
// assign ValNumWei1 = DISWEIPEC_ValNumWei[`C_LOG_2( `BLOCK_DEPTH) * 1 +: `C_LOG_2( `BLOCK_DEPTH)];
// assign ValNumWei2 = DISWEIPEC_ValNumWei[`C_LOG_2( `BLOCK_DEPTH) * 2 +: `C_LOG_2( `BLOCK_DEPTH)];
// assign ValNumWei3 = DISWEIPEC_ValNumWei[`C_LOG_2( `BLOCK_DEPTH) * 3 +: `C_LOG_2( `BLOCK_DEPTH)];
// assign ValNumWei4 = DISWEIPEC_ValNumWei[`C_LOG_2( `BLOCK_DEPTH) * 4 +: `C_LOG_2( `BLOCK_DEPTH)];
// assign ValNumWei5 = DISWEIPEC_ValNumWei[`C_LOG_2( `BLOCK_DEPTH) * 5 +: `C_LOG_2( `BLOCK_DEPTH)];
// assign ValNumWei6 = DISWEIPEC_ValNumWei[`C_LOG_2( `BLOCK_DEPTH) * 6 +: `C_LOG_2( `BLOCK_DEPTH)];
// assign ValNumWei7 = DISWEIPEC_ValNumWei[`C_LOG_2( `BLOCK_DEPTH) * 7 +: `C_LOG_2( `BLOCK_DEPTH)];




// output Rdy/ Get
assign NXTPEC_RdyAct = state == WAITGET;
assign LSTPEC_GetAct = CfgMac;

// Connect CNV && MAC
// update ACT and Start
// Level
assign PECCNV_PlsAcc =   MACPEC_Fnh6 && MACPEC_Fnh7 && MACPEC_Fnh8
                      && MACPEC_Fnh3 && MACPEC_Fnh4 && MACPEC_Fnh5
                      && MACPEC_Fnh0 && MACPEC_Fnh1 && MACPEC_Fnh2 ;


always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        PECCNV_PlsAcc_d <= 0;
    end else begin
        PECCNV_PlsAcc_d <= PECCNV_PlsAcc;
    end
end
assign PlsFnhAll = PECCNV_PlsAcc && ~PECCNV_PlsAcc_d;
assign StaRow = LSTPEC_FrtActRow && PlsFnhAll;
assign FnhRow = LSTPEC_LstActRow && PlsFnhAll;
assign FnhBlk = LSTPEC_LstActBlk && PlsFnhAll;

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        PECMAC_FlgAct <= 0;
        PECMAC_Act    <= 0;
        NXTPEC_FrtActRow <= 0;
        NXTPEC_LstActBlk <= 0;
        NXTPEC_LstActRow <= 0;
    end else if ( CfgMac ) begin
        PECMAC_FlgAct <= PEBPEC_FlgAct;
        PECMAC_Act    <= PEBPEC_Act;
        NXTPEC_FrtActRow <= LSTPEC_FrtActRow;
        NXTPEC_LstActBlk <= LSTPEC_LstActBlk;
        NXTPEC_LstActRow <= LSTPEC_LstActRow;
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        PECMAC_Sta <= 0;
    end else begin
        PECMAC_Sta <= CfgMac;//paulse
    end
end
assign PECCNV_FnhRow = FnhRow;


// Read SRAM
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        PECRAM_AddrRd <= 0;
    end else if ( FnhBlk ) begin
        PECRAM_AddrRd <= 0;
    end else if ( StaRow ) begin
        PECRAM_AddrRd <= PECRAM_AddrRd + 1;
    end
end
assign PECRAM_EnRd = StaRow ;
assign PECCNV_Psum = RAMPEC_DatRd ;

// Write SRAM
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        PECRAM_AddrWr <= 0;
    end else if ( FnhBlk ) begin
        PECRAM_AddrWr <= 0;        
    end else if ( FnhRow ) begin
        PECRAM_AddrWr <= PECRAM_AddrWr + 1;
    end
end
assign PECRAM_DatWr = CNVOUT_Psum2;
assign PECRAM_EnWr  = FnhRow;



//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================

CNVROW CNVROW0 (
        .clk            (clk),
        .rst_n          (rst_n),
        .PECMAC_Sta     (PECMAC_Sta),
        .PECCNV_PlsAcc  (PECCNV_PlsAcc),// WAITGETute Psum
        .PECCNV_FnhRow  (PECCNV_FnhRow),
        .MACPEC_Fnh0    (MACPEC_Fnh6),
        .MACPEC_Fnh1    (MACPEC_Fnh7),
        .MACPEC_Fnh2    (MACPEC_Fnh8),
        .PECMAC_FlgAct  (PECMAC_FlgAct),
        .PECMAC_Act     (PECMAC_Act),
        .PECMAC_FlgWei0 (PECMAC_FlgWei6),
        .PECMAC_FlgWei1 (PECMAC_FlgWei7),
        .PECMAC_FlgWei2 (PECMAC_FlgWei8),
        .PECMAC_Wei0     (PECMAC_Wei6),
        .PECMAC_Wei1    (PECMAC_Wei7),
        .PECMAC_Wei2    (PECMAC_Wei8),
        // .PECMAC_AddrBaseWei0(0),
        // .PECMAC_AddrBaseWei1(0),
        // .PECMAC_AddrBaseWei2(0),
        .CNVIN_Psum     (PECCNV_Psum),
        .CNVOUT_Psum    (CNVOUT_Psum0)
    );

CNVROW CNVROW1 (
        .clk            (clk),
        .rst_n          (rst_n),
        .PECMAC_Sta     (PECMAC_Sta),
        .PECCNV_PlsAcc  (PECCNV_PlsAcc),// WAITGETute Psum
        .PECCNV_FnhRow  (PECCNV_FnhRow),
        .MACPEC_Fnh0    (MACPEC_Fnh3),
        .MACPEC_Fnh1    (MACPEC_Fnh4),
        .MACPEC_Fnh2    (MACPEC_Fnh5),
        .PECMAC_FlgAct  (PECMAC_FlgAct),
        .PECMAC_Act     (PECMAC_Act),
        .PECMAC_FlgWei0 (PECMAC_FlgWei3),
        .PECMAC_FlgWei1 (PECMAC_FlgWei4),
        .PECMAC_FlgWei2 (PECMAC_FlgWei5),
        .PECMAC_Wei0     (PECMAC_Wei3),
        .PECMAC_Wei1    (PECMAC_Wei4),
        .PECMAC_Wei2    (PECMAC_Wei5),
        // .PECMAC_AddrBaseWei0(0),
        // .PECMAC_AddrBaseWei1(0),
        // .PECMAC_AddrBaseWei2(0),
        .CNVIN_Psum     (CNVOUT_Psum0),
        .CNVOUT_Psum    (CNVOUT_Psum1)
    );

CNVROW CNVROW2 (
        .clk            (clk),
        .rst_n          (rst_n),
        .PECMAC_Sta     (PECMAC_Sta),
        .PECCNV_PlsAcc  (PECCNV_PlsAcc),// WAITGETute Psum
        .PECCNV_FnhRow  (PECCNV_FnhRow),
        .MACPEC_Fnh0    (MACPEC_Fnh0),
        .MACPEC_Fnh1    (MACPEC_Fnh1),
        .MACPEC_Fnh2    (MACPEC_Fnh2),
        .PECMAC_FlgAct  (PECMAC_FlgAct),
        .PECMAC_Act     (PECMAC_Act),
        .PECMAC_FlgWei0 (PECMAC_FlgWei0),
        .PECMAC_FlgWei1 (PECMAC_FlgWei1),
        .PECMAC_FlgWei2 (PECMAC_FlgWei2),
        .PECMAC_Wei0    (PECMAC_Wei0),
        .PECMAC_Wei1    (PECMAC_Wei1),
        .PECMAC_Wei2    (PECMAC_Wei2),
        // .PECMAC_AddrBaseWei0(0),
        // .PECMAC_AddrBaseWei1(0),
        // .PECMAC_AddrBaseWei2(0),
        .CNVIN_Psum     (CNVOUT_Psum1),
        .CNVOUT_Psum    (CNVOUT_Psum2)
    );


endmodule