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
module PEC (
    input                                                       clk     ,
    input                                                       rst_n   ,
    input                                                       CTRLWEIPEC_RdyWei  ,
    output                                                      PECCTRLWEI_GetWei  ,//=CTRLWEIPEC_RdyWei paulse
    input [ `DATA_WIDTH * `BLOCK_DEPTH * `KERNEL_SIZE   -1 : 0] DISWEIPEC_Wei,
    input [ 1 * `BLOCK_DEPTH * `KERNEL_SIZE             -1 : 0] DISWEIPEC_FlgWei,
    input [ `BUSPEC_WIDTH                                -1 : 0] INBUS_LSTPEC,
    input                                                       INBUS_NXTPEC,
    output [ `BUSPEC_WIDTH                                -1 : 0] OUTBUS_NXTPEC,
    output                                                      OUTBUS_LSTPEC,

    output                                                      PECRAM_EnWr,
    output reg [ `C_LOG_2(`LENPSUM*`LENPSUM)                     -1 : 0] PECRAM_AddrWr,
    output [  `PSUM_WIDTH                -1 : 0] PECRAM_DatWr,
    output                                                      PECRAM_EnRd,
    output reg [ `C_LOG_2(`LENPSUM*`LENPSUM)                     -1 : 0] PECRAM_AddrRd,
    input  [ `PSUM_WIDTH                   -1 : 0] RAMPEC_DatRd

);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================






//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================

    wire                                                       LSTPEC_FrtActRow   ;// because read and write simultaneously
    wire                                                       LSTPEC_LstActRow   ;//
    wire                                                       LSTPEC_LstActBlk   ;//
    wire                                                       LSTPEC_ValPsum     ;// only for write RAM valid
    wire                                                        LSTPEC_ValCol;
    reg                                                    NXTPEC_FrtActRow   ;
    reg                                                    NXTPEC_LstActRow   ;
    reg                                                    NXTPEC_LstActBlk   ;
    reg                                                    NXTPEC_ValPsum     ;
    reg                                                    NXTPEC_ValCol     ;
    wire                                                       LSTPEC_RdyAct;// level
    wire                                                       LSTPEC_GetAct;// PAULSE
    wire [ `BLOCK_DEPTH                                -1 : 0] PEBPEC_FlgAct;
    wire [ `DATA_WIDTH * `BLOCK_DEPTH                  -1 : 0] PEBPEC_Act;
    wire                                                       NXTPEC_RdyAct;// To Next PEC: THIS PEC's ACT is NOT ever gotten
    wire                                                       NXTPEC_GetAct;// THIS PEC's ACT is gotten
    reg   [ `BLOCK_DEPTH                           -1 : 0] PECMAC_FlgAct;
    reg   [ `DATA_WIDTH * `BLOCK_DEPTH             -1 : 0] PECMAC_Act;


wire                                                    CfgMac;
wire                                                    CfgWei;
reg                                                     CfgWei_d;
wire                                                    MACPEC_Fnh0;
wire                                                    MACPEC_Fnh1;
wire                                                    MACPEC_Fnh2;
wire                                                    MACPEC_Fnh3;
wire                                                    MACPEC_Fnh4;
wire                                                    MACPEC_Fnh5;
wire                                                    MACPEC_Fnh6;
wire                                                    MACPEC_Fnh7;
wire                                                    MACPEC_Fnh8;
reg                                                     PECMAC_Sta;
wire                                                    LevFnhAll;// level
reg                                                     LevFnhAll_d,LevFnhAll_dd,LevFnhAll_ddd;// level
wire                                                    PlsFnhAll;
wire                                                    FnhRow;
wire                                                    StaRow;
wire                                                    FnhBlk; // not used
wire                                                    PECCNV_FnhRow;
wire [  `PSUM_WIDTH                    -1 : 0] PECCNV_Psum;
wire [  `PSUM_WIDTH                    -1 : 0] CNVOUT_Psum0;
wire [  `PSUM_WIDTH                    -1 : 0] CNVOUT_Psum1;
wire [  `PSUM_WIDTH                    -1 : 0] CNVOUT_Psum2;
reg  [ `DATA_WIDTH * `BLOCK_DEPTH * `KERNEL_SIZE-1 : 0] WeiArray;
reg  [ 1 * `BLOCK_DEPTH * `KERNEL_SIZE          -1 : 0] FlgWei;
reg                                                     ValPsum;
reg                                                     ValCol;
reg                                                     FrtActRow;
reg                                                     LstActRow, LstActRow_d, LstActRow_dd, LstActRow_ddd;
reg                                                     LstActBlk,LstActBlk_d,LstActBlk_dd,LstActBlk_ddd;
reg  [ `C_LOG_2( `BLOCK_DEPTH) * `KERNEL_SIZE   -1 : 0] ValNumWei;
wire [ `C_LOG_2( `BLOCK_DEPTH)                  -1 : 0] ValNumWei0;
wire [ `C_LOG_2( `BLOCK_DEPTH)                  -1 : 0] ValNumWei1;
wire [ `C_LOG_2( `BLOCK_DEPTH)                  -1 : 0] ValNumWei2;
wire [ `C_LOG_2( `BLOCK_DEPTH)                  -1 : 0] ValNumWei3;
wire [ `C_LOG_2( `BLOCK_DEPTH)                  -1 : 0] ValNumWei4;
wire [ `C_LOG_2( `BLOCK_DEPTH)                  -1 : 0] ValNumWei5;
wire [ `C_LOG_2( `BLOCK_DEPTH)                  -1 : 0] ValNumWei6;
wire [ `C_LOG_2( `BLOCK_DEPTH)                  -1 : 0] ValNumWei7;
// reg  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE) - 1 : 0 ] PECMAC_AddrBaseWei0;
// reg  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE) - 1 : 0 ] PECMAC_AddrBaseWei1;
// reg  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE) - 1 : 0 ] PECMAC_AddrBaseWei2;
// reg  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE) - 1 : 0 ] PECMAC_AddrBaseWei3;
// reg  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE) - 1 : 0 ] PECMAC_AddrBaseWei4;
// reg  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE) - 1 : 0 ] PECMAC_AddrBaseWei5;
// reg  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE) - 1 : 0 ] PECMAC_AddrBaseWei6;
// reg  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE) - 1 : 0 ] PECMAC_AddrBaseWei7;
// reg  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE) - 1 : 0 ] PECMAC_AddrBaseWei8;
wire [ 1 * `BLOCK_DEPTH                         -1 : 0] PECMAC_FlgWei0;
wire [ 1 * `BLOCK_DEPTH                         -1 : 0] PECMAC_FlgWei1;
wire [ 1 * `BLOCK_DEPTH                         -1 : 0] PECMAC_FlgWei2;
wire [ 1 * `BLOCK_DEPTH                         -1 : 0] PECMAC_FlgWei3;
wire [ 1 * `BLOCK_DEPTH                         -1 : 0] PECMAC_FlgWei4;
wire [ 1 * `BLOCK_DEPTH                         -1 : 0] PECMAC_FlgWei5;
wire [ 1 * `BLOCK_DEPTH                         -1 : 0] PECMAC_FlgWei6;
wire [ 1 * `BLOCK_DEPTH                         -1 : 0] PECMAC_FlgWei7;
wire [ 1 * `BLOCK_DEPTH                         -1 : 0] PECMAC_FlgWei8;
reg  [ `DATA_WIDTH * `BLOCK_DEPTH               -1 : 0] PECMAC_Wei0;
reg  [ `DATA_WIDTH * `BLOCK_DEPTH               -1 : 0] PECMAC_Wei1;
reg  [ `DATA_WIDTH * `BLOCK_DEPTH               -1 : 0] PECMAC_Wei2;
reg  [ `DATA_WIDTH * `BLOCK_DEPTH               -1 : 0] PECMAC_Wei3;
reg  [ `DATA_WIDTH * `BLOCK_DEPTH               -1 : 0] PECMAC_Wei4;
reg  [ `DATA_WIDTH * `BLOCK_DEPTH               -1 : 0] PECMAC_Wei5;
reg  [ `DATA_WIDTH * `BLOCK_DEPTH               -1 : 0] PECMAC_Wei6;
reg  [ `DATA_WIDTH * `BLOCK_DEPTH               -1 : 0] PECMAC_Wei7;
reg  [ `DATA_WIDTH * `BLOCK_DEPTH               -1 : 0] PECMAC_Wei8;

wire                                                                              PlsFnhAll_d;
//=====================================================================================================================
// Logic Design :
//=====================================================================================================================
assign  {
LSTPEC_FrtActRow   ,
LSTPEC_LstActRow   ,
LSTPEC_LstActBlk   ,
LSTPEC_ValPsum     ,
LSTPEC_ValCol,
LSTPEC_RdyAct,
PEBPEC_FlgAct,
PEBPEC_Act}=INBUS_LSTPEC;
assign NXTPEC_GetAct = INBUS_NXTPEC;
assign OUTBUS_NXTPEC = {
NXTPEC_FrtActRow   ,
NXTPEC_LstActRow   ,
NXTPEC_LstActBlk   ,
NXTPEC_ValPsum     ,
NXTPEC_ValCol    ,
NXTPEC_RdyAct,
PECMAC_FlgAct,
PECMAC_Act
} ;
assign OUTBUS_LSTPEC = LSTPEC_GetAct;



// FSM : ACT is ever gotten or not
localparam IDLE     = 3'b000;
localparam CFGWEI   = 3'b001;
localparam CFGACT   = 3'b011;
localparam WAITGET  = 3'b010;
localparam RDRAM    = 3'b100;
localparam WRRAM    = 3'b101;

reg [ 3 - 1 : 0  ] next_state;
reg [ 3 - 1 : 0  ] state;


/////////////////////////// shortest except compute time; short 1 clk => 20% speedup /////////////////////////////////
always @(*) begin
    case (state)
      IDLE  :   if ( 1'b1 )
                    next_state <= CFGWEI;
                else
                    next_state <= IDLE;  // avoid Latch
      CFGWEI:   if ( CTRLWEIPEC_RdyWei )
                    next_state <= RDRAM;
                else
                    next_state <= CFGWEI;
      RDRAM:        next_state <= CFGACT;
      CFGACT:   if( LSTPEC_RdyAct && LevFnhAll) // || ~EnPEC
                    next_state <= WAITGET;
                else
                    next_state <= CFGACT;
      WAITGET  :if( NXTPEC_GetAct ) // make sure is gotten by NXTPEC
                    if( LstActRow )
                        next_state <= WRRAM;
                    else
                        next_state <= CFGACT;
                else
                    next_state <= WAITGET;
      WRRAM :  if( LstActBlk &&PlsFnhAll)
                    next_state <= IDLE;// wait row finish to config new weights
                else if(PlsFnhAll) //wait row finish
                    next_state <= RDRAM;
                else
                    next_state <= WRRAM;

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

assign CfgWei = next_state == RDRAM && state ==  CFGWEI;
assign PECCTRLWEI_GetWei = next_state == RDRAM && state ==  CFGWEI;//==CTRLWEIPEC_RdyWei

// finished in DISWEI
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        WeiArray          <= 0;
        FlgWei              <= 0;
    end else if ( CfgWei ) begin
        FlgWei           <= DISWEIPEC_FlgWei;
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
assign LevFnhAll =   MACPEC_Fnh6 && MACPEC_Fnh7 && MACPEC_Fnh8
                      && MACPEC_Fnh3 && MACPEC_Fnh4 && MACPEC_Fnh5
                      && MACPEC_Fnh0 && MACPEC_Fnh1 && MACPEC_Fnh2 ;


always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        LevFnhAll_d <= 1;
    end else begin
        LevFnhAll_d <= LevFnhAll;
        LevFnhAll_dd<=LevFnhAll_d;
        LevFnhAll_ddd<=LevFnhAll_dd;
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        LstActRow_d <= 0;
        LstActRow_dd <= 0;
    end else begin
         LstActRow_d<= LstActRow;
         LstActRow_dd<= LstActRow_d;
         LstActRow_ddd<=LstActRow_dd;
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        LstActBlk_d <= 0;
        LstActBlk_dd <= 0;
        LstActBlk_ddd <= 0;
    end else begin
        LstActBlk_d <= LstActBlk;
        LstActBlk_dd <= LstActBlk_d;
        LstActBlk_ddd <= LstActBlk_dd;
    end
end
assign PlsFnhAll = LevFnhAll && ~LevFnhAll_d;
assign StaRow = FrtActRow && PlsFnhAll;
assign FnhRow = LstActRow_dd && LevFnhAll_d && ~LevFnhAll_dd; // paulse
assign FnhBlk = LstActBlk_ddd && LevFnhAll_dd && ~LevFnhAll_ddd;

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        PECMAC_FlgAct <= 0;
        PECMAC_Act    <= 0;
        NXTPEC_FrtActRow <= 0;
        NXTPEC_LstActBlk <= 0;
        NXTPEC_LstActRow <= 0;
    end else if ( CfgMac ) begin
        PECMAC_FlgAct    <= PEBPEC_FlgAct;
        PECMAC_Act       <= PEBPEC_Act;

        FrtActRow        <=LSTPEC_FrtActRow;
        LstActRow        <=LSTPEC_LstActRow;
        LstActBlk        <=LSTPEC_LstActBlk;
        ValPsum          <= LSTPEC_ValPsum;
        ValCol              <= LSTPEC_ValCol;

        NXTPEC_FrtActRow <= FrtActRow;
        NXTPEC_LstActBlk <= LstActBlk;
        NXTPEC_LstActRow <= LstActRow;
        NXTPEC_ValPsum   <= ValPsum;
        NXTPEC_ValCol   <= ValCol;
    end
end

/*    if ( !rst_n ) begin
        RdyRAMDatRd <= 0;
    end else if ( PECRAM_EnRd ) begin // make sure Dat is read firstly, then compute.
        RdyRAMDatRd <= 1;
    end else if ( FnhBlk) begin
        RdyRAMDatRd <= 0;
    end
end
*/
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        PECMAC_Sta <= 0;
    end else begin
        PECMAC_Sta <= CfgMac ;//paulse  && EnPEC
    end
end

assign PECCNV_FnhRow = FnhRow;


// Read SRAM
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        PECRAM_AddrRd <= 0;
 //   end else if ( FnhBlk ) begin // PECRAM_AddrRd automatic to zero because of PECRAM_EnRd
 //       PECRAM_AddrRd <= 0;
    end else if ( PECRAM_EnRd ) begin
        PECRAM_AddrRd <= PECRAM_AddrRd + 1;
    end
end
//assign PECRAM_EnRd = StaRow && ValPsum; // 14
//assign PECRAM_EnRd = state == RDRAM; // 14
assign PECRAM_EnRd = PECMAC_Sta; // 14
assign PECCNV_Psum = RAMPEC_DatRd ;


// Write SRAM
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        PECRAM_AddrWr <= 0;
    end else if ( FnhBlk ) begin
        PECRAM_AddrWr <= 0;
    end else if ( PECRAM_EnWr ) begin
        PECRAM_AddrWr <= PECRAM_AddrWr + 1;
    end
end
assign PECRAM_DatWr = CNVOUT_Psum0; // 14
assign PECRAM_EnWr  = PlsFnhAll_d && ValPsum && ValCol;//output Row is 1-14 not -1, 0



//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================

CNVROW #(
    .ADDR_GET(0)
    ) CNVROW0 (
        .clk            (clk),
        .rst_n          (rst_n),
        .PECMAC_Sta     (PECMAC_Sta),
        .PECCNV_PlsAcc  (PlsFnhAll),// WAITGETute Psum
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
        .CNVIN_Psum     (CNVOUT_Psum1),
        .CNVOUT_Psum    (CNVOUT_Psum0)
    );

CNVROW CNVROW1 (
        .clk            (clk),
        .rst_n          (rst_n),
        .PECMAC_Sta     (PECMAC_Sta),
        .PECCNV_PlsAcc  (PlsFnhAll),// WAITGETute Psum
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
        .CNVIN_Psum     (CNVOUT_Psum2),
        .CNVOUT_Psum    (CNVOUT_Psum1)
    );

CNVROW CNVROW2 (
        .clk            (clk),
        .rst_n          (rst_n),
        .PECMAC_Sta     (PECMAC_Sta),
        .PECCNV_PlsAcc  (PlsFnhAll),// WAITGETute Psum
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
        .CNVIN_Psum     (PECCNV_Psum),
        .CNVOUT_Psum    (CNVOUT_Psum2)
    );
Delay #(
    .NUM_STAGES(1),
    .DATA_WIDTH(1)
    )Delay_PlsFnhAll(
    .CLK(clk),
    .RESET_N(rst_n),
    .DIN(PlsFnhAll),
    .DOUT(PlsFnhAll_d)
    );

endmodule
