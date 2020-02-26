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
module PEB (
    input                                                   clk     ,
    input                                                   rst_n   ,
    input                                                   CTRLPEB_FrtBlk      ,
    input                                                   CTRLPEB_FnhFrm,
  //  output                                                  NXTPEB_FrtBlk,

    input                                                   POOLPEB_EnRd,
    input  [ `C_LOG_2(`LENPSUM*`LENPSUM)                     -1 : 0] POOLPEB_AddrRd,
    output [ `PSUM_WIDTH                   -1 : 0] PEBPOOL_Dat,

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
    input [ `BUSPEB_WIDTH                       - 1:0 ] INBUS_LSTPEB,
    input                                                               INBUS_NXTPEB,
    output [ `BUSPEB_WIDTH                  - 1 : 0 ] OUTBUS_NXTPEB,
    output                                                          OUTBUS_LSTPEB
/*
    input                                                   LSTPEC_FrtActRow0   ,// because read and write simultaneously
    input                                                   LSTPEC_LstActRow0   ,//
    input                                                   LSTPEC_LstActBlk0   ,//
    input                                                   LSTPEC_ValPsum0     ,
    input                                                   LSTPEC_ValCol,
    input                                                   LSTPEB_RdyAct,
    input[ `BLOCK_DEPTH                             -1 : 0] LSTPEB_FlgAct,
    input[ `DATA_WIDTH * `BLOCK_DEPTH               -1 : 0] LSTPEB_Act,
    output                                                  LSTPEB_GetAct,

    output                                                  NXTPEC_FrtActRow2   ,
    output                                                  NXTPEC_LstActRow2   ,
    output                                                  NXTPEC_LstActBlk2   ,
    output                                                  NXTPEC_ValPsum2     ,
    output                                                  NXTPEC_ValCol,
    output                                                  NXTPEB_RdyAct,
    output[ `BLOCK_DEPTH                            -1 : 0] NXTPEB_FlgAct,
    output[ `DATA_WIDTH * `BLOCK_DEPTH               -1 : 0] NXTPEB_Act  ,
    input                                                   NXTPEB_GetAct
*/
);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================





//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================

