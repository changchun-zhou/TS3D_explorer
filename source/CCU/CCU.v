//======================================================
// Copyright (C) 2019 By zhoucc
// All Rights Reserved
//======================================================
// Module : CCU
// Author : CC zhou
// Contact :
// Date : 3 .9 .2019
//=======================================================
// Description :
//========================================================
module CCU (
    input                   clk     ,
    input                   rst_n   ,
    input                   IFCFG_RdDone,
    output                  CFG_Req,
    input                       IFCFG_Val,
    input                   GBF_Val,
    output                  TOP_Sta,
    output                  Rst_Layer,// Rst_pat Rst_Frm,
    output                   IF_Val
);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================





//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================





//=====================================================================================================================
// Logic Design :
//=====================================================================================================================
localparam IDLE = 3'b000;
localparam CFG = 3'b001;
localparam CMP = 3'b010;
localparam STOP = 3'b011;
localparam WAITGBF = 3'b100;
reg [ 3 -1:0 ]state;
reg [ 3 -1:0 ]next_state;
always @(*) begin
    case ( state )
        IDLE : if( 1'b1)
                    next_state <= CFG; //A network config a time
                else
                    next_state <= IDLE;
        CFG: if( IFCFG_RdDone)
                    next_state <= WAITGBF;
                else
                    next_state <= CFG;
        WAITGBF: if( GBF_Val)//every layer
                    next_state <= CMP;
                else
                    next_state <= WAITGBF;
        CMP: if( 1'b0)
                    next_state <= IDLE;
                else if ( 1'b0 )
                    next_state <= WAITGBF;
                else
                    next_state <= CMP;
        default: next_state <= IDLE;
    endcase
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end
assign CFG_Req = state == CFG;
//assign CFG_Req = 0;
assign TOP_Sta = state == WAITGBF && next_state == CMP;// paulse
assign Rst_Layer = state != WAITGBF && next_state == WAITGBF ;
assign IF_Val = state != IDLE;
//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================


endmodule