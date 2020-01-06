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
module PEC (
    input                   clk     ,
    input                   rst_n   ,
    input                   PEBPEC_FnhRow      ,
    input                   PEBPEC_StaRow      ,
    input                   PEBPEC_FnhBlk      ,
    input                   PEBPEC_FnhFrm      ,
    // input                   PEBPEC_FrtBlk      ,//DO NOT get from data, instead 0;

    input                                         LSTPEC_RdyAct,// level
    output                                        LSTPEC_GetAct,// PAULSE
    input [ `CHANNEL_DEPTH              - 1 : 0 ] PEBPEC_FlgAct,
    input [ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ] PEBPEC_Act,
    output                                        NXTPEC_RdyAct,// To Next PEC: THIS PEC's ACT is NOT ever gotten
    input                                         NXTPEC_GetAct,// THIS PEC's ACT is gotten

    input                                         DISWEIPEC_RdyWei,
    input [ `CHANNEL_DEPTH              - 1 : 0 ] DISWEIMAC_FlgWei0,
    input [ `CHANNEL_DEPTH              - 1 : 0 ] DISWEIMAC_FlgWei1,
    input [ `CHANNEL_DEPTH              - 1 : 0 ] DISWEIMAC_FlgWei2,
    input [ `CHANNEL_DEPTH              - 1 : 0 ] DISWEIMAC_FlgWei3,
    input [ `CHANNEL_DEPTH              - 1 : 0 ] DISWEIMAC_FlgWei4,
    input [ `CHANNEL_DEPTH              - 1 : 0 ] DISWEIMAC_FlgWei5,
    input [ `CHANNEL_DEPTH              - 1 : 0 ] DISWEIMAC_FlgWei6,
    input [ `CHANNEL_DEPTH              - 1 : 0 ] DISWEIMAC_FlgWei7,
    input [ `CHANNEL_DEPTH              - 1 : 0 ] DISWEIMAC_FlgWei8,


    input [ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ] DISWEIMAC_Wei0,
    input [ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ] DISWEIMAC_Wei1,
    input [ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ] DISWEIMAC_Wei2,
    input [ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ] DISWEIMAC_Wei3,
    input [ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ] DISWEIMAC_Wei4,
    input [ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ] DISWEIMAC_Wei5,
    input [ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ] DISWEIMAC_Wei6,
    input [ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ] DISWEIMAC_Wei7,
    input [ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ] DISWEIMAC_Wei8,

    output                                        PECRAM_EnWr,
    output [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] PECRAM_AddrWr,
    output [  PSUM_WIDTH * `LENPSUM     - 1 : 0 ] PECRAM_DatWr,

    output                                        PECRAM_EnRd,
    output [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] PECRAM_AddrRd,
    input  [ PSUM_WIDTH * `LENPSUM      - 1 : 0 ] RAMPEC_DatRd 

);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================






//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================
wire CfgMac;

wire MACPEC_Fnh0;
wire MACPEC_Fnh1;
wire MACPEC_Fnh2;
wire MACPEC_Fnh3;
wire MACPEC_Fnh4;
wire MACPEC_Fnh5;
wire MACPEC_Fnh6;
wire MACPEC_Fnh7;
wire MACPEC_Fnh8;