// wire                                        PEBPEC_FnhFrm;
//wire [`BUSPEC_WIDTH            -1 : 0 ] INBUS_LSTPEB;
//wire [`BUSPEC_WIDTH            -1 : 0 ] OUTBUS_NXTPEB;
//wire                                   INBUS_NXTPEB;
//wire                                    OUTBUS_LSTPEB;
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
wire [  `C_LOG_2(`LENPSUM*`LENPSUM)         - 1 : 0 ] PECRAM_AddrWr0;
wire [   `PSUM_WIDTH    - 1 : 0 ] PECRAM_DatWr0;
wire                                        PECRAM_EnRd0;
wire [          - 1 : 0 ] PECRAM_AddrRd0;
wire [  `PSUM_WIDTH     - 1 : 0 ] RAMPEC_DatRd0;

wire                                        PECRAM_EnWr1;
wire [  `C_LOG_2(`LENPSUM*`LENPSUM)         - 1 : 0 ] PECRAM_AddrWr1;
wire [   `PSUM_WIDTH    - 1 : 0 ] PECRAM_DatWr1;
wire                                        PECRAM_EnRd1;
wire [  `C_LOG_2(`LENPSUM*`LENPSUM)         - 1 : 0 ] PECRAM_AddrRd1;
wire [  `PSUM_WIDTH     - 1 : 0 ] RAMPEC_DatRd1;

wire                                        PECRAM_EnWr2;
wire [  `C_LOG_2(`LENPSUM*`LENPSUM)         - 1 : 0 ] PECRAM_AddrWr2;
wire [   `PSUM_WIDTH    - 1 : 0 ] PECRAM_DatWr2;

wire                                        PECRAM_EnRd2;
wire [  `C_LOG_2(`LENPSUM*`LENPSUM)         - 1 : 0 ] PECRAM_AddrRd2;
wire [  `PSUM_WIDTH     - 1 : 0 ] RAMPEC_DatRd2;

wire [   `PSUM_WIDTH    - 1 : 0 ] PECRAM_DatWr3;
wire [  `PSUM_WIDTH     - 1 : 0 ] RAMPEC_DatRd3;

wire                                        EnWr0;
wire [  `C_LOG_2(`LENPSUM*`LENPSUM)         - 1 : 0 ] AddrWr0;
wire [   `PSUM_WIDTH    - 1 : 0 ] DatWr0;
wire                                        EnRd0;
wire [  `C_LOG_2(`LENPSUM*`LENPSUM)         - 1 : 0 ] AddrRd0;
wire [  `PSUM_WIDTH     - 1 : 0 ] DatRd0;

wire                                        EnWr1;
wire [  `C_LOG_2(`LENPSUM*`LENPSUM)         - 1 : 0 ] AddrWr1;
wire [   `PSUM_WIDTH    - 1 : 0 ] DatWr1;
wire                                        EnRd1;
wire [  `C_LOG_2(`LENPSUM*`LENPSUM)         - 1 : 0 ] AddrRd1;
wire [  `PSUM_WIDTH     - 1 : 0 ] DatRd1;

wire                                        EnWr2;
wire [  `C_LOG_2(`LENPSUM*`LENPSUM)         - 1 : 0 ] AddrWr2;
wire [   `PSUM_WIDTH    - 1 : 0 ] DatWr2;
wire                                        EnRd2;
wire [  `C_LOG_2(`LENPSUM*`LENPSUM)         - 1 : 0 ] AddrRd2;
wire [  `PSUM_WIDTH     - 1 : 0 ] DatRd2;

wire                                        EnWr3;
wire [  `C_LOG_2(`LENPSUM*`LENPSUM)         - 1 : 0 ] AddrWr3;
wire [   `PSUM_WIDTH    - 1 : 0 ] DatWr3;
wire                                        EnRd3;
wire [  `C_LOG_2(`LENPSUM*`LENPSUM)         - 1 : 0 ] AddrRd3;
wire [  `PSUM_WIDTH     - 1 : 0 ] DatRd3;

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

assign RAMPEC_DatRd2 = CTRLPEB_FrtBlk ? DatRd1 : FlgRAM2 ? DatRd2  : DatRd3     ; // ERROR //////////////////////////////////////////
// assign RAMPEC_DatRd2 = CTRLPEB_FrtBlk ?( DatRd1+ FlgRAM2 ? DatRd2  : DatRd3): FlgRAM2 ? DatRd2  : DatRd3     ; // ERROR //////////////////////////////////////////

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
assign GENPEC[0].CTRLWEIPEC_RdyWei = CTRLWEIPEC_RdyWei0;
assign GENPEC[1].CTRLWEIPEC_RdyWei = CTRLWEIPEC_RdyWei1;
assign GENPEC[2].CTRLWEIPEC_RdyWei = CTRLWEIPEC_RdyWei2;
assign PECCTRLWEI_GetWei0 = GENPEC[0].PECCTRLWEI_GetWei;
assign PECCTRLWEI_GetWei1 = GENPEC[1].PECCTRLWEI_GetWei;
assign PECCTRLWEI_GetWei2 = GENPEC[2].PECCTRLWEI_GetWei;
/*
assign {GENPEC[0].LSTPEC_FrtActRow,GENPEC[0].LSTPEC_LstActRow,GENPEC[0].LSTPEC_LstActBlk,GENPEC[0].LSTPEC_ValPsum,GENPEC[0].LSTPEC_RdyAct,LSTPEB_GetAct,GENPEC[0].LSTPEC_FlgAct,GENPEC[0].LSTPEC_Act} =
        {LSTPEC_FrtActRow0,LSTPEC_LstActRow0,LSTPEC_LstActBlk0,LSTPEC_ValPsum0,LSTPEB_RdyAct,GENPEC[0].LSTPEC_GetAct,LSTPEB_FlgAct,LSTPEB_Act};
assign {GENPEC[1].LSTPEC_FrtActRow,GENPEC[1].LSTPEC_LstActRow,GENPEC[1].LSTPEC_LstActBlk,GENPEC[1].LSTPEC_ValPsum,GENPEC[1].LSTPEC_RdyAct,GENPEC[1].LSTPEC_GetAct,GENPEC[1].LSTPEC_FlgAct,GENPEC[1].LSTPEC_Act} =
        {GENPEC[0].NXTPEC_FrtActRow,GENPEC[0].NXTPEC_LstActRow,GENPEC[0].NXTPEC_LstActBlk,GENPEC[0].NXTPEC_ValPsum,GENPEC[0].NXTPEC_RdyAct,GENPEC[0].NXTPEC_GetAct,GENPEC[0].NXTPEC_FlgAct,GENPEC[0].NXTPEC_Act};
assign {GENPEC[2].LSTPEC_FrtActRow,GENPEC[2].LSTPEC_LstActRow,GENPEC[2].LSTPEC_LstActBlk,GENPEC[2].LSTPEC_ValPsum,GENPEC[2].LSTPEC_RdyAct,GENPEC[2].LSTPEC_GetAct,GENPEC[2].LSTPEC_FlgAct,GENPEC[2].LSTPEC_Act} =
        {GENPEC[1].NXTPEC_FrtActRow,GENPEC[1].NXTPEC_LstActRow,GENPEC[1].NXTPEC_LstActBlk,GENPEC[1].NXTPEC_ValPsum,GENPEC[1].NXTPEC_RdyAct,GENPEC[1].NXTPEC_GetAct,GENPEC[1].NXTPEC_FlgAct,GENPEC[1].NXTPEC_Act};
*/
/*
assign INBUS_LSTPEB = { //////////////////////////////////////////////// ValCol
LSTPEC_FrtActRow0   ,
LSTPEC_LstActRow0   ,
LSTPEC_LstActBlk0   ,
LSTPEC_ValPsum0     ,
LSTPEC_ValCol,
LSTPEB_RdyAct,
LSTPEB_FlgAct,
LSTPEB_Act
};
//assign INBUS_NXTPEB = NXTPEB_GetAct;
assign  {
NXTPEC_FrtActRow2   ,
NXTPEC_LstActRow2   ,
NXTPEC_LstActBlk2   ,
NXTPEC_ValPsum2     ,
NXTPEC_ValCol,
NXTPEB_RdyAct,
NXTPEB_FlgAct,
NXTPEB_Act
} = OUTBUS_NXTPEB;
//assign LSTPEB_GetAct = OUTBUS_LSTPEB ;
*/
assign GENPEC[0].INBUS_LSTPEC = INBUS_LSTPEB;
assign GENPEC[1].INBUS_LSTPEC = GENPEC[0].OUTBUS_NXTPEC;
assign GENPEC[2].INBUS_LSTPEC = GENPEC[1].OUTBUS_NXTPEC;
assign OUTBUS_NXTPEB = GENPEC[2].OUTBUS_NXTPEC;

assign GENPEC[2].INBUS_NXTPEC = INBUS_NXTPEB;
assign GENPEC[1].INBUS_NXTPEC = GENPEC[2].OUTBUS_LSTPEC;
assign GENPEC[0].INBUS_NXTPEC = GENPEC[1].OUTBUS_LSTPEC;
assign OUTBUS_LSTPEB = GENPEC[0].OUTBUS_LSTPEC;

assign  PECRAM_EnWr0=GENPEC[0].PECRAM_EnWr;
assign  PECRAM_EnWr1=GENPEC[1].PECRAM_EnWr;
assign  PECRAM_EnWr2=GENPEC[2].PECRAM_EnWr;
assign PECRAM_AddrWr0=GENPEC[0].PECRAM_AddrWr;
assign PECRAM_AddrWr1=GENPEC[1].PECRAM_AddrWr;
assign PECRAM_AddrWr2=GENPEC[2].PECRAM_AddrWr;
assign PECRAM_DatWr0=GENPEC[0].PECRAM_DatWr;
assign PECRAM_DatWr1=GENPEC[1].PECRAM_DatWr;
assign PECRAM_DatWr2=GENPEC[2].PECRAM_DatWr;

assign  PECRAM_EnRd0=GENPEC[0].PECRAM_EnRd;
assign  PECRAM_EnRd1=GENPEC[1].PECRAM_EnRd;
assign  PECRAM_EnRd2=GENPEC[2].PECRAM_EnRd;
assign PECRAM_AddrRd0=GENPEC[0].PECRAM_AddrRd;
assign PECRAM_AddrRd1=GENPEC[1].PECRAM_AddrRd;
assign PECRAM_AddrRd2=GENPEC[2].PECRAM_AddrRd;
assign GENPEC[0].RAMPEC_DatRd=RAMPEC_DatRd0;
assign GENPEC[1].RAMPEC_DatRd=RAMPEC_DatRd1;
assign GENPEC[2].RAMPEC_DatRd=RAMPEC_DatRd2;

generate
    genvar i;
    for(i=0;i<3;i=i+1) begin:GENPEC
        wire                                                   CTRLWEIPEC_RdyWei;
        wire                                                   PECCTRLWEI_GetWei;
        wire [`BUSPEC_WIDTH            -1 :0 ] INBUS_LSTPEC, OUTBUS_NXTPEC;
        wire                                                    INBUS_NXTPEC, OUTBUS_LSTPEC;
        wire                                                    PECRAM_EnWr  ;
        wire [ `C_LOG_2(`LENPSUM*`LENPSUM)                       - 1 : 0]PECRAM_AddrWr;
        wire [ `PSUM_WIDTH                     - 1 : 0 ]PECRAM_DatWr ;
        wire                                                    PECRAM_EnRd  ;
        wire [ `C_LOG_2(`LENPSUM*`LENPSUM)                       -1 : 0]PECRAM_AddrRd;
        wire [ `PSUM_WIDTH                    -1 : 0]RAMPEC_DatRd ;

        // open / close EnPEC
        // EnPEC == 1
        PEC inst_PEC
            (
                .clk               (clk),
                .rst_n             (rst_n),
                .CTRLWEIPEC_RdyWei (CTRLWEIPEC_RdyWei),
                .PECCTRLWEI_GetWei (PECCTRLWEI_GetWei),
                .DISWEIPEC_Wei     (DISWEIPEC_Wei   ),
                .DISWEIPEC_FlgWei  (DISWEIPEC_FlgWei),

                .INBUS_LSTPEC         (INBUS_LSTPEC),
                .INBUS_NXTPEC      (INBUS_NXTPEC),
                .OUTBUS_NXTPEC         (OUTBUS_NXTPEC),
                .OUTBUS_LSTPEC      (OUTBUS_LSTPEC),
                .PECRAM_EnWr       (PECRAM_EnWr  ),
                .PECRAM_AddrWr     (PECRAM_AddrWr),
                .PECRAM_DatWr      (PECRAM_DatWr ),
                .PECRAM_EnRd       (PECRAM_EnRd  ),
                .PECRAM_AddrRd     (PECRAM_AddrRd),
                .RAMPEC_DatRd      (RAMPEC_DatRd )
            );
    end
endgenerate


SRAM_DUAL #(
        .SRAM_DEPTH_BIT( `C_LOG_2(`LENPSUM*`LENPSUM)),
        .SRAM_WIDTH( `PSUM_WIDTH)
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
        .SRAM_DEPTH_BIT( `C_LOG_2(`LENPSUM*`LENPSUM)),
        .SRAM_WIDTH( `PSUM_WIDTH)
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
         .SRAM_DEPTH_BIT( `C_LOG_2(`LENPSUM*`LENPSUM)),
        .SRAM_WIDTH( `PSUM_WIDTH)
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
        .SRAM_DEPTH_BIT( `C_LOG_2(`LENPSUM*`LENPSUM)),
        .SRAM_WIDTH( `PSUM_WIDTH)
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
