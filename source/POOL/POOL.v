//======================================================
// Copyright (C) 2020 By zhoucc
// All Rights Reserved
//======================================================
// Module : POOL
// Author : CC zhou
// Contact :
// Date : 22 .2 .2020
//=======================================================
// Description :
//========================================================
`include "../include/dw_params_presim.vh"
module POOL(
    input                                                                       clk     ,
    input                                                                       rst_n   ,
    input [ 5 + 1+`POOL_KERNEL_WIDTH                -1 : 0] CFG_POOL      ,
    input                                                                       POOL_Val,  // paulse
    output [ 1			                       -1 : 0] POOLPEL_EnRd,// 4 bit ID of PEB
    output [ `C_LOG_2(`LENPSUM * `LENPSUM)-1 : 0] POOLPEL_AddrRd,
    input  [ `PSUM_WIDTH * `NUMPEB                   -1 : 0] PELPOOL_Dat,
    output                                                                    GBFOFM_EnWr,
    output  reg[ `GBFOFM_ADDRWIDTH                 -1 : 0] GBFOFM_AddrWr,
    output [ `PORT_DATAWIDTH                        -1 : 0] GBFOFM_DatWr,
    output                                                                    GBFFLGOFM_EnWr,
    output reg  [ `GBFFLGOFM_ADDRWIDTH         - 1 :0 ] GBFFLGOFM_AddrWr,
    output  [ `PORT_DATAWIDTH                     - 1 : 0 ] GBFFLGOFM_DatWr

);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================



//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================
reg  [ `DATA_WIDTH                           -1 : 0 ] POOL_MEM [0:`NUMPEB -1]; // modify to 2D array
wire  [  5                                              -1     : 0 ] FL;
wire  [  5                                              -1     : 0 ] fl;

reg     [ 3                                              -1 : 0 ] cnt_poolx;
reg     [ 3                                              -1 : 0 ] cnt_pooly;
wire     [ `C_LOG_2(`LENPSUM * `LENPSUM) -1 : 0] AddrBasePEL;
wire                                                                        POOL_ValFrm;
wire    [ `C_LOG_2(`POOL_WIDTH)         -1 : 0 ] Stride;
reg     [ `C_LOG_2(`LENPSUM)                -1 : 0 ] AddrCol;
reg     [ `C_LOG_2(`LENPSUM*`LENPSUM)                -1 : 0 ] AddrBaseRow;
wire                                                                    FnhPoolRow;
wire                                                                    FnhPoolPat;
wire   [ `NUMPEB            -1 : 0] FLAG_PSUM;
wire [ `PSUM_WIDTH       - 1 : 0] ReLU [0: `NUMPEB -1];
wire                                              POOLPEL_EnRd_d;
wire [ `DATA_WIDTH * `NUMPEB - 1:0] FRMPOOL_DatWr;
wire [ `DATA_WIDTH * `NUMPEB - 1:0] FRMPOOL_DatRd;
wire [ `DATA_WIDTH * `NUMPEB - 1:0] DELTA_DatWr;
wire [ `DATA_WIDTH * `NUMPEB - 1:0] DELTA_DatRd;
reg [ `DATA_WIDTH                    - 1:0] SPRS_MEM [0 : `NUMPEB -1];
wire [ `NUMPEB                          - 1 :0] FLAG_MEM;

wire SIPOOFM_En;
wire SIPOFLGOFM_En;

wire DELTA_EnRd;
wire DELTA_EnWr;
reg [ `C_LOG_2(`LENPSUM*`LENPSUM)  -1:0] DELTA_AddrRd;
reg [ `C_LOG_2(`LENPSUM*`LENPSUM)  -1:0] DELTA_AddrWr;

wire FRMPOOL_EnRd;
wire FRMPOOL_EnWr;
reg [`C_LOG_2(`LENPSUM/2*`LENPSUM/2)      - 1:0]FRMPOOL_AddrRd;
reg [`C_LOG_2(`LENPSUM/2*`LENPSUM/2)      - 1:0]FRMPOOL_AddrWr;
//=====================================================================================================================
// Logic Design :
//=====================================================================================================================
// FSM : ACT is ever gotten or not

localparam IDLE0     = 3'b000;
localparam IDLE     = 3'b100;
localparam RDPEL   = 3'b001;
localparam FRMPOOLDELTA   = 3'b011;
localparam DELTA  = 3'b010;
//localparam RDRAM    = 3'b100;
//localparam WRRAM    = 3'b101;

reg [ 3 - 1 : 0  ] next_state;
reg [ 3 - 1 : 0  ] state;
wire [ 3 - 1 : 0  ] state_d;
wire [ 3 - 1 : 0  ] state_dd;

always @(*) begin
    case (state)
      IDLE0  :   if ( POOL_Val )
                    next_state <= IDLE;
                else
                    next_state <= IDLE0;  // avoid Latch
    IDLE: next_state <= RDPEL;
      RDPEL: if(FnhPoolPat)
                        next_state <= IDLE0;
                 else  if (  cnt_poolx==Stride && cnt_pooly==Stride)
                         if(POOL_ValFrm)
                            next_state <= FRMPOOLDELTA;
                        else
                            next_state <= DELTA;
                else
                    next_state <= RDPEL;
      FRMPOOLDELTA: if( 1'b1)
                    next_state <= IDLE;
                    else
                           next_state <= FRMPOOLDELTA;

      default: next_state <= IDLE;
    endcase
end

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end


assign {fl, POOL_ValFrm, Stride} = CFG_POOL;
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        AddrCol <= 0;
    end else if ( FnhPoolRow)begin //////////////////////////////////
        AddrCol <= 0;
    end else if ( state == FRMPOOLDELTA  ) begin
       AddrCol  <= AddrCol + Stride; // Stride ==3,  read PELPOOL_DatRd twice
    end
end
// Stride = 2 or 3 only
assign FnhPoolRow = AddrCol + Stride > `LENPSUM;  //
assign FnhPoolPat = AddrBaseRow + `LENPSUM * Stride > `LENPSUM * `LENPSUM -1;
assign AddrBasePEL = AddrBaseRow + AddrCol;
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        AddrBaseRow <= 0;
    end else if ( FnhPoolPat ) begin
         AddrBaseRow <= 0;
    end else if( FnhPoolRow ) begin
        AddrBaseRow <= AddrBaseRow + `LENPSUM * Stride;
    end
end

assign  POOLPEL_AddrRd = AddrBasePEL + cnt_poolx + `LENPSUM * cnt_pooly;

always @ ( posedge clk or negedge rst_n  ) begin
    if ( ! rst_n) begin
        cnt_poolx <= 0;
    end else if (  cnt_poolx == Stride - 1 ) begin
        cnt_poolx <= 0;
    end else if (  POOLPEL_EnRd &&  cnt_poolx < Stride - 1)begin
        cnt_poolx <= cnt_poolx + 1;
    end
end

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        cnt_pooly <= 0;
    end else if ( cnt_pooly == Stride- 1 ) begin
        cnt_pooly <= 0;
    end else if ( cnt_poolx == Stride - 1  )begin
        cnt_pooly <= cnt_pooly + 1;
    end
end

assign FL = (fl > 5'd21)? 5'd21 : fl;
generate
  genvar i;
  for(i=0;i<`NUMPEB; i=i+1) begin:POOL_PEB
