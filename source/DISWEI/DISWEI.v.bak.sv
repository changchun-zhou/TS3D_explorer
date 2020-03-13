//======================================================
// Copyright (C) 2019 By zhoucc
// All Rights Reserved
//======================================================
// Module : DISWEI
// Author : CC zhou
// Contact : 
// Date : 7 .1 .2019
//=======================================================
// Description :
// Pipeline because of 6 clk between GetWei and RdyWei;
//========================================================
module DISWEI #(
    parameter  = 
) (
    input                   clk     ,
    input                   rst_n   ,
    input                         ,
    input                  CTRLWEI_PlsFetch,
    input                  CTRLWEI_GetWei, 
    output                                       DISWEI_RdyWei,
    output [ `DATA_WIDTH * `BLOCK_DEPTH * `KERNEL_SIZE - 1 : 0 ] DISWEIPEC_Wei,
    output [ 1 * `BLOCK_DEPTH * `KERNEL_SIZE        - 1 : 0 ] DISWEIPEC_FlgWei,
    // output   DISWEI_AddrBase0,




    input                                        GBFWEI_Val, //valid 
    output                                       GBFWEI_EnRd,
    output [ `GBFWEI_ADDRWIDTH          - 1 : 0 ]GBFWEI_AddrRd,
    input  [ `GBFWEI_DATAWIDTH          - 1 : 0 ]GBFWEI_DatRd,

    input                                        GBFFLGWEI_Val, //valid 
    output                                       GBFFLGWEI_EnRd,
    output [ `GBFWEI_ADDRWIDTH          - 1 : 0 ]GBFFLGWEI_AddrRd,
    input  [ `GBFFLGWEI_DATAWIDTH       - 1 : 0 ]GBFFLGWEI_DatRd,



                        
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
// localparam IDLE = 3'b000;
// localparam CHECKDATA = 3'b001;
// localparam CFGWEI = 3'b011;
// localparam WAITGET = 3'b010;

// reg [ 3 - 1 : 0          ] state;
// reg [ 3 - 1 : 0          ] next_state;

// always @(*) begin
//     case (state)
//       IDLE    : if ( CTRLWEI_PlsFetch )
//                     next_state <= CHECKDATA;
//                 else 
//                     next_state <= IDLE;

//       CHECKDATA:if( GBFWEI_Val && GBFFLGWEI_Val && GBFVNWEI_Val)
//                     next_state <= CFGWEI;
//                 else 
//                     next_state <= CHECKDATA;

//       CFGWEI  : if( FnhFetch) //config finish
//                     next_state <= WAITGET;
//                 else 
//                     next_state <= CFGWEI;
//       WAITGET : if( DISWEI_GetWei )
//                     next_state <= IDLE;
//                 else 
//                     next_state <= WAITGET;

//       default: next_state <= IDLE;
//     endcase
// end
// always @ ( posedge clk or negedge rst_n ) begin
//     if ( ~rst_n ) begin
//         state <= IDLE;
//     end else  begin
//         state <= next_state
//     end
// end
assign CTRLWEI_GetWei = DISWEI_GetWei;
// assign PlsFetch = next_state == CFGWEI && state == CHECKDATA;



always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        GBFFLGWEI_AddrRd <= 0;
    end else if (  ) begin
        GBFFLGWEI_AddrRd <= 0;
    end else if ( GBFFLGWEI_EnRd ) begin
        GBFFLGWEI_AddrRd <= GBFFLGWEI_AddrRd + 1;
    end
end
assign GBFFLGWEI_EnRd = PlsFetch;

generate
  genvar i;
  for( i=0; i<`KERNEL_SIZE ; i=i+1) begin: AddrWeiGen
      always @ ( posedge clk or negedge rst_n ) begin
          if ( ~rst_n ) begin
              ValNumWei[i] <= 0;
          end else if (  ) begin
              ValNumWei[i] <= GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+ 0] + GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+ 8] + GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+16] + GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+24] + 
                              GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+ 1] + GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+ 9] + GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+17] + GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+25] +
                              GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+ 2] + GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+10] + GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+18] + GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+26] +
                              GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+ 3] + GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+11] + GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+19] + GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+27] +
                              GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+ 4] + GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+12] + GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+20] + GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+28] +
                              GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+ 5] + GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+13] + GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+21] + GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+29] +
                              GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+ 6] + GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+14] + GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+22] + GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+30] +
                              GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+ 7] + GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+15] + GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+23] + GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+31]  ;

          end
      end
endgenerate

// assign DISWEI_AddrBase0 = 8 - ValNumRmn ;//
// assign DISWEI_AddrBase1 = DISWEI_AddrBase0 + ValNumWei[0];
// assign DISWEI_AddrBase2 = DISWEI_AddrBase1 + ValNumWei[1];
// assign DISWEI_AddrBase3 = DISWEI_AddrBase2 + ValNumWei[2];
// assign DISWEI_AddrBase4 = DISWEI_AddrBase3 + ValNumWei[3];
// assign DISWEI_AddrBase5 = DISWEI_AddrBase4 + ValNumWei[4];
// assign DISWEI_AddrBase6 = DISWEI_AddrBase5 + ValNumWei[5];
// assign DISWEI_AddrBase7 = DISWEI_AddrBase6 + ValNumWei[6];
// assign DISWEI_AddrBase8 = DISWEI_AddrBase7 + ValNumWei[7];

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
         <= ;
    end else if (  ) begin
        ValNumPEC <= ValNumWei[0] + ValNumWei[1] + ValNumWei[2] + ValNumWei[3] + ValNumWei[4] + 
                     ValNumWei[5] + ValNumWei[6] + ValNumWei[7] + ValNumWei[8] ;
    end
end
                   

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CntFetch <= 0;
    end else if ( FnhFetch ) begin
        CntFetch <= 0;
    end else if ( GBFWEI_EnRd ) begin
        CntFetch <= CntFetch + 1;
    end
end

//Long delay chain: ValNumWei -> ValNumPEC -> FnhFetch -> next_state ->PlsFetch
//fanout
assign FnhFetch = ( CntFetch << 3 + ValNumRmn) >= ValNumPEC;
assign GBFWEI_EnRd = state == CFGWEI && ~FnhFetch; 

assign DISWEIPEC_RdyWei = state == WAITGET;

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        DISWEIPEC_Wei <= 0;
    end else if ( GBFWEI_EnRd_d ) begin
        DISWEIPEC_Wei <= {DISWEIPEC_Wei, GBFWEI_DatRd};//
    end
end

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        ValNumRmn <= 0;
    end else if ( FnhFetch ) begin
        ValNumRmn <= DISWEI_AddrBase0;
    end
end


//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================


endmodule