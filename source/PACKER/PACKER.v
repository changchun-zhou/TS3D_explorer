//======================================================
// Copyright (C) 2019 By zhoucc
// All Rights Reserved
//======================================================
// Module : PACKER
// Author : CC zhou
// Contact : 
// Date :   6 . 1 .2019
//=======================================================
// Description : Make sure ValDat delay 1 clk after ReqDat
// 
//========================================================
`include "../include/dw_params_presim.vh"
module  PACKER #(
    parameter NUM_DATA =  32,
    parameter DATA_WIDTH = 8
) (
    input                                   clk     ,
    input                                   rst_n   ,
    input  [ `C_LOG_2(NUM_DATA)    - 1 : 0 ] NumPacker, // 0-31 stands for 1-32 data
    input                                   Sta,//paulse
    input                                   Bypass ,// paulse 0 data

    output                                  ReqDat,
    input                                   ValDat, // Make sure ValDat delay 1 clk after ReqDat
    input  [ DATA_WIDTH           - 1 : 0 ] Dat,
    output reg [ DATA_WIDTH * NUM_DATA- 1 : 0 ] DatPacker,  
    output                                  NearFnhPacker  // because Dat delay 1 clk after ReqDat  
);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================





//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================
reg  [ `C_LOG_2(NUM_DATA) - 1 : 0 ] CntFetch; // cannot reach NUM_DATA




//=====================================================================================================================
// Logic Design :
//=====================================================================================================================
localparam IDLE = 0;
localparam READ = 1;
reg state;
reg next_state;

always @(*) begin
    case (state)
      IDLE    : if ( Sta && ~Bypass )
                  next_state <= READ;
                else 
                  next_state <= IDLE;
      READ: if( NearFnhPacker)
                  next_state <= IDLE;
            else
                  next_state <= READ;

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

assign ReqDat = next_state;


always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        DatPacker <= 0;
    end else if ( Sta ) begin
        DatPacker <= 0;
    end else if( ValDat) begin
        DatPacker <= { DatPacker, Dat};//
    end
end

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CntFetch <= 0;
    end else if ( NearFnhPacker) begin
        CntFetch <= 0;
    end else if ( ValDat ) begin
        CntFetch <= CntFetch + 1;
    end
end

assign NearFnhPacker = Bypass || CntFetch == NumPacker;


//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================


endmodule