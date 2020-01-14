//======================================================
// Copyright (C) 2019 By zhoucc
// All Rights Reserved
//======================================================
// Module : MACAW
// Author : CC zhou
// Contact : 
// Date : 3 .1 .2019
//=======================================================
// Description :
//========================================================
`include "../include/dw_params_presim.vh"
module MACAW(
    input                                                       clk     ,
    input                                                       rst_n   ,
    input                                                       PECMAC_Sta      ,
    output reg                                                  MACPEC_Fnh,//level; ahead 1 clk//////////////////////////////////////////
    input [ `BLOCK_DEPTH                                -1 : 0] PECMAC_FlgAct,
    input [ `DATA_WIDTH * `BLOCK_DEPTH                  -1 : 0] PECMAC_Act,
    input [ `BLOCK_DEPTH                                -1 : 0] PECMAC_FlgWei,    
    input [ `DATA_WIDTH * `BLOCK_DEPTH                  -1 : 0] PECMAC_Wei, // trans
    input [ `DATA_WIDTH + `C_LOG_2(`BLOCK_DEPTH*3)      -1 : 0] MACMAC_Mac,
    output reg[ `DATA_WIDTH + `C_LOG_2(`BLOCK_DEPTH*3)  -1 : 0] MACCNV_Mac

);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================


//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================
wire[ `C_LOG_2(`BLOCK_DEPTH)      -1 : 0] OffsetAct;
reg [ `C_LOG_2(`BLOCK_DEPTH)      -1 : 0] OffsetAct_d;
wire[ `C_LOG_2(`BLOCK_DEPTH)      -1 : 0] OffsetWei;
wire                                        ValAddr;
reg [ `C_LOG_2(`BLOCK_DEPTH)      -1 : 0] AddrAct;
reg [ `C_LOG_2(`BLOCK_DEPTH)      -1 : 0] AddrWei;
//=====================================================================================================================
// Logic Design :
//=====================================================================================================================

localparam IDLE = 0; 
localparam COMP = 1;
reg  state;
always @(posedge clk or negedge rst_n) begin
  if(~rst_n) begin
    state <= IDLE;
  end else begin
    case (state)
      IDLE: if ( PECMAC_Sta )
                state <= COMP;
      COMP: if( MACPEC_Fnh)
                state <= IDLE;

      default: state <= IDLE;
    endcase
  end
end

// 
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        AddrAct <= -1;// Meet first Addr 31
        AddrWei <= -1;
    end else if ( PECMAC_Sta ) begin
        AddrAct <= -1;
        AddrWei <= -1;
    end else begin // When FlgAct==0, AddrAct <= 31 
        AddrAct <= AddrAct + OffsetAct;
        AddrWei <= AddrWei + OffsetWei;
    end 
end

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        OffsetAct_d <= 0;
    end else  begin
        OffsetAct_d <= OffsetAct;
    end
end
assign ValAddr = |OffsetAct_d;// reduce path delay from FlgCutAct to AddrAct;

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        MACCNV_Mac <= 0;
    end else if ( PECMAC_Sta ) begin
        MACCNV_Mac <= MACMAC_Mac;
    end else if ( ValAddr ) begin
        MACCNV_Mac <= MACCNV_Mac + PECMAC_Act[  AddrAct << `C_LOG_2(`DATA_WIDTH) +: `DATA_WIDTH] 
                                 * PECMAC_Wei[  AddrWei << `C_LOG_2(`DATA_WIDTH) +: `DATA_WIDTH];
    end
end

// MACPEC_Fnh paulse
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        MACPEC_Fnh <= 0;
    end else if( PECMAC_Sta ) begin
        MACPEC_Fnh <= 0;
    end else begin
        MACPEC_Fnh <= ~(|OffsetAct) && state;// && state == COMP
    end
end

//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================

FLGOFFSET #(
        .DATA_WIDTH(`BLOCK_DEPTH),
        .ADDR_WIDTH(`C_LOG_2(`BLOCK_DEPTH))
    ) FLGOFFSET (
        .clk            (clk),
        .rst_n          (rst_n),
        .PECMAC_Sta     (PECMAC_Sta),
        .PECMAC_FlgAct  (PECMAC_FlgAct),
        .PECMAC_FlgWei  (PECMAC_FlgWei),
        .OffsetAct      (OffsetAct),
        .OffsetWei      (OffsetWei)
    );

endmodule