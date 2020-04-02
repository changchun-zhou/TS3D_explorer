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
    output                                                          DISWEI_RdyFIFO   ,
    output wire  [ `DATA_WIDTH * `BLOCK_DEPTH * `KERNEL_SIZE -1 : 0] DISWEIPEC_Wei   ,// trans MSB and LSB
    output wire  [ 1 * `BLOCK_DEPTH * `KERNEL_SIZE           -1 : 0] DISWEIPEC_FlgWei,
    input                                                           GBFWEI_Val      , //valid
    input                                                           GBFWEI_BusyRd   ,
    output                                                          GBFWEI_EnRd     ,
    output reg  [ `GBFWEI_ADDRWIDTH                         -1 : 0] GBFWEI_AddrRd   ,
    input       [ `PORT_DATAWIDTH                         -1 : 0] GBFWEI_DatRd    ,
    input                                                           GBFFLGWEI_Val   , //valid
    output                                                          GBFFLGWEI_EnRd  ,
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
wire                                                     GBFWEI_EnRd_d;
reg                                                     GBFWEI_EnRd_dd;
reg                                                     GBFWEI_EnRd_ddd;
wire [ `C_LOG_2(`BLOCK_DEPTH * `KERNEL_SIZE )    -1 : 0] ValNumPEC;
reg [ `C_LOG_2(`BLOCK_DEPTH * `KERNEL_SIZE )    -1 : 0] NumVal_Cur;
reg [ `C_LOG_2(`BLOCK_DEPTH * `KERNEL_SIZE )    -1 : 0] CntFetch_SeqWei;
reg [ `GBFFLGWEI_DATAWIDTH                      -1 : 0] GBFFLGWEI_DatRd_d;
reg [ `GBFFLGWEI_DATAWIDTH                      -1 : 0] GBFFLGWEI_DatRd_dd;
reg                                                     ValFlgWei;
reg  [ 1 * `BLOCK_DEPTH * `KERNEL_SIZE           -1 : 0] FlgWei;
reg [ `C_LOG_2(`KERNEL_SIZE)                    -1 : 0] ValNumRmn_lastFetch;
reg   [ `C_LOG_2(`BLOCK_DEPTH * `KERNEL_SIZE )   -1 : 0] CntFetch;
wire  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE*`DATA_WIDTH)   -1 : 0] AddrBaseWei0;
wire  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE*`DATA_WIDTH)   -1 : 0] AddrBaseWei1;
wire  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE*`DATA_WIDTH)   -1 : 0] AddrBaseWei2;
wire  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE*`DATA_WIDTH)   -1 : 0] AddrBaseWei3;
wire  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE*`DATA_WIDTH)   -1 : 0] AddrBaseWei4;
wire  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE*`DATA_WIDTH)   -1 : 0] AddrBaseWei5;
wire  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE*`DATA_WIDTH)   -1 : 0] AddrBaseWei6;
wire  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE*`DATA_WIDTH)   -1 : 0] AddrBaseWei7;
wire  [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE*`DATA_WIDTH)   -1 : 0] AddrBaseWei8;
reg   [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE*`DATA_WIDTH)   -1 : 0] AddrBaseWei;
reg  [  `DATA_WIDTH * `BLOCK_DEPTH * `KERNEL_SIZE-1 : 0] SeqWei;
reg  [ `DATA_WIDTH * `BLOCK_DEPTH * `KERNEL_SIZE -1 : 0] Wei;
wire Rdy_SeqWei;
reg Rdy_SeqWei_d;
wire WEI_Val;
wire Req_WEI;
wire GBFFLGWEI_EnRd_d;
wire [ 3 - 1:0 ]state_d;
wire fifo_push,fifo_pop,fifo_empty,fifo_full;
wire [ 1 * `BLOCK_DEPTH * `KERNEL_SIZE + `DATA_WIDTH * `BLOCK_DEPTH * `KERNEL_SIZE -1 :0]fifo_in,fifo_out;
//=====================================================================================================================
// Logic Design :
//=====================================================================================================================
assign WEI_Val = GBFFLGWEI_Val && GBFWEI_Val;

