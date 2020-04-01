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
`include "../source/include/dw_params_presim.vh"
module CTRLWEI (
    input                                           clk     ,
    input                                           rst_n   ,
    input                                           Start,
    input                                           Reset  ,
    output reg [ `NUMPEC                    -1 : 0] CTRLWEIPEC_RdyWei ,//48 b
    input  [ `NUMPEC                        -1 : 0] PECCTRLWEI_GetWei ,
    input                                           DISWEI_RdyFIFO,
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

localparam IDLE         = 3'b000;
localparam WAITGETWEI   = 3'b010;
localparam WAIT_DISWEI = 3'b001;
reg [ 3 - 1 : 0          ] state;
reg [ 3 - 1 : 0          ] next_state;

always @(*) begin
    case (state)
      IDLE    : if ( Start )
                    next_state <= WAIT_DISWEI;
                else
                    next_state <= IDLE;
      WAIT_DISWEI: if(Reset)
                    next_state <= IDLE;
                else if( DISWEI_RdyFIFO)
                    next_state <= WAITGETWEI;
      WAITGETWEI  :
                if( Reset) //config finish
                    next_state <= IDLE;
                else if ( |PECCTRLWEI_GetWei )
                    next_state <= WAIT_DISWEI;
                else
                    next_state <= WAITGETWEI;
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
    end else if ( state==WAITGETWEI && next_state==WAIT_DISWEI && IDPEC==0 || Reset) begin// automatic loop 0-47
        IDPEC <= `NUMPEC -1;
    end else if ( state==WAITGETWEI && next_state==WAIT_DISWEI) begin// be PEC fetch
        IDPEC <= IDPEC - 1; // MSB to LSB
    end
end

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CTRLWEIPEC_RdyWei <= 0;
    end else if ( state==WAITGETWEI && next_state==WAIT_DISWEI || Reset) begin
        CTRLWEIPEC_RdyWei <= 0;
    end else if ( state == WAITGETWEI ) begin
        CTRLWEIPEC_RdyWei[IDPEC] <= 1;
    end
end

assign CTRLWEI_PlsFetch = state==WAIT_DISWEI && next_state == WAITGETWEI;


//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================


endmodule
