//======================================================
// Copyright (C) 2019 By zhoucc
// All Rights Reserved
//======================================================
// Module : PEB
// Author : CC zhou
// Contact : 
// Date : 4 .1 .2019
//=======================================================
// Description : Distribute SRAM For 3 PEC
//========================================================
`include "../include/dw_params_presim.vh"
module PEB #(
    parameter PSUM_WIDTH = (`DATA_WIDTH *2 + `C_LOG_2(`BLOCK_DEPTH) + 2 )
    )(
    input                                                   clk     ,
    input                                                   rst_n   ,
    input                                                   CTRLPEB_FrtBlk      ,
    input                                                   CTRLPEB_FnhFrm,
    output                                                  NXTPEB_FrtBlk,

    input                                                   POOLPEB_EnRd,
    input  [ `C_LOG_2(`LENPSUM)                     -1 : 0] POOLPEB_AddrRd,
    output [ PSUM_WIDTH * `LENPSUM                  -1 : 0] PEBPOOL_Dat,

    input                                                   CTRLWEIPEC_RdyWei0  ,
    input                                                   CTRLWEIPEC_RdyWei1  ,
    input                                                   CTRLWEIPEC_RdyWei2  ,
    output                                                  PECCTRLWEI_GetWei0  ,//=CTRLWEIPEC_RdyWei paulse
    output                                                  PECCTRLWEI_GetWei1  ,//=CTRLWEIPEC_RdyWei paulse
    output                                                  PECCTRLWEI_GetWei2  ,//=CTRLWEIPEC_RdyWei paulse

    input [`DATA_WIDTH * `BLOCK_DEPTH * `KERNEL_SIZE -1 :0] DISWEIPEC_Wei,
    input [1 * `BLOCK_DEPTH * `KERNEL_SIZE          -1 : 0] DISWEIPEC_FlgWei,
    // input [`C_LOG_2( `BLOCK_DEPTH) * `KERNEL_SIZE   -1 : 0] DISWEIPEC_ValNumWei,
    // input [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE)   - 1 : 0 ] DISWEI_AddrBase,

    input                                                   LSTPEC_FrtActRow0   ,// because read and write simultaneously
    input                                                   LSTPEC_LstActRow0   ,//
    input                                                   LSTPEC_LstActBlk0   ,//
    input                                                   LSTPEC_ValPsum0     ,
    input                                                   LSTPEB_RdyAct,
    output                                                  LSTPEB_GetAct,
    input[ `BLOCK_DEPTH                             -1 : 0] LSTPEB_FlgAct,
    input[ `DATA_WIDTH * `BLOCK_DEPTH               -1 : 0] LSTPEB_Act,

    output                                                  NXTPEC_FrtActRow2   ,
    output                                                  NXTPEC_LstActRow2   ,
    output                                                  NXTPEC_LstActBlk2   ,
    output                                                  NXTPEC_ValPsum2     ,
    output                                                  NXTPEB_RdyAct,
    input                                                   NXTPEB_GetAct,
    output[ `BLOCK_DEPTH                            -1 : 0] NXTPEB_FlgAct,
    output[ `DATA_WIDTH * `BLOCK_DEPTH               -1 : 0] NXTPEB_Act    

);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================





//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================
        
// wire                                        PEBPEC_FnhFrm;

reg                                         FlgRAM2;              
wire                                        NXTPEC_FrtActRow0;
wire                                        NXTPEC_LstActRow0;
wire                                        NXTPEC_LstActBlk0;
wire                                        NXTPEC_RdyAct0;
wire                                        NXTPEC_GetAct0;
wire                                        NXTPEC_FrtActRow1;
wire                                        NXTPEC_LstActRow1;
wire                                        NXTPEC_LstActBlk1;
wire                                        NXTPEC_RdyAct1;
wire                                        NXTPEC_GetAct1;