// *********************************************************************
// FSM 
localparam IDLE = 3'b000;
localparam CHECK_FIFO_GBF = 3'b001;
localparam FETCH_FLAGWEI = 3'b010;
localparam WAIT_FETCH_FLAGWEI = 3'b110;
localparam FETCH_WEI = 3'b011;
localparam WATI_PUSH = 3'b100;
localparam PUSH = 3'b111;
reg [ 3 -1:0 ]state;
reg [ 3 -1:0 ]next_state;
always @(*) begin
    case ( state )
        IDLE :  if( 1'b1)
                    next_state <= CHECK_FIFO_GBF; //A network config a time
                else
                    next_state <= IDLE;
        CHECK_FIFO_GBF: if( CTRLACT_FnhFrm)
                    next_state <= IDLE;
                else if( !fifo_full && WEI_Val)
                    next_state <= FETCH_FLAGWEI;
                else
                    next_state <= CHECK_FIFO_GBF;
        FETCH_FLAGWEI: next_state <= WAIT_FETCH_FLAGWEI; // Fect flagwei         
        WAIT_FETCH_FLAGWEI: if( Req_WEI )//wait ValNumPEC compute to Req_WEI:whether FETCH_WEI
                    next_state <= FETCH_WEI;
                else
                    next_state <= WATI_PUSH;//directly push to fifo
        FETCH_WEI:  if( Req_WEI )//every time next_state is FETCH_WEI, try to fetch WEI
                        //next_state <= FETCH_FLAGWEI;
                        next_state <= FETCH_WEI;
                    else 
                        next_state <= WATI_PUSH;
        WATI_PUSH: 
                    next_state <= PUSH;
        PUSH:    next_state <= CHECK_FIFO_GBF;
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


assign GBFFLGWEI_EnRd = state == CHECK_FIFO_GBF && next_state == FETCH_FLAGWEI;//paulse

generate
  genvar i;
  for( i=0; i<`KERNEL_SIZE ; i=i+1) begin: AddrWeiGen
      always @ ( posedge clk or negedge rst_n ) begin
          if ( ~rst_n ) begin
              ValNumWei[`KERNEL_SIZE-1-i] <= 0;// 0 1 2 3 4 5 like
          end else if ( GBFFLGWEI_EnRd_d) begin
              ValNumWei[`KERNEL_SIZE-1-i] <= GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+ 0] + GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+ 8] + GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+16] + GBFFLGWEI_DatRd[`BLOCK_DEPTH*i+24] +
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



assign ValNumPEC = ValNumWei[0] + ValNumWei[1] + ValNumWei[2] + ValNumWei[3] + ValNumWei[4] +
                     ValNumWei[5] + ValNumWei[6] + ValNumWei[7] + ValNumWei[8] ;


always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        NumVal_Cur <= 0;
    end else if (CTRLACT_FnhFrm ) begin // 3st stage Pipeline
        NumVal_Cur <= 0;
    end else if ( state == WATI_PUSH )begin
        NumVal_Cur <= NumVal_Cur - ValNumPEC;
    end else if ( GBFWEI_EnRd ) begin
        NumVal_Cur <= NumVal_Cur + `PORT_DATAWIDTH/`DATA_WIDTH;//12B
    end
end

assign Req_WEI = NumVal_Cur < ValNumPEC; // * 8 = << 3
assign GBFWEI_EnRd = next_state == FETCH_WEI && ~GBFWEI_BusyRd;
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
        SeqWei <= {SeqWei, GBFWEI_DatRd};// left shift
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        AddrBaseWei <= 0;
    end else if(CTRLACT_FnhFrm) begin
        AddrBaseWei<=0;//////////////////////////////
    end else if ( next_state == WATI_PUSH ) begin
        AddrBaseWei <= NumVal_Cur - ValNumPEC;
    end
end

assign AddrBaseWei8 = AddrBaseWei;// PECMAC_Wei0
assign AddrBaseWei7 = AddrBaseWei + ValNumWei[8];//PECMAC_Wei0
assign AddrBaseWei6 = AddrBaseWei + ValNumWei[8] + ValNumWei[7];
assign AddrBaseWei5 = AddrBaseWei + ValNumWei[8] + ValNumWei[7] + ValNumWei[6];
assign AddrBaseWei4 = AddrBaseWei + ValNumWei[8] + ValNumWei[7] + ValNumWei[6] + ValNumWei[5];
assign AddrBaseWei3 = AddrBaseWei + ValNumWei[8] + ValNumWei[7] + ValNumWei[6] + ValNumWei[5] + ValNumWei[4];
assign AddrBaseWei2 = AddrBaseWei + ValNumWei[8] + ValNumWei[7] + ValNumWei[6] + ValNumWei[5] + ValNumWei[4] + ValNumWei[3];
assign AddrBaseWei1 = AddrBaseWei + ValNumWei[8] + ValNumWei[7] + ValNumWei[6] + ValNumWei[5] + ValNumWei[4] + ValNumWei[3] + ValNumWei[2];
assign AddrBaseWei0 = AddrBaseWei + ValNumWei[8] + ValNumWei[7] + ValNumWei[6] + ValNumWei[5] + ValNumWei[4] + ValNumWei[3] + ValNumWei[2] + ValNumWei[1];

wire [ `DATA_WIDTH*`BLOCK_DEPTH  -1 : 0]Wei0;
wire [ `DATA_WIDTH*`BLOCK_DEPTH  -1 : 0]Wei1;
wire [ `DATA_WIDTH*`BLOCK_DEPTH  -1 : 0]Wei2;
wire [ `DATA_WIDTH*`BLOCK_DEPTH  -1 : 0]Wei3;
wire [ `DATA_WIDTH*`BLOCK_DEPTH  -1 : 0]Wei4;
wire [ `DATA_WIDTH*`BLOCK_DEPTH  -1 : 0]Wei5;
wire [ `DATA_WIDTH*`BLOCK_DEPTH  -1 : 0]Wei6;
wire [ `DATA_WIDTH*`BLOCK_DEPTH  -1 : 0]Wei7;
wire [ `DATA_WIDTH*`BLOCK_DEPTH  -1 : 0]Wei8;
assign Wei0 = SeqWei[ AddrBaseWei0 << `C_LOG_2(`DATA_WIDTH) +: `DATA_WIDTH * `BLOCK_DEPTH];
assign Wei1 = SeqWei[ AddrBaseWei1 << `C_LOG_2(`DATA_WIDTH) +: `DATA_WIDTH * `BLOCK_DEPTH];
assign Wei2 = SeqWei[ AddrBaseWei2 << `C_LOG_2(`DATA_WIDTH) +: `DATA_WIDTH * `BLOCK_DEPTH];
assign Wei3 = SeqWei[ AddrBaseWei3 << `C_LOG_2(`DATA_WIDTH) +: `DATA_WIDTH * `BLOCK_DEPTH];
assign Wei4 = SeqWei[ AddrBaseWei4 << `C_LOG_2(`DATA_WIDTH) +: `DATA_WIDTH * `BLOCK_DEPTH];
assign Wei5 = SeqWei[ AddrBaseWei5 << `C_LOG_2(`DATA_WIDTH) +: `DATA_WIDTH * `BLOCK_DEPTH];
assign Wei6 = SeqWei[ AddrBaseWei6 << `C_LOG_2(`DATA_WIDTH) +: `DATA_WIDTH * `BLOCK_DEPTH];
assign Wei7 = SeqWei[ AddrBaseWei7 << `C_LOG_2(`DATA_WIDTH) +: `DATA_WIDTH * `BLOCK_DEPTH];
assign Wei8 = SeqWei[ AddrBaseWei8 << `C_LOG_2(`DATA_WIDTH) +: `DATA_WIDTH * `BLOCK_DEPTH];

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        Wei <= 0;
    end else if ( state==WATI_PUSH) begin // paulse wei0 wei1 wei2 ...wei8
        Wei <= {    Wei0,
                    Wei1,
                    Wei2,
                    Wei3,
                    Wei4,
                    Wei5,
                    Wei6,
                    Wei7,
                    Wei8 };
    end
