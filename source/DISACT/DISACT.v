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
    // output                                          CTRLACT_GetAct,                    
    output                                          DISACT_RdyAct,
    // input                                           DISACT_GetAct,
    output      [ `BLOCK_DEPTH              -1 : 0] DISACT_FlgAct,
    output       [ `DATA_WIDTH * `BLOCK_DEPTH-1 : 0] DISACT_Act,    
    input                                           GBFACT_Val, //valid 
    output                                          GBFACT_EnRd,
    output reg  [ `GBFACT_ADDRWIDTH         -1 : 0] GBFACT_AddrRd,
    input       [ `DATA_WIDTH               -1 : 0] GBFACT_DatRd,// 8 * `DATA_WIDTH meets bandwidth; like WEI ////////////////////
    input                                           GBFFLGACT_Val, //valid 
    output                                          GBFFLGACT_EnRd,
    output reg  [ `GBFACT_ADDRWIDTH         -1 : 0] GBFFLGACT_AddrRd,
    input       [ `BLOCK_DEPTH              -1 : 0] GBFFLGACT_DatRd
                        
);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================





//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================
wire                                    NearFnhPacker;
wire                                    PlsFetch;
reg                                     PACKER_Sta;
reg                                     GBFFLGACT_EnRd_d;
reg [ `C_LOG_2(`BLOCK_DEPTH)      : 0] PACKER_Num;
reg                                     PACKER_ValDat;
wire                                    PACKER_ReqDat;

wire                                    PACKER_Bypass;
wire                                    GBFVNACT_EnRd;
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

      CHECKDATA:if( GBFACT_Val && GBFFLGACT_Val)
                    next_state <= CFGACT;
                else 
                    next_state <= CHECKDATA;
      CFGACT  : if( NearFnhPacker) //config finish
                    next_state <= WAITGET;
                else 
                    next_state <= CFGACT;
      WAITGET : if( CTRLACT_PlsFetch )
                    next_state <= CHECKDATA;
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

// assign CTRLACT_GetAct = DISACT_GetAct;
assign DISACT_RdyAct = state == WAITGET;

assign PlsFetch = next_state == CFGACT && state == CHECKDATA;


// Fetch valid num
// always @ ( posedge clk or negedge rst_n ) begin
//     if ( ~rst_n ) begin
//         GBFVNACT_AddrRd <= 0;
//     end else if ( PlsFetch ) begin
//         GBFVNACT_AddrRd <= GBFVNACT_AddrRd + 1;
//     end
// end

assign GBFVNACT_EnRd = PlsFetch;

// Fetch ACT
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        GBFACT_AddrRd <= 0;
    end else if( 1'b0 ) begin ////////////////////////////////////////
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
        GBFFLGACT_EnRd_d <= 0;
    end else begin
        GBFFLGACT_EnRd_d <= GBFFLGACT_EnRd;
        PACKER_Sta <= GBFFLGACT_EnRd_d;
    end
end

// FLAG 
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        GBFFLGACT_AddrRd <= 0;
    end else if ( 1'b0 ) begin ///////////////////////////////////
        GBFFLGACT_AddrRd <= 0;
    end else if ( GBFFLGACT_EnRd ) begin
        GBFFLGACT_AddrRd <= GBFFLGACT_AddrRd + 1;
    end
end

assign DISACT_FlgAct = GBFFLGACT_DatRd;
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        PACKER_Num <= 0;
    end else if ( GBFFLGACT_EnRd_d ) begin
        PACKER_Num <=   GBFFLGACT_DatRd[0] + GBFFLGACT_DatRd[1] + GBFFLGACT_DatRd[2] + GBFFLGACT_DatRd[3] + GBFFLGACT_DatRd[4] + GBFFLGACT_DatRd[5] + GBFFLGACT_DatRd[6] + GBFFLGACT_DatRd[7] +
                        GBFFLGACT_DatRd[8] + GBFFLGACT_DatRd[9] + GBFFLGACT_DatRd[10] + GBFFLGACT_DatRd[11] +
GBFFLGACT_DatRd[12] +
GBFFLGACT_DatRd[13] +
GBFFLGACT_DatRd[14] +
GBFFLGACT_DatRd[15] +
GBFFLGACT_DatRd[16] +
GBFFLGACT_DatRd[17] +
GBFFLGACT_DatRd[18] +
GBFFLGACT_DatRd[19] +
GBFFLGACT_DatRd[20] +
GBFFLGACT_DatRd[21] +
GBFFLGACT_DatRd[22] +
GBFFLGACT_DatRd[23] +
GBFFLGACT_DatRd[24] +
GBFFLGACT_DatRd[25] +
GBFFLGACT_DatRd[26] +
GBFFLGACT_DatRd[27] +
GBFFLGACT_DatRd[28] +
GBFFLGACT_DatRd[29] +
GBFFLGACT_DatRd[30] +
GBFFLGACT_DatRd[31] ;
    end
end

assign GBFFLGACT_EnRd = PlsFetch;
assign PACKER_Bypass = ~(|PACKER_Num); //flag == 0

//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================
PACKER #(
        .NUM_DATA(`BLOCK_DEPTH),
        .DATA_WIDTH(`DATA_WIDTH)
    ) PACKER_ACT (
        .clk           (clk),
        .rst_n         (rst_n),
        .NumPacker     (PACKER_Num),
        .Sta           (PACKER_Sta),
        .Bypass        (PACKER_Bypass),
        .ReqDat        (PACKER_ReqDat),
        .ValDat        (PACKER_ValDat),
        .Dat           (GBFACT_DatRd),
        .DatPacker     (DISACT_Act),
        .NearFnhPacker (NearFnhPacker)
    );
endmodule