// ReLU
        assign FLAG_PSUM[i] = PELPOOL_Dat[`PSUM_WIDTH * (i+1)  - 1];
        assign ReLU[i]  =  FLAG_PSUM[i] ?  'b0 : PELPOOL_Dat[ `PSUM_WIDTH *  i  +: `PSUM_WIDTH];
//

  // Pooling 1x2x2
        always @ ( posedge clk or negedge rst_n ) begin
          if ( !rst_n ) begin
             POOL_MEM[i] <= 0;
          end else if ( state == IDLE ) begin
             POOL_MEM[i] <= 0;
         end else if(  POOLPEL_EnRd_d)begin
             POOL_MEM[i]   <= (POOL_MEM[i]  >  ReLU[i] )? POOL_MEM[i] :{ 1'b0 , ReLU[i][FL + 6 -: 7] } ;
          end
        end
    // Pooling 2x1x1
    assign FRMPOOL_DatWr[`DATA_WIDTH*i +: `DATA_WIDTH] = ( POOL_MEM[i] > FRMPOOL_DatRd[`DATA_WIDTH*i +: `DATA_WIDTH] || ~POOL_ValFrm)? POOL_MEM[i] :FRMPOOL_DatRd[`DATA_WIDTH*i +: `DATA_WIDTH];
    assign DELTA_DatWr[`DATA_WIDTH*i +: `DATA_WIDTH] = $signed(FRMPOOL_DatWr[`DATA_WIDTH*i +: `DATA_WIDTH]) - $signed(DELTA_DatRd[ `DATA_WIDTH * (`NUMPEB - i )  -1 -: `DATA_WIDTH]);
        always @ ( posedge clk or negedge rst_n ) begin
            if ( !rst_n ) begin
                SPRS_MEM[i] <= 0;
            end else if ( state_d ==FRMPOOLDELTA ) begin
                SPRS_MEM[i] <= DELTA_DatWr[`DATA_WIDTH*i +: `DATA_WIDTH] ;
            end
        end
        assign FLAG_MEM[i] = |SPRS_MEM[`NUMPEB-1-i];
      end
endgenerate
reg     [ `C_LOG_2(`NUMPEB)   - 1:0]SPRS_Addr;
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        SPRS_Addr <= 0;
   end else if ( state == IDLE ) begin
        SPRS_Addr <= `NUMPEB -1;
    end else if (  |SPRS_Addr) begin
        SPRS_Addr <= SPRS_Addr - 1 ;
    end
end

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        GBFOFM_AddrWr <= 0;
    end else if (  GBFOFM_EnWr) begin
        GBFOFM_AddrWr <= GBFOFM_AddrWr + 1;
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        GBFFLGOFM_AddrWr <= 0;
    end else if ( GBFFLGOFM_EnWr ) begin
        GBFFLGOFM_AddrWr <= GBFFLGOFM_AddrWr + 1;
    end
end

assign FRMPOOL_EnWr = state == FRMPOOLDELTA;
assign SIPOOFM_En = FLAG_MEM[SPRS_Addr];
assign SIPOFLGOFM_En = state_dd==FRMPOOLDELTA;
//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================

// sipo

sipo
#( // INPUT PARAMETERS
    .DATA_IN_WIDTH(`DATA_WIDTH),
   .DATA_OUT_WIDTH (`PORT_DATAWIDTH) // 12*
)SIPO_OFM( // PORTS
    .clk(clk),
    .rst_n(rst_n),
    .enable(SIPOOFM_En),
    .data_in(SPRS_MEM[SPRS_Addr]),
    .ready( ),
    .data_out(GBFOFM_DatWr),
    .out_valid(GBFOFM_EnWr)   // output must be gotten immediately
);
sipo
#( // INPUT PARAMETERS
    .DATA_IN_WIDTH(`NUMPEB),
   .DATA_OUT_WIDTH (`PORT_DATAWIDTH) // 12*
)SIPO_FLGOFM( // PORTS
    .clk(clk),
    .rst_n(rst_n),
    .enable(SIPOFLGOFM_En),
    .data_in(FLAG_MEM),
    .ready( ),
    .data_out(GBFFLGOFM_DatWr),
    .out_valid(GBFFLGOFM_EnWr)   // output must be gotten immediately
);
// ==================================================================