wire [ `DATA_WIDTH * `BLOCK_DEPTH           -1 : 0] PECMAC_Act0;
wire [ `DATA_WIDTH * `BLOCK_DEPTH           -1 : 0] PECMAC_Act1;
wire [ `BLOCK_DEPTH                         -1 : 0] NXTPEB_FlgAct0;
wire [ `BLOCK_DEPTH                         -1 : 0] NXTPEB_FlgAct1;


wire                                        PECRAM_EnWr0;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] PECRAM_AddrWr0;
wire [  PSUM_WIDTH * `LENPSUM     - 1 : 0 ] PECRAM_DatWr0;
wire                                        PECRAM_EnRd0;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] PECRAM_AddrRd0;
wire [ PSUM_WIDTH * `LENPSUM      - 1 : 0 ] RAMPEC_DatRd0; 

wire                                        PECRAM_EnWr1;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] PECRAM_AddrWr1;
wire [  PSUM_WIDTH * `LENPSUM     - 1 : 0 ] PECRAM_DatWr1;
wire                                        PECRAM_EnRd1;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] PECRAM_AddrRd1;
wire [ PSUM_WIDTH * `LENPSUM      - 1 : 0 ] RAMPEC_DatRd1; 

wire                                        PECRAM_EnWr2;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] PECRAM_AddrWr2;
wire [  PSUM_WIDTH * `LENPSUM     - 1 : 0 ] PECRAM_DatWr2;

wire                                        PECRAM_EnRd2;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] PECRAM_AddrRd2;
wire [ PSUM_WIDTH * `LENPSUM      - 1 : 0 ] RAMPEC_DatRd2; 

wire [  PSUM_WIDTH * `LENPSUM     - 1 : 0 ] PECRAM_DatWr3;
wire [ PSUM_WIDTH * `LENPSUM      - 1 : 0 ] RAMPEC_DatRd3; 

wire                                        EnWr0;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] AddrWr0;
wire [  PSUM_WIDTH * `LENPSUM     - 1 : 0 ] DatWr0;
wire                                        EnRd0;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] AddrRd0;
wire [ PSUM_WIDTH * `LENPSUM      - 1 : 0 ] DatRd0; 

wire                                        EnWr1;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] AddrWr1;
wire [  PSUM_WIDTH * `LENPSUM     - 1 : 0 ] DatWr1;
wire                                        EnRd1;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] AddrRd1;
wire [ PSUM_WIDTH * `LENPSUM      - 1 : 0 ] DatRd1;

wire                                        EnWr2;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] AddrWr2;
wire [  PSUM_WIDTH * `LENPSUM     - 1 : 0 ] DatWr2;
wire                                        EnRd2;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] AddrRd2;
wire [ PSUM_WIDTH * `LENPSUM      - 1 : 0 ] DatRd2;

wire                                        EnWr3;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] AddrWr3;
wire [  PSUM_WIDTH * `LENPSUM     - 1 : 0 ] DatWr3;
wire                                        EnRd3;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] AddrRd3;
wire [ PSUM_WIDTH * `LENPSUM      - 1 : 0 ] DatRd3;

wire                                        NXTPEC_ValPsum0;
wire                                        NXTPEC_ValPsum1;

//=====================================================================================================================
// Logic Design :
//=====================================================================================================================
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        FlgRAM2 <= 1;
    end else if ( CTRLPEB_FnhFrm ) begin
        FlgRAM2 <= ~FlgRAM2;
    end
end



// Fetch LAST SRAM when new frame comes ( frtblk of new frame)
// only read 
assign EnWr0         = PECRAM_EnWr0     ;
assign AddrWr0       = PECRAM_AddrWr0   ;
assign DatWr0        = PECRAM_DatWr0    ;
assign EnRd0         = CTRLPEB_FrtBlk ? 0 : PECRAM_EnRd0     ;
assign AddrRd0       = CTRLPEB_FrtBlk ? 0 : PECRAM_AddrRd0   ;
assign RAMPEC_DatRd0 = CTRLPEB_FrtBlk ? 0 : DatRd0    ; //after first block, the first data is x because of EnRd is 0 before.

