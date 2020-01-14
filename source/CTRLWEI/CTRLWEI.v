//======================================================
// Copyright (C) 2019 By zhoucc
// All Rights Reserved
//======================================================
// Module : CTRLWEI
// Author : CC zhou
// Contact : 
// Date : 7 .1 .2019
//=======================================================
// Description : Control configuration of Weights for 48 PECs one by one;

// Ahead get GetWei(CTRLWEI_PlsFetch) and output RdyWei;

// input GetWei, produce CTRLWEI_PlsFetch activate Pipeline 1 clk;
// collect RdyWei from DISWEI, set 1 to RdyWei of NXTPEC;
//========================================================
`include "../include/dw_params_presim.vh"
module CTRLWEI (
    input                                           clk     ,
    input                                           rst_n   ,
    input                                           TOP_Sta,
    output reg [ `NUMPEC                    -1 : 0] CTRLWEIPEC_RdyWei ,//48 b
    input  [ `NUMPEC                        -1 : 0] PECCTRLWEI_GetWei , 
    input                                           DISWEI_RdyWei, 
    output                                          CTRLWEI_PlsFetch
);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================





//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================
reg [ `C_LOG_2(`NUMPEC)   - 1 : 0 ] IDPEC;


//=====================================================================================================================
// Logic Design :
//=====================================================================================================================
localparam IDLE     = 3'b000;
localparam PREPIPE1 = 3'b100;
localparam PREPIPE2 = 3'b101;
localparam PREPIPE3 = 3'b111;
localparam PREPIPE4 = 3'b110;
localparam GETWEI   = 3'b010;

reg [ 3 - 1 : 0          ] state;
reg [ 3 - 1 : 0          ] next_state;

always @(*) begin
    case (state)
      IDLE    : if ( TOP_Sta )
                    next_state <= PREPIPE1;
                else 
                    next_state <= IDLE;
      PREPIPE1: next_state <= PREPIPE2;
      PREPIPE2: next_state <= PREPIPE3;
      PREPIPE3: next_state <= GETWEI;
      GETWEI  : if( 1'b0) //config finish
                    next_state <= IDLE;
                else 
                    next_state <= GETWEI;
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

//GBFWEI is scheduled ahead
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        IDPEC <= `NUMPEC -1;
    end else if ( CTRLWEI_PlsFetch && IDPEC==0 ) begin// automatic loop 0-47
        IDPEC <= `NUMPEC -1;
    end else if ( CTRLWEI_PlsFetch && state == GETWEI) begin
        IDPEC <= IDPEC - 1; // MSB to LSB
    end
end

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CTRLWEIPEC_RdyWei <= 0;
    end else if ( |PECCTRLWEI_GetWei ) begin
        CTRLWEIPEC_RdyWei <= 0;
    end else if ( DISWEI_RdyWei && state == GETWEI ) begin
        CTRLWEIPEC_RdyWei[IDPEC] <= 1;
    end
end

// PECCTRLWEI_GetWei == CTRLWEIPEC_RdyWei
// CTRLWEI_PlsFetch is triggered by CTRLWEIPEC_RdyWei directly because PEC fectches Wei immediately

assign CTRLWEI_PlsFetch = ( |CTRLWEIPEC_RdyWei && |PECCTRLWEI_GetWei ) || state[2] ;


//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================


endmodule