reg [ `CHANNEL_DEPTH              - 1 : 0 ] PECMAC_FlgAct;
reg [ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ] PECMAC_Act;
reg                                         PECMAC_Sta;

wire                                PECCNV_PlsAcc;
wire                                PECCNV_FnhRow;

wire [  PSUM_WIDTH * `LENPSUM       - 1 : 0 ] PECCNV_Psum;
wire [  PSUM_WIDTH * `LENPSUM       - 1 : 0 ] CNVOUT_Psum0;
wire [  PSUM_WIDTH * `LENPSUM       - 1 : 0 ] CNVOUT_Psum1;
wire [  PSUM_WIDTH * `LENPSUM       - 1 : 0 ] CNVOUT_Psum2;


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
      IDLE  : if ( 1'b1 )
                  next_state <= CFGWEI;
      CFGWEI: if ( DISWEIPEC_RdyWei )
                next_state <= CFGACT;
      CFGACT: if( LSTPEC_RdyAct && PECCNV_PlsAcc)
                next_state <= WAITGET;
      WAITGET  : if( PEBPEC_FnhBlk )
                next_state <= IDLE;
              else if( NXTPEC_GetAct )
                next_state <= CFGACT;

      default: next_state <= IDLE;
    endcase
  end
end

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end


assign CfgMac = next_state == WAITGET && state == CFGACT;

// output Rdy/ Get
assign NXTPEC_RdyAct = state == WAITGET;
assign LSTPEC_GetAct = CfgMac;

// Connect CNV && MAC
// update ACT and Start
assign PECCNV_PlsAcc =   MACPEC_Fnh6 && MACPEC_Fnh7 && MACPEC_Fnh8
                      && MACPEC_Fnh3 && MACPEC_Fnh4 && MACPEC_Fnh5
                      && MACPEC_Fnh0 && MACPEC_Fnh1 && MACPEC_Fnh2 ;

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        PECMAC_FlgAct <= 0;
        PECMAC_Act    <= 0;
    end else if ( CfgMac ) begin
        PECMAC_FlgAct <= PEBPEC_FlgAct;
        PECMAC_Act    <= PEBPEC_Act;
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        PECMAC_Sta <= 0;
    end else begin
        PECMAC_Sta <= CfgMac;//paulse
    end
end
assign PECCNV_FnhRow = PEBPEC_FnhRow;


// Read SRAM
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        PECRAM_AddrRd <= 0;
    end else if ( PEBPEC_FnhBlk ) begin
        PECRAM_AddrRd <= 0;
    end else if ( PEBPEC_StaRow ) begin
        PECRAM_AddrRd <= PECRAM_AddrRd + 1;
    end
end
assign PECRAM_EnRd = PEBPEC_StaRow ;
assign PECCNV_Psum = RAMPEC_DatRd ;

// Write SRAM
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        PECRAM_AddrWr <= 0;
    end else if ( PEBPEC_FnhBlk ) begin
        PECRAM_AddrWr <= 0;        
    end else if ( PEBPEC_FnhRow ) begin
        PECRAM_AddrWr <= PECRAM_AddrWr + 1;
    end
end
assign PECRAM_DatWr = CNVOUT_Psum2;
assign PECRAM_EnWr  = PEBPEC_FnhRow;



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
        .PECMAC_FlgWei0 (DISWEIMAC_FlgWei6),
        .PECMAC_FlgWei1 (DISWEIMAC_FlgWei7),
        .PECMAC_FlgWei2 (DISWEIMAC_FlgWei8),
        .PECMAC_Wei0    (DISWEIMAC_Wei6),
        .PECMAC_Wei1    (DISWEIMAC_Wei7),
        .PECMAC_Wei2    (DISWEIMAC_Wei8),
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
        .PECMAC_FlgWei0 (DISWEIMAC_FlgWei3),
        .PECMAC_FlgWei1 (DISWEIMAC_FlgWei4),
        .PECMAC_FlgWei2 (DISWEIMAC_FlgWei5),
        .PECMAC_Wei0    (DISWEIMAC_Wei3),
        .PECMAC_Wei1    (DISWEIMAC_Wei4),
        .PECMAC_Wei2    (DISWEIMAC_Wei5),
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
        .PECMAC_FlgWei0 (DISWEIMAC_FlgWei0),
        .PECMAC_FlgWei1 (DISWEIMAC_FlgWei1),
        .PECMAC_FlgWei2 (DISWEIMAC_FlgWei2),
        .PECMAC_Wei0    (DISWEIMAC_Wei0),
        .PECMAC_Wei1    (DISWEIMAC_Wei1),
        .PECMAC_Wei2    (DISWEIMAC_Wei2),
        .CNVIN_Psum     (CNVOUT_Psum1),
        .CNVOUT_Psum    (CNVOUT_Psum2)
    );


endmodule