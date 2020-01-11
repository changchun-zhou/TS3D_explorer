//======================================================
// Copyright (C) 2019 By zhoucc
// All Rights Reserved
//======================================================
// Module : DISACT
// Author : CC zhou
// Contact : 
// Date : 6 .1 .2019
//=======================================================
// Description :
//========================================================
`include "../include/dw_params_presim.vh"
module DISACT (
    input                                           clk     ,
    input                                           rst_n   ,

    input                                           CTRLACT_PlsFetch,
    output                                          CTRLACT_GetAct,                    
    output                                          DISACT_RdyAct,
    input                                           DISACT_GetAct,
    output      [ `BLOCK_DEPTH              -1 : 0] DISACT_FlgAct,
    input       [ `DATA_WIDTH * `BLOCK_DEPTH-1 : 0] DISACT_Act,    
    input                                           GBFACT_Val, //valid 
    output                                          GBFACT_EnRd,
    output reg  [ `GBFACT_ADDRWIDTH         -1 : 0] GBFACT_AddrRd,
    input       [ `DATA_WIDTH               -1 : 0] GBFACT_DatRd,
    input                                           GBFFLGACT_Val, //valid 
    output                                          GBFFLGACT_EnRd,
    output reg  [ `GBFACT_ADDRWIDTH         -1 : 0] GBFFLGACT_AddrRd,
    input       [ `BLOCK_DEPTH              -1 : 0] GBFFLGACT_DatRd,
    input                                           GBFVNACT_Val, //valid num ACT
    output                                          GBFVNACT_EnRd,
    output reg  [ `GBFACT_ADDRWIDTH         -1 : 0] GBFVNACT_AddrRd,
    input       [ `C_LOG_2(`BLOCK_DEPTH)    -1 : 0] GBFVNACT_DatRd
                        
);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================





//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================
wire                                NearFnhPacker;
wire                                PlsFetch;
reg                                     PACKER_ValDat;
wire                                PACKER_ReqDat;
reg                                     PACKER_Sta;
wire                                PACKER_Bypass;
//=====================================================================================================================
// Logic Design :
//=====================================================================================================================

// 
localparam IDLE = 3'b000;
localparam CHECKDATA = 3'b001;
localparam CFGACT = 3'b011;
localparam WAITGET = 3'b010;

reg [ 3 - 1 : 0          ] state;
reg [ 3 - 1 : 0          ] next_state;

always @(*) begin
    case (state)
      IDLE    : if ( CTRLACT_PlsFetch )
                    next_state <= CHECKDATA;
                else 
                    next_state <= IDLE;

      CHECKDATA:if( GBFACT_Val && GBFFLGACT_Val && GBFVNACT_Val)
                    next_state <= CFGACT;
                else 
                    next_state <= CHECKDATA;
      CFGACT  : if( NearFnhPacker) //config finish
                    next_state <= WAITGET;
                else 
                    next_state <= CFGACT;
      WAITGET : if( DISACT_GetAct )
                    next_state <= IDLE;
                else 
                    next_state <= WAITGET;

      default: next_state <= IDLE;
    endcase
end


always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        state <= IDLE;
    end else  begin
        state <= next_state;
    end
end

assign CTRLACT_GetAct = DISACT_GetAct;
assign DISACT_RdyAct = state == WAITGET;

assign PlsFetch = next_state == CFGACT && state == CHECKDATA;


// Fetch valid num
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        GBFVNACT_AddrRd <= 0;
    end else if ( PlsFetch ) begin
        GBFVNACT_AddrRd <= GBFVNACT_AddrRd + 1;
    end
end

assign GBFVNACT_EnRd = PlsFetch;

// Fetch ACT
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        GBFACT_AddrRd <= 0;
    end else if( 1'b1 ) begin ////////////////////////////////////////
        GBFACT_AddrRd <= 0;
    end else if( GBFACT_EnRd) begin
        GBFACT_AddrRd <= GBFACT_AddrRd + 1;
    end
end
assign GBFACT_EnRd = PACKER_ReqDat;

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        PACKER_ValDat <= 0;
    end else begin
        PACKER_ValDat <= PACKER_ReqDat;
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        PACKER_Sta <= 0;
    end else begin
        PACKER_Sta <= GBFVNACT_EnRd;
    end
end

// FLAG 
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        GBFFLGACT_AddrRd <= 0;
    end else if ( 1'b1 ) begin ///////////////////////////////////
        GBFFLGACT_AddrRd <= 0;
    end else if ( GBFFLGACT_EnRd ) begin
        GBFFLGACT_AddrRd <= GBFFLGACT_AddrRd + 1;
    end
end

assign GBFFLGACT_EnRd = PlsFetch;
assign PACKER_Bypass = ~(|GBFFLGACT_DatRd); //flag == 0

//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================
PACKER #(
        .NUM_DATA(`BLOCK_DEPTH),
        .DATA_WIDTH(`DATA_WIDTH)
    ) PACKER_ACT (
        .clk           (clk),
        .rst_n         (rst_n),
        .NumPacker     (GBFVNACT_DatRd),
        .Sta           (PACKER_Sta),
        .Bypass        (PACKER_Bypass),
        .ReqDat        (PACKER_ReqDat),
        .ValDat        (PACKER_ValDat),
        .Dat           (GBFACT_DatRd),
        .DatPacker     (DISACT_Act),
        .NearFnhPacker (NearFnhPacker)
    );
endmodule