assign EnWr1         = PECRAM_EnWr1     ;
assign AddrWr1       = PECRAM_AddrWr1   ;
assign DatWr1        = PECRAM_DatWr1    ;
assign EnRd1         = CTRLPEB_FrtBlk ? PECRAM_EnRd0      : PECRAM_EnRd1     ;
assign AddrRd1       = CTRLPEB_FrtBlk ? PECRAM_AddrRd0    : PECRAM_AddrRd1   ;
assign RAMPEC_DatRd1 = CTRLPEB_FrtBlk ? DatRd0     : DatRd1           ;

// Ping   
assign EnWr2         = FlgRAM2 ? ( PECRAM_EnWr2     ) : 0               ;
assign AddrWr2       = FlgRAM2 ? ( PECRAM_AddrWr2   ) : 0               ;
assign DatWr2        = FlgRAM2 ? ( PECRAM_DatWr2    ) : 0               ;
assign EnRd2         = FlgRAM2 ? ( CTRLPEB_FrtBlk ? PECRAM_EnRd1      : PECRAM_EnRd2     ) : POOLPEB_EnRd    ;
assign AddrRd2       = FlgRAM2 ? ( CTRLPEB_FrtBlk ? PECRAM_AddrRd1    : PECRAM_AddrRd2   ) : POOLPEB_AddrRd  ;

assign RAMPEC_DatRd2 = CTRLPEB_FrtBlk ? DatRd1 : FlgRAM2 ? DatRd2  : DatRd3     ;

// Pong
assign EnWr3         =~FlgRAM2 ? ( PECRAM_EnWr2     ) : 0               ;
assign AddrWr3       =~FlgRAM2 ? ( PECRAM_AddrWr2   ) : 0               ;
assign DatWr3        =~FlgRAM2 ? ( PECRAM_DatWr2    ) : 0               ;
assign EnRd3         =~FlgRAM2 ? ( CTRLPEB_FrtBlk ? PECRAM_EnRd1      : PECRAM_EnRd2     ) : POOLPEB_EnRd    ;
assign AddrRd3       =~FlgRAM2 ? ( CTRLPEB_FrtBlk ? PECRAM_AddrRd1    : PECRAM_AddrRd2   ) : POOLPEB_AddrRd  ;

assign PEBPOOL_Dat   =~FlgRAM2 ? DatRd2 : DatRd3 ;

//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================


// open / close EnPEC
// EnPEC == 1
PEC PEC0 
    (
        .clk               (clk),
        .rst_n             (rst_n),
        .CTRLWEIPEC_RdyWei (CTRLWEIPEC_RdyWei0),
        .PECCTRLWEI_GetWei (PECCTRLWEI_GetWei0),
        .DISWEIPEC_Wei     (DISWEIPEC_Wei),
        .DISWEIPEC_FlgWei  (DISWEIPEC_FlgWei),
        // .DISWEIPEC_ValNumWei(DISWEIPEC_ValNumWei),
        // .DISWEI_AddrBase  ( DISWEI_AddrBase ),
        .LSTPEC_FrtActRow  (LSTPEC_FrtActRow0),
        .LSTPEC_LstActRow  (LSTPEC_LstActRow0),
        .LSTPEC_LstActBlk  (LSTPEC_LstActBlk0),
        .LSTPEC_ValPsum    (LSTPEC_ValPsum0),
        .NXTPEC_FrtActRow  (NXTPEC_FrtActRow0),
        .NXTPEC_LstActRow  (NXTPEC_LstActRow0),
        .NXTPEC_LstActBlk  (NXTPEC_LstActBlk0),
        .NXTPEC_ValPsum    (NXTPEC_ValPsum0),
        .LSTPEC_RdyAct     (LSTPEB_RdyAct),
        .LSTPEC_GetAct     (LSTPEB_GetAct),
        .PEBPEC_FlgAct     (LSTPEB_FlgAct),
        .PEBPEC_Act        (LSTPEB_Act),
        .NXTPEC_RdyAct     (NXTPEC_RdyAct0),
        .NXTPEC_GetAct     (NXTPEC_GetAct0),
        .PECMAC_Act        (PECMAC_Act0 ),
        .PECMAC_FlgAct     (NXTPEB_FlgAct0),
        .PECRAM_EnWr       (PECRAM_EnWr0  ),
        .PECRAM_AddrWr     (PECRAM_AddrWr0),
        .PECRAM_DatWr      (PECRAM_DatWr0 ),
        .PECRAM_EnRd       (PECRAM_EnRd0  ),
        .PECRAM_AddrRd     (PECRAM_AddrRd0),
        .RAMPEC_DatRd      (RAMPEC_DatRd0 )
    );

