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
    input                                           TOP_Sta,
    input                                            GBFFLGWEI_Val,
    input                                             GBFWEI_Val,
    output reg [ `NUMPEC                    -1 : 0] CTRLWEIPEC_RdyWei ,//48 b
    input  [ `NUMPEC                        -1 : 0] PECCTRLWEI_GetWei ,
    input                                           DISWEI_RdyWei,
    output                                          CTRLWEI_PlsFetch,
    input                                           CTRLACT_FnhFrm
);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================





//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================
reg [ `C_LOG_2(`NUMPEC)   - 1 : 0 ] IDPEC;
wire                                                  WEI_Val;

//=====================================================================================================================
// Logic Design :
//=====================================================================================================================
assign WEI_Val = GBFFLGWEI_Val && GBFWEI_Val;

localparam IDLE         = 3'b000;
localparam PREPIPE1 = 3'b100;
localparam PREPIPE2 = 3'b101;
localparam PREPIPE3 = 3'b111;
localparam PREPIPE4 = 3'b110;
localparam WAITGETWEI   = 3'b010;
localparam WAITWEIVAL   = 3'b011;
localparam WAIT = 3'b001;
reg [ 3 - 1 : 0          ] state;
reg [ 3 - 1 : 0          ] next_state;

always @(*) begin
    case (state)
      IDLE    : if ( TOP_Sta )
                    next_state <= WAIT;
                else
                    next_state <= IDLE;
      WAIT: if ( WEI_Val)
                    next_state <= PREPIPE1;
                else begin
                    next_state <= WAIT;
                end
      PREPIPE1: if ( WEI_Val)
                         next_state <= PREPIPE2;
                         else
                         next_state <= PREPIPE1;
      PREPIPE2: if ( WEI_Val)
                         next_state <= PREPIPE3;
                        else
                        next_state <= PREPIPE2;
      PREPIPE3: if ( WEI_Val)
                         next_state <= WAITGETWEI;
                        else
                        next_state <= PREPIPE3;
      WAITGETWEI  :
                if( 1'b0) //config finish
                    next_state <= IDLE;
                else if(CTRLACT_FnhFrm) //New frame reset address of weights
                    next_state <= WAIT;
                else if ( PECCTRLWEI_GetWei )
                    next_state <= WAITWEIVAL;
                else
                    next_state <= WAITGETWEI;
      WAITWEIVAL: //
                if( WEI_Val)// check WEI Val
                  next_state <= WAITGETWEI;
                else
                    next_state <= WAITWEIVAL;
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
    end else if ( CTRLWEI_PlsFetch && state == WAITWEIVAL) begin
        IDPEC <= IDPEC - 1; // MSB to LSB
    end
end

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CTRLWEIPEC_RdyWei <= 0;
    end else if ( |PECCTRLWEI_GetWei || CTRLACT_FnhFrm ) begin
        CTRLWEIPEC_RdyWei <= 0;
    end else if ( DISWEI_RdyWei && state == WAITGETWEI ) begin
        CTRLWEIPEC_RdyWei[IDPEC] <= 1;
    end
end

// PECCTRLWEI_GetWei == CTRLWEIPEC_RdyWei
// CTRLWEI_PlsFetch is triggered by CTRLWEIPEC_RdyWei directly because PEC fectches Wei immediately
wire PrePlsFetch; // 3 pls
assign PrePlsFetch = (state==WAIT&& next_state == PREPIPE1 || state == PREPIPE1 && next_state==PREPIPE2 || state == PREPIPE2 && next_state== PREPIPE3);
assign CTRLWEI_PlsFetch = ( state ==WAITWEIVAL &&next_state ==WAITGETWEI) || PrePlsFetch ;


//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================


endmodule
