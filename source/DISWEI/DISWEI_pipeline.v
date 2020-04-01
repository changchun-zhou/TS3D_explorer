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
`include "../source/include/dw_params_presim.vh"
module DISWEI (
    input                                                           clk             ,
    input                                                           rst_n           ,
    input                                                           CTRLWEI_PlsFetch,
    output                                                          DISWEI_RdyWei   ,
    output reg  [ `DATA_WIDTH * `BLOCK_DEPTH * `KERNEL_SIZE -1 : 0] DISWEIPEC_Wei   ,// trans MSB and LSB
    output reg  [ 1 * `BLOCK_DEPTH * `KERNEL_SIZE           -1 : 0] DISWEIPEC_FlgWei,
    // output reg  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE)    -1 : 0] AddrBaseWei ,
 //   input                                                           GBFWEI_Val      , //valid
    output                                                          GBFWEI_EnRd     ,
    output reg  [ `GBFWEI_ADDRWIDTH                         -1 : 0] GBFWEI_AddrRd   ,
    input       [ `PORT_DATAWIDTH                         -1 : 0] GBFWEI_DatRd    ,
 //   input                                                           GBFFLGWEI_Val   , //valid
    output                                                          GBFFLGWEI_EnRd  ,
 //   output reg  [ `GBFFLGWEI_ADDRWIDTH                         -1 : 0] GBFFLGWEI_AddrRd,
    input       [ `GBFFLGWEI_DATAWIDTH                      -1 : 0] GBFFLGWEI_DatRd  ,
    input                                                           CTRLACT_FnhFrm  //reset AddrRd and pipeline

);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================
reg  CTRLACT_FnhFrm_d;




//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================
reg [ `C_LOG_2(`BLOCK_DEPTH)                    -1 : 0] ValNumWei   [ 0 : `KERNEL_SIZE - 1];
reg [ `C_LOG_2(`BLOCK_DEPTH)                    -1 : 0] ValNumWei_d   [ 0 : `KERNEL_SIZE - 1];
reg                                                     GBFWEI_EnRd_d;
reg                                                     GBFWEI_EnRd_dd;
reg                                                     GBFWEI_EnRd_ddd;
reg [ `C_LOG_2(`BLOCK_DEPTH * `KERNEL_SIZE )    -1 : 0] ValNumPEC;
wire [ `C_LOG_2(`BLOCK_DEPTH * `KERNEL_SIZE )    -1 : 0] NumVal_Cur;
reg [ `C_LOG_2(`BLOCK_DEPTH * `KERNEL_SIZE )    -1 : 0] CntFetch_SeqWei;
reg [ `GBFFLGWEI_DATAWIDTH                      -1 : 0] GBFFLGWEI_DatRd_d;
reg [ `GBFFLGWEI_DATAWIDTH                      -1 : 0] GBFFLGWEI_DatRd_dd;
reg                                                     ValFlgWei;
reg  [ 1 * `BLOCK_DEPTH * `KERNEL_SIZE           -1 : 0] FlgWei;
reg [ `C_LOG_2(`KERNEL_SIZE)                    -1 : 0] ValNumRmn_lastFetch;
reg  [ `C_LOG_2(`BLOCK_DEPTH * `KERNEL_SIZE )   -1 : 0] CntFetch;
wire  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE)   -1 : 0] AddrBaseWei0;
wire  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE)   -1 : 0] AddrBaseWei1;
wire  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE)   -1 : 0] AddrBaseWei2;
wire  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE)   -1 : 0] AddrBaseWei3;
wire  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE)   -1 : 0] AddrBaseWei4;
wire  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE)   -1 : 0] AddrBaseWei5;
wire  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE)   -1 : 0] AddrBaseWei6;
wire  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE)   -1 : 0] AddrBaseWei7;
wire  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE)   -1 : 0] AddrBaseWei8;
reg   [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE)   -1 : 0] AddrBaseWei;
reg  [ `DATA_WIDTH * `BLOCK_DEPTH * `KERNEL_SIZE-1 : 0] SeqWei;
wire Rdy_SeqWei;
reg Rdy_SeqWei_d;
//=====================================================================================================================
// Logic Design :
//=====================================================================================================================
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CTRLACT_FnhFrm_d <= 0;
    end else begin ////////////////////////////////
        CTRLACT_FnhFrm_d <= CTRLACT_FnhFrm;
    end
end

// 1st stage Pipeline

assign GBFFLGWEI_EnRd = CTRLWEI_PlsFetch && ~CTRLACT_FnhFrm;
// Pipeline start with a invalid GBFFLGWEI_DatRd; because DatRd after EnRd 1 clk;
// modifed to control by state
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        ValFlgWei <= 0;
    end else if ( CTRLACT_FnhFrm ) begin
        ValFlgWei <= 0;
    end else if ( CTRLWEI_PlsFetch ) begin
        ValFlgWei <= 1;
    end
end

// 2st stage Pipeline
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        FlgWei <= 0;
    end else if( CTRLACT_FnhFrm) begin
	FlgWei <= 0;
    end else if ( CTRLWEI_PlsFetch && ValFlgWei) begin
        FlgWei <= GBFFLGWEI_DatRd; //GBFFLGWEI_DatRd_d ??
    end
end
generate
  genvar i;
  for( i=0; i<`KERNEL_SIZE ; i=i+1) begin: AddrWeiGen
      always @ ( posedge clk or negedge rst_n ) begin
          if ( ~rst_n ) begin
              ValNumWei[i] <= 0;
           end else if(CTRLACT_FnhFrm || CTRLACT_FnhFrm_d) begin
                ValNumWei[i] <= 0;
          end else if ( CTRLWEI_PlsFetch &&ValFlgWei) begin
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
  end
endgenerate


// 3st stage Pipeline
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        DISWEIPEC_FlgWei <= 0;
    end else if ( CTRLWEI_PlsFetch ) begin
        DISWEIPEC_FlgWei <= FlgWei;
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        ValNumPEC <= 0;
    end else if(CTRLACT_FnhFrm) begin
        ValNumPEC <= 0;
    end else if ( CTRLWEI_PlsFetch ) begin
        ValNumPEC <= ValNumWei[0] + ValNumWei[1] + ValNumWei[2] + ValNumWei[3] + ValNumWei[4] +
                     ValNumWei[5] + ValNumWei[6] + ValNumWei[7] + ValNumWei[8] ;
        ValNumWei_d[0] <= ValNumWei[0];// reserved
        ValNumWei_d[1] <= ValNumWei[1];
        ValNumWei_d[2] <= ValNumWei[2];
        ValNumWei_d[3] <= ValNumWei[3];
        ValNumWei_d[4] <= ValNumWei[4];
        ValNumWei_d[5] <= ValNumWei[5];
        ValNumWei_d[6] <= ValNumWei[6];
        ValNumWei_d[7] <= ValNumWei[7];
        ValNumWei_d[8] <= ValNumWei[8];
        // DISWEIPEC_ValNumWei <= ValNumWei;
    end
end
// 3st stage Pipeline

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        GBFFLGWEI_DatRd_d <= 0;
    end else begin
        GBFFLGWEI_DatRd_d <= GBFFLGWEI_DatRd;
    end
end

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        ValNumRmn_lastFetch <= 0;
    end else if ( Rdy_SeqWei ) begin
        ValNumRmn_lastFetch <= AddrBaseWei;
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CntFetch <= 0;
    end else if ( CTRLWEI_PlsFetch|| Rdy_SeqWei ) begin // 3st stage Pipeline
        CntFetch <= 0;
    end else if ( GBFWEI_EnRd ) begin
        //CntFetch <= CntFetch + `KERNEL_SIZE;//
        CntFetch <= CntFetch + `PORT_DATAWIDTH/`DATA_WIDTH;//12B
    end
end

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
          GBFWEI_EnRd_d <= 0 ;
          GBFWEI_EnRd_dd<= 0;
    end else begin
         GBFWEI_EnRd_d <= GBFWEI_EnRd;
         GBFWEI_EnRd_dd<= GBFWEI_EnRd_d;
         GBFWEI_EnRd_ddd<= GBFWEI_EnRd_dd;
    end
end
// ****************************************************************************
// Get Wei to DISWEI  ( Separate module) FIFO?
// ****************************************************************************

//Long delay chain: ValNumWei -> ValNumPEC -> FnhFetch -> next_state ->PlsFetch
//fanout
// 1st stage
reg ValEnRd; // begin Fetch - DISWEI is ready
// always @ ( posedge clk or negedge rst_n ) begin
//     if ( !rst_n ) begin
//         ValEnRd <= 0;
//     end else if ( CTRLWEI_PlsFetch ) begin
//         ValEnRd <= 1;
//     end else if( Rdy_SeqWei) begin
//         ValEnRd <= 0;
//     end
// end
assign GBFWEI_EnRd = ( CntFetch + ValNumRmn_lastFetch) < ValNumPEC && ~CTRLACT_FnhFrm; // * 8 = << 3
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
          GBFWEI_AddrRd <= 0;
    end else if(CTRLACT_FnhFrm) begin
         GBFWEI_AddrRd <= 0;
    end else if ( GBFWEI_EnRd ) begin
         GBFWEI_AddrRd <= GBFWEI_AddrRd + 1;
    end
end

//2st stage
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        SeqWei <= 0;
    end else if(CTRLACT_FnhFrm) begin
        SeqWei <= 0;
    end else if ( GBFWEI_EnRd_d ) begin
        SeqWei <= {SeqWei, GBFWEI_DatRd};//
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        AddrBaseWei <= 0;
    end else if(CTRLACT_FnhFrm) begin
        AddrBaseWei<=0;
    end else if ( ~GBFWEI_EnRd && GBFWEI_EnRd_d ) begin
        AddrBaseWei <= ( CntFetch + ValNumRmn_lastFetch) - ValNumPEC;
        // AddrBaseWei <= ( CntFetch + ValNumRmn_lastFetch);
    end
end


assign AddrBaseWei0 = AddrBaseWei;//
assign AddrBaseWei1 = AddrBaseWei + ValNumWei_d[0];
assign AddrBaseWei2 = AddrBaseWei + ValNumWei_d[0] + ValNumWei_d[1];
assign AddrBaseWei3 = AddrBaseWei + ValNumWei_d[0] + ValNumWei_d[1] + ValNumWei_d[2];
assign AddrBaseWei4 = AddrBaseWei + ValNumWei_d[0] + ValNumWei_d[1] + ValNumWei_d[2] + ValNumWei_d[3];
assign AddrBaseWei5 = AddrBaseWei + ValNumWei_d[0] + ValNumWei_d[1] + ValNumWei_d[2] + ValNumWei_d[3] + ValNumWei_d[4];
assign AddrBaseWei6 = AddrBaseWei + ValNumWei_d[0] + ValNumWei_d[1] + ValNumWei_d[2] + ValNumWei_d[3] + ValNumWei_d[4] + ValNumWei_d[5];
assign AddrBaseWei7 = AddrBaseWei + ValNumWei_d[0] + ValNumWei_d[1] + ValNumWei_d[2] + ValNumWei_d[3] + ValNumWei_d[4] + ValNumWei_d[5] + ValNumWei_d[6];
assign AddrBaseWei8 = AddrBaseWei + ValNumWei_d[0] + ValNumWei_d[1] + ValNumWei_d[2] + ValNumWei_d[3] + ValNumWei_d[4] + ValNumWei_d[5] + ValNumWei_d[6] + ValNumWei_d[7];

reg [ `DATA_WIDTH * `BLOCK_DEPTH   - 1 : 0 ] SeqWei0;
reg [ `DATA_WIDTH * `BLOCK_DEPTH   - 1 : 0 ] SeqWei8;
//3st stage
//assign Rdy_SeqWei  = ~GBFWEI_EnRd_d

// always @ ( posedge clk or negedge rst_n ) begin
//     if ( !rst_n ) begin
//         Rdy_SeqWei <= 0;
//     end else if( CTRLWEI_PlsFetch) begin
//         Rdy_SeqWei <= 0;
//     end else if (  CntFetch + ValNumRmn_lastFetch >= ValNumPEC && ValNumPEC!=0) begin // ? CTRLACT_FnhFrM???
//         Rdy_SeqWei <= 1;
//     end else begin
//         Rdy_SeqWei <= 0;
//     end
// end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        CntFetch_SeqWei <= 0;
    end else if ( GBFWEI_EnRd_d  ) begin
        CntFetch_SeqWei <= CntFetch;//sys
    end
end
assign NumVal_Cur = CntFetch_SeqWei + ValNumRmn_lastFetch;
assign Rdy_SeqWei = NumVal_Cur >= ValNumPEC && ValNumPEC!=0;


// always @ ( posedge clk or negedge rst_n ) begin
//     if ( !rst_n ) begin
//         Rdy_SeqWei_d <= 0;
//     end else begin
//         Rdy_SeqWei_d <= Rdy_SeqWei;
//     end
// end

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        DISWEIPEC_Wei <= 0;
    end else if ( CTRLACT_FnhFrm) begin
        DISWEIPEC_Wei <= 0;
    //end else if ( ~GBFWEI_EnRd_dd && GBFWEI_EnRd_ddd) begin // paulse
    end else if ( Rdy_SeqWei) begin // paulse
        DISWEIPEC_Wei <= {  SeqWei[ `DATA_WIDTH * AddrBaseWei8 +: `DATA_WIDTH * `BLOCK_DEPTH],
                            SeqWei[ `DATA_WIDTH * AddrBaseWei7 +: `DATA_WIDTH * `BLOCK_DEPTH],
                            SeqWei[ `DATA_WIDTH * AddrBaseWei6 +: `DATA_WIDTH * `BLOCK_DEPTH],
                            SeqWei[ `DATA_WIDTH * AddrBaseWei5 +: `DATA_WIDTH * `BLOCK_DEPTH],
                            SeqWei[ `DATA_WIDTH * AddrBaseWei4 +: `DATA_WIDTH * `BLOCK_DEPTH],
                            SeqWei[ `DATA_WIDTH * AddrBaseWei3 +: `DATA_WIDTH * `BLOCK_DEPTH],
                            SeqWei[ `DATA_WIDTH * AddrBaseWei2 +: `DATA_WIDTH * `BLOCK_DEPTH],
                            SeqWei[ `DATA_WIDTH * AddrBaseWei1 +: `DATA_WIDTH * `BLOCK_DEPTH],
                            SeqWei[ `DATA_WIDTH * AddrBaseWei0 +: `DATA_WIDTH * `BLOCK_DEPTH] };
        SeqWei0 <= SeqWei[ `DATA_WIDTH * AddrBaseWei0 - 1 ];
        SeqWei8 <= SeqWei[ `DATA_WIDTH * AddrBaseWei8 - 1 -: `DATA_WIDTH * `BLOCK_DEPTH];
    end
end

assign DISWEI_RdyWei = Rdy_SeqWei;
//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================


endmodule