assign FRMPOOL_EnRd = state == FRMPOOLDELTA && POOL_ValFrm;
assign FRMPOOL_EnWr = state_d == FRMPOOLDELTA && ~POOL_ValFrm;
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        FRMPOOL_AddrRd <= 0;
    end else if ( FRMPOOL_AddrRd == `LENPSUM -1 ) begin
         FRMPOOL_AddrRd <= 0;
    end else if (FRMPOOL_EnRd ) begin
        FRMPOOL_AddrRd <= FRMPOOL_AddrRd + 1;
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        FRMPOOL_AddrWr <= 0;
    end else if ( FRMPOOL_AddrWr == `LENPSUM -1 ) begin
         FRMPOOL_AddrWr <= 0;
    end else if (FRMPOOL_EnWr ) begin
        FRMPOOL_AddrWr <= FRMPOOL_AddrWr + 1;
    end
end
// reuse
SRAM_DUAL #(
        .SRAM_DEPTH_BIT(`C_LOG_2(`LENPSUM/2*`LENPSUM/2)),
        .SRAM_WIDTH(`DATA_WIDTH * `NUMPEB),
        .INIT_IF ("yes"),
        .INIT_FILE ("")
    ) RAM_FRMPOOL(
        .clk      ( clk         ),
        .addr_r   ( FRMPOOL_AddrRd     ),
        .addr_w   ( FRMPOOL_AddrWr     ),
        .read_en  ( FRMPOOL_EnRd       ),
        .write_en ( FRMPOOL_EnWr       ),
        .data_in  ( FRMPOOL_DatWr      ),
        .data_out ( FRMPOOL_DatRd     )
    );

assign DELTA_EnRd = state == FRMPOOLDELTA;
assign DELTA_EnWr = state_d == FRMPOOLDELTA;
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        DELTA_AddrRd <= 0;
    end else if ( DELTA_AddrRd == `LENPSUM -1 ) begin
         DELTA_AddrRd <= 0;
    end else if (DELTA_EnRd ) begin
        DELTA_AddrRd <= DELTA_AddrRd + 1;
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        DELTA_AddrWr <= 0;
    end else if ( DELTA_AddrWr == `LENPSUM -1 ) begin
         DELTA_AddrWr <= 0;
    end else if (DELTA_EnWr ) begin
        DELTA_AddrWr <= DELTA_AddrWr + 1;
    end
end
SRAM_DUAL #(
        .SRAM_DEPTH_BIT(`C_LOG_2(`LENPSUM*`LENPSUM)),
        .SRAM_WIDTH(`DATA_WIDTH * `NUMPEB),
        .INIT_IF ("yes"),
        .INIT_FILE ("")
    ) RAM_DELTA (
        .clk      ( clk         ),
        .addr_r   ( DELTA_AddrRd     ),
        .addr_w   ( DELTA_AddrWr     ),
        .read_en  ( DELTA_EnRd       ),
        .write_en ( DELTA_EnWr       ),
        .data_in  (  DELTA_DatWr      ),
        .data_out ( DELTA_DatRd      )
    );

Delay #(
    .NUM_STAGES(1),
    .DATA_WIDTH(1)
    )Delay_POOLPEL_EnRd_d
    (
        .CLK(clk),
        .RESET_N(rst_n),
        .DIN(POOLPEL_EnRd),
        .DOUT(POOLPEL_EnRd_d)
        );
Delay #(
    .NUM_STAGES(1),
    .DATA_WIDTH(3)
    )Delay_state_d
    (
        .CLK(clk),
        .RESET_N(rst_n),
        .DIN(state),
        .DOUT(state_d)
        );
Delay #(
    .NUM_STAGES(2),
    .DATA_WIDTH(3)
    )Delay_state_dd
    (
        .CLK(clk),
        .RESET_N(rst_n),
        .DIN(state),
        .DOUT(state_dd)
        );
endmodule