// EnPEC == 0 when frame0
PEC PEC1
    (
        .clk               (clk),
        .rst_n             (rst_n),
        .CTRLWEIPEC_RdyWei (CTRLWEIPEC_RdyWei1),
        .PECCTRLWEI_GetWei (PECCTRLWEI_GetWei1),
        .DISWEIPEC_Wei     (DISWEIPEC_Wei),
        .DISWEIPEC_FlgWei  (DISWEIPEC_FlgWei),
        // .DISWEIPEC_ValNumWei(DISWEIPEC_ValNumWei),
        // .DISWEI_AddrBase ( DISWEI_AddrBase),
        .LSTPEC_FrtActRow  (NXTPEC_FrtActRow0),
        .LSTPEC_LstActRow  (NXTPEC_LstActRow0),
        .LSTPEC_LstActBlk  (NXTPEC_LstActBlk0),
        .LSTPEC_ValPsum    (NXTPEC_ValPsum0),
        .NXTPEC_FrtActRow  (NXTPEC_FrtActRow1),
        .NXTPEC_LstActRow  (NXTPEC_LstActRow1),
        .NXTPEC_LstActBlk  (NXTPEC_LstActBlk1),
        .NXTPEC_ValPsum    (NXTPEC_ValPsum1),
        .LSTPEC_RdyAct     (NXTPEC_RdyAct0),
        .LSTPEC_GetAct     (NXTPEC_GetAct0),
        .PEBPEC_FlgAct     (NXTPEB_FlgAct0),
        .PEBPEC_Act        (PECMAC_Act0),
        .NXTPEC_RdyAct     (NXTPEC_RdyAct1),
        .NXTPEC_GetAct     (NXTPEC_GetAct1),
        .PECMAC_Act        (PECMAC_Act1 ),
        .PECMAC_FlgAct     (NXTPEB_FlgAct1),
        .PECRAM_EnWr       (PECRAM_EnWr1),
        .PECRAM_AddrWr     (PECRAM_AddrWr1),
        .PECRAM_DatWr      (PECRAM_DatWr1),
        .PECRAM_EnRd       (PECRAM_EnRd1),
        .PECRAM_AddrRd     (PECRAM_AddrRd1),
        .RAMPEC_DatRd      (RAMPEC_DatRd1)
    );