end

assign fifo_push = state == PUSH;
assign fifo_in = {GBFFLGWEI_DatRd,Wei};
assign { DISWEIPEC_FlgWei, DISWEIPEC_Wei } = fifo_out;
assign fifo_pop = CTRLWEI_PlsFetch; 
assign DISWEI_RdyFIFO = !fifo_empty;

//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================
fifo_asic #(
    .DATA_WIDTH(1 * `BLOCK_DEPTH * `KERNEL_SIZE + 
      `DATA_WIDTH * `BLOCK_DEPTH * `KERNEL_SIZE  ),
    .ADDR_WIDTH(`FIFO_DISWEI_ADDRWIDTH ) // 4 PEC
    ) fifo_DISWEI(
    .clk ( clk ),
    .rst_n ( rst_n ),
    .Reset ( CTRLACT_FnhFrm),
    .push(fifo_push) ,
    .pop(fifo_pop ) ,
    .data_in( fifo_in),
    .data_out (fifo_out ),
    .empty(fifo_empty ),
    .full (fifo_full )
    );
Delay #(
        .NUM_STAGES(1),
        .DATA_WIDTH(1)
    ) Delay_GBFFLGWEI_EnRd (
        .CLK     (clk),
        .RESET_N (rst_n),
        .DIN     (GBFFLGWEI_EnRd),
        .DOUT    (GBFFLGWEI_EnRd_d)
    );
Delay #(
        .NUM_STAGES(1),
        .DATA_WIDTH(1)
    ) Delay_GBFWEI_EnRd (
        .CLK     (clk),
        .RESET_N (rst_n),
        .DIN     (GBFWEI_EnRd),
        .DOUT    (GBFWEI_EnRd_d)
    );
Delay #(
        .NUM_STAGES(1),
        .DATA_WIDTH(3)
    ) Delay_state (
        .CLK     (clk),
        .RESET_N (rst_n),
        .DIN     (state),
        .DOUT    (state_d)
    );
endmodule
