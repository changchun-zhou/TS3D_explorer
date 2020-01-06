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
module MACAW(
    input                   clk     ,
    input                   rst_n   ,
    input                   PECMAC_Sta      ,
    output                  MACPEC_Fnh,//level; same with Mac

    input [ `CHANNEL_DEPTH              - 1 : 0 ] PECMAC_FlgAct,
    input [ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ] PECMAC_Act,
    input [ `CHANNEL_DEPTH              - 1 : 0 ] PECMAC_FlgWei,    
    input [ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ] PECMAC_Wei,

    input [ `DATA_WIDTH + `C_LOG_2(`CHANNEL_DEPTH*3)- 1 : 0 ] MACMAC_Mac,
    output [ `DATA_WIDTH + `C_LOG_2(`CHANNEL_DEPTH*3)- 1 : 0 ] MACCNV_Mac

);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================


//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================
reg                                           ValFlg;
reg [ `CHANNEL_DEPTH                - 1 : 0 ] FlgAct;
reg [ `CHANNEL_DEPTH                - 1 : 0 ] FlgWei;
reg [ `CHANNEL_DEPTH                - 1 : 0 ] Set;

wire                                          ValOffset;
wire[ `C_LOG_2(`CHANNEL_DEPTH)      - 1 : 0 ] OffsetAct;
wire[ `C_LOG_2(`CHANNEL_DEPTH)      - 1 : 0 ] OffsetWei;

reg                                           ValAddr;
reg [ `C_LOG_2(`CHANNEL_DEPTH)       - 1 : 0 ] AddrAct;
reg [ `C_LOG_2(`CHANNEL_DEPTH)       - 1 : 0 ] AddrWei;

//=====================================================================================================================
// Logic Design :
//=====================================================================================================================

// Update Flg and ValFlg
always @ ( posedge clk or negedge rst_n ) begin 
    if ( ~rst_n ) begin
        FlgAct <= 0;
        FlgWei <= 0;
        // ValFlg  <= 0;
    end else if ( PECMAC_Sta ) begin
        FlgAct <= `PECMAC_FlgAct;
        FlgWei <= `PECMAC_FlgWei;
        // ValFlg  <= 1;
    end else if ( ValOffset ) begin
        FlgAct <= FlgAct & ~Set; // drop ahead 1
        FlgWei <= FlgWei & ~Set;
        // ValFlg  <= 1;
    end else begin
        // ValFlg  <= 0;
    end
end

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        ValFlg <= 0;
    end else if ( PECMAC_Sta )begin
        ValFlg <= 1;
    end else if( ValOffset && state ) begin
        ValFlg <= 1;
    end else begin
        ValFlg <= 0;
    end
end

// 
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        AddrAct <= -1;// Meet first Addr 31
        AddrWei <= -1;
        ValAddr <= 0;
    end else if ( PECMAC_Sta ) begin
        AddrAct <= -1;
        AddrWei <= -1;
        ValAddr <= 0;        
    end else if ( ValOffset ) begin // When FlgAct==0, AddrAct <= 31 
        AddrAct <= AddrAct + OffsetAct;
        AddrWei <= AddrWei + OffsetWei;
        ValAddr <= 1;
    end else begin
        ValAddr <= 0;
    end
end

// MUL and Acc
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
    end else begin
        MACPEC_Fnh <= ~(|(FlgAct & FlgWei)) && state;// FlgAct & FlgWei == 'b0 && state == COMP
    end
end

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
                state <= IDLE

      default: state <= IDLE;
    endcase
  end
end


//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================

FLGOFFSET #(
        .DATA_WIDTH(`CHANNEL_DEPTH),
        .ADDR_WIDTH(`C_LOG_2(`CHANNEL_DEPTH))
    ) FLGOFFSET (
        .Act    (FlgAct),
        .Wei    (FlgWei),
        .ValFlg  ( ValFlg),
        .OffsetAct (OffsetAct),
        .OffsetWei (OffsetWei),
        .SetOut    ( Set ),
        .ValOffset    (ValOffset )
    );

endmodule