// EnPEC == 0 when frame0/1
PEC PEC2
    (
        .clk               (clk),
        .rst_n             (rst_n),
        .CTRLWEIPEC_RdyWei (CTRLWEIPEC_RdyWei2),
        .PECCTRLWEI_GetWei (PECCTRLWEI_GetWei2),
        .DISWEIPEC_Wei     (DISWEIPEC_Wei),
        .DISWEIPEC_FlgWei  (DISWEIPEC_FlgWei),
        // .DISWEIPEC_ValNumWei(DISWEIPEC_ValNumWei),
        // .DISWEI_AddrBase  (DISWEI_AddrBase),
        .LSTPEC_FrtActRow  (NXTPEC_FrtActRow1),
        .LSTPEC_LstActRow  (NXTPEC_LstActRow1),
        .LSTPEC_LstActBlk  (NXTPEC_LstActBlk1),
        .LSTPEC_ValPsum    (NXTPEC_ValPsum1),
        .NXTPEC_FrtActRow  (NXTPEC_FrtActRow2),
        .NXTPEC_LstActRow  (NXTPEC_LstActRow2),
        .NXTPEC_LstActBlk  (NXTPEC_LstActBlk2),
        .NXTPEC_ValPsum    (NXTPEC_ValPsum2),
        .LSTPEC_RdyAct     (NXTPEC_RdyAct1),
        .LSTPEC_GetAct     (NXTPEC_GetAct1),
        .PEBPEC_FlgAct     (NXTPEB_FlgAct1),
        .PEBPEC_Act        (PECMAC_Act1),
        .NXTPEC_RdyAct     (NXTPEB_RdyAct),
        .NXTPEC_GetAct     (NXTPEB_GetAct),
        .PECMAC_FlgAct     (NXTPEB_FlgAct),
        .PECMAC_Act        (NXTPEB_Act ),
        .PECRAM_EnWr       (PECRAM_EnWr2),
        .PECRAM_AddrWr     (PECRAM_AddrWr2),
        .PECRAM_DatWr      (PECRAM_DatWr2),
        .PECRAM_EnRd       (PECRAM_EnRd2),
        .PECRAM_AddrRd     (PECRAM_AddrRd2),
        .RAMPEC_DatRd      (RAMPEC_DatRd2)
    );


SRAM_DUAL #(
        .SRAM_DEPTH_BIT(`C_LOG_2(`LENPSUM)),   
        .SRAM_WIDTH(PSUM_WIDTH * `LENPSUM)
    ) RAM_PEC0 (
        .clk      ( clk         ),
        .addr_r   ( AddrRd0     ),
        .addr_w   ( AddrWr0     ),
        .read_en  ( EnRd0       ),
        .write_en ( EnWr0       ),
        .data_in  ( PECRAM_DatWr0      ),
        .data_out ( DatRd0      )
    );
SRAM_DUAL #(
        .SRAM_DEPTH_BIT(`C_LOG_2(`LENPSUM)),   
        .SRAM_WIDTH(PSUM_WIDTH * `LENPSUM)
    ) RAM_PEC1 (
        .clk      ( clk         ),
        .addr_r   ( AddrRd1     ),
        .addr_w   ( AddrWr1     ),
        .read_en  ( EnRd1       ),
        .write_en ( EnWr1       ),
        .data_in  ( PECRAM_DatWr1      ),
        .data_out ( DatRd1      )
    );
SRAM_DUAL #(
         .SRAM_DEPTH_BIT(`C_LOG_2(`LENPSUM)),   
        .SRAM_WIDTH(PSUM_WIDTH * `LENPSUM) 
    ) RAM_PEC2 (
        .clk      ( clk         ),
        .addr_r   ( AddrRd2     ),
        .addr_w   ( AddrWr2     ),
        .read_en  ( EnRd2       ),
        .write_en ( EnWr2       ),
        .data_in  ( PECRAM_DatWr2      ),
        .data_out ( DatRd2      )
    );

SRAM_DUAL #(
        .SRAM_DEPTH_BIT(`C_LOG_2(`LENPSUM)),   
        .SRAM_WIDTH(PSUM_WIDTH * `LENPSUM)
    ) RAM_PEC3 (
        .clk      ( clk         ),
        .addr_r   ( AddrRd3     ),
        .addr_w   ( AddrWr3     ),
        .read_en  ( EnRd3       ),
        .write_en ( EnWr3       ),
        .data_in  ( PECRAM_DatWr3      ),
        .data_out ( DatRd3      )
    );

endmodule