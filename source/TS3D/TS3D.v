//======================================================
// Copyright (C) 2019 By zhoucc
// All Rights Reserved
//======================================================
// Module : TS3D
// Author : CC zhou
// Date : 8 .1 .2019
//=======================================================
// Description :
//========================================================
// `include
// `ifdef SYNTH
`include "../source/include/dw_params_presim.vh"
// `endif
module TS3D (
    input                                       clk     ,
    input                                       rst_n   ,
    output                                     Reset,
    output                                      Reset_WEI,
    output                                      Reset_ACT,
    output                                      Reset_OFM,
    output                                      IF_Val,
    input                                           IF_RdDone,
    output                                      CFG_Req,
    input [`PORT_DATAWIDTH   - 1 : 0] IFCFG,
    input                                       IFCFG_Val,

 //   input                                       GBFWEI_Val, //valid
    input                                       GBFWEI_EnWr,
    output                                    GBFWEI_EnRd,
    input [ `GBFWEI_ADDRWIDTH           -1 : 0] GBFWEI_AddrWr,
    output [ `GBFWEI_ADDRWIDTH           -1 : 0] GBFWEI_AddrRd,
    input [ `PORT_DATAWIDTH           -1 : 0] GBFWEI_DatWr,

//    input                                       GBFFLGWEI_Val, //valid
    input                                       GBFFLGWEI_EnWr,
    output wire                              GBFFLGWEI_EnRd  ,
    input [ `GBFFLGWEI_ADDRWIDTH           -1 : 0] GBFFLGWEI_AddrWr,
    output reg[ `GBFFLGWEI_ADDRWIDTH           -1 : 0] GBFFLGWEI_AddrRd,
    input [ `PORT_DATAWIDTH        -1 : 0] GBFFLGWEI_DatWr,

 //   input                                       GBFACT_Val, //valid
    input                                       GBFACT_EnWr,
    output                                     GBFACT_EnRd,
    input  [ `GBFACT_ADDRWIDTH          -1 : 0] GBFACT_AddrWr,
    output reg [ `GBFACT_ADDRWIDTH          -1 : 0] GBFACT_AddrRd,
    input  [ `PORT_DATAWIDTH                -1 : 0] GBFACT_DatWr,

 //   input                                       GBFFLGACT_Val, //valid
    input                                       GBFFLGACT_EnWr,
    output                                      GBFFLGACT_EnRd,
    input  [ `GBFFLGACT_ADDRWIDTH          -1 : 0] GBFFLGACT_AddrWr,
    output reg [ `GBFFLGACT_ADDRWIDTH          -1 : 0] GBFFLGACT_AddrRd,
    input  [ `PORT_DATAWIDTH               -1 : 0] GBFFLGACT_DatWr,

    input                                                                    GBFOFM_EnRd,
    output                                                                    GBFOFM_EnWr,
    input  [ `GBFOFM_ADDRWIDTH                  -1 : 0] GBFOFM_AddrRd,
    output  [ `GBFOFM_ADDRWIDTH                  -1 : 0] GBFOFM_AddrWr,
    output [ `PORT_DATAWIDTH                      -1 : 0] GBFOFM_DatRd,
    input                                                                    GBFFLGOFM_EnRd,
    output                                                                    GBFFLGOFM_EnWr,
    input   [ `GBFFLGOFM_ADDRWIDTH           - 1 :0 ] GBFFLGOFM_AddrRd,
    output   [ `GBFFLGOFM_ADDRWIDTH           - 1 :0 ] GBFFLGOFM_AddrWr,
    output  [ `PORT_DATAWIDTH                    - 1 : 0 ] GBFFLGOFM_DatRd
);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================





//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================
// wire [ `NUMPEB                      -1 : 0] POOLPEB_EnRd = 0;
// wire                                        POOLPEB_AddrRd = 0;
// wire                                        PEBPOOL_Dat;

reg                                                         TOP_Sta_reg;
reg                                                         TOP_Sta_reg_d;
wire                                                        TOP_Sta;
wire    [ `C_LOG_2(`LENROW)                         -1 : 0] CFG_LenRow;
wire    [ `BLK_WIDTH                                -1 : 0] CFG_DepBlk;
wire    [ `BLK_WIDTH                                -1 : 0] CFG_NumBlk;
wire    [ `FRAME_WIDTH                              -1 : 0] CFG_NumFrm;
wire    [ `PATCH_WIDTH                              -1 : 0] CFG_NumPat;
wire    [ `LAYER_WIDTH                              -1 : 0] CFG_NumLay;
wire [ 5 + 1+`POOL_KERNEL_WIDTH                -1 : 0] CFG_POOL;
wire                                                        CTRLACT_FrtBlk;
wire                                                        CTRLACT_FrtActRow;
wire                                                        CTRLACT_LstActRow;
wire                                                        CTRLACT_LstActBlk;
wire                                                        CTRLACT_FnhFrm;
wire                                                        DISACT_RdyAct;
wire                                                        DISACT_GetAct;
wire  [ `BLOCK_DEPTH                                -1 : 0] DISACT_FlgAct;
wire  [ `DATA_WIDTH * `BLOCK_DEPTH                  -1 : 0] DISACT_Act;
wire  [ `NUMPEC                                     -1 : 0] CTRLWEIPEC_RdyWei;
wire  [ `NUMPEC                                     -1 : 0] PECCTRLWEI_GetWei;
wire  [ `DATA_WIDTH * `BLOCK_DEPTH * `KERNEL_SIZE   -1 : 0] DISWEIPEC_Wei;
wire  [ 1 * `BLOCK_DEPTH * `KERNEL_SIZE             -1 : 0] DISWEIPEC_FlgWei;
// wire  [ `C_LOG_2( `BLOCK_DEPTH) * `KERNEL_SIZE      -1 : 0] DISWEIPEC_ValNumWei;
wire                                                        DISWEI_RdyFIFO;
wire                                                        CTRLWEI_PlsFetch;
// wire    [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE)    -1 : 0] DISWEI_AddrBase ;
//wire    [ `GBFWEI_ADDRWIDTH                         -1 : 0] GBFWEI_AddrRd   ;
wire    [ `PORT_DATAWIDTH                         -1 : 0] GBFWEI_DatRd    ;
wire                                                            GBFWEI_Val;
wire                                                            _GBFWEI_Val;
//wire                                                        GBFFLGWEI_EnRd  ;
wire                                                        GBFFLGWEI_EnRd_d  ;
//reg    [ `GBFWEI_ADDRWIDTH                         -1 : 0] GBFFLGWEI_AddrRd;
wire    [ `PORT_DATAWIDTH                      -1 : 0] GBFFLGWEI_DatRd ;
wire                                                        CTRLACT_PlsFetch;
wire                                                        CTRLACT_GetAct;
//wire                                                        GBFACT_EnRd;
wire                                                        GBFACT_EnRd_d;
//reg    [ `GBFACT_ADDRWIDTH                         -1 : 0] GBFACT_AddrRd;
wire    [ `PORT_DATAWIDTH                               -1 : 0] GBFACT_DatRd;
//wire                                                        GBFFLGACT_EnRd;
wire                                                        GBFFLGACT_EnRd_d;
//reg    [ `GBFACT_ADDRWIDTH                         -1 : 0] GBFFLGACT_AddrRd;
wire    [ `PORT_DATAWIDTH                              -1 : 0] GBFFLGACT_DatRd;
// wire                                                        GBFVNACT_EnRd;
// wire    [ `GBFACT_ADDRWIDTH                         -1 : 0] GBFVNACT_AddrRd;
// wire    [ `C_LOG_2(`BLOCK_DEPTH)                    -1 : 0] GBFVNACT_DatRd;
wire                                                        CTRLACT_ValPsum;
wire                                                        CTRLACT_ValCol;

wire [ `NUMPEB                                              - 1:0 ] PEBPOOL_En;
    wire  [ 1       -1 : 0] POOLPEL_EnRd;// 4 bit ID of PEB
    wire  [ `C_LOG_2(`LENPSUM*`LENPSUM)         -1 : 0] POOLPEL_AddrRd;
    wire [ `PSUM_WIDTH * `NUMPEB      -1 : 0] PELPOOL_Dat;
wire                                                            POOL_ValDelta;
wire                                                            POOL_ValFrm;
wire                                                            POOL_En;
    //wire                                                                    GBFOFM_EnWr;
//    wire  [ `GBFOFM_ADDRWIDTH                 -1 : 0] GBFOFM_AddrWr;
    wire [ `PORT_DATAWIDTH                        -1 : 0] GBFOFM_DatWr;
    //wire                                                                    GBFFLGOFM_EnWr;
 //   wire   [ `GBFFLGOFM_ADDRWIDTH         - 1 :0 ] GBFFLGOFM_AddrWr;
    wire  [ `PORT_DATAWIDTH                     - 1 : 0 ] GBFFLGOFM_DatWr;
    wire                                                                    CTRLACT_EvenFrm;

        wire                                Packed_RdyWr;
    wire                                  Packed_RdyWr_d;
    wire                                    Packed_EnWr;
    wire                                    Unpacked_RdyRd;
    wire                                    Unpacked_EnRd;
    wire      [    `DATA_WIDTH  - 1 : 0 ]Unpacked_DatRd;

    wire                                        FLGACT_Packed_RdyWr;
    wire                                        FLGACT_Packed_RdyWr_d;
    wire                                        FLGACT_Packed_EnWr;
    wire                                        FLGACT_Unpacked_RdyRd;
    wire                                        FLGACT_Unpacked_EnRd;
    wire [ `BLOCK_DEPTH  - 1 : 0 ]FLGACT_Unpacked_DatRd;


    wire                                        FLGWEI_Packed_RdyRd;
//    wire                                        FLGWEI_Packed_RdyRd_d;
    wire                                        FLGWEI_Packed_EnRd;
    wire [ `GBFFLGWEI_DATAWIDTH  - 1 : 0 ]FLGWEI_Packed_DatRd;
    reg [ `GBFFLGWEI_DATAWIDTH  - 1 : 0 ]FLGWEI_Packed_DatRd_d;

    wire                                        FLGWEI_Unpacked_RdyWr;
    wire                                        FLGWEI_Unpacked_EnWr;
wire                                                    GBFFLGWEI_Val;
wire                                                    _GBFFLGWEI_Val;
wire                ALLRdy_FLGACT;
wire                ALLRdy_FLGACT_d;
wire                GBFFLGACT_Val;
wire                _GBFFLGACT_Val;
wire                ALLRdy_ACT;
wire                ALLRdy_ACT_d;
wire                GBFACT_Val;
wire                _GBFACT_Val;
wire                    GBF_Val;
wire 			Rst_Layer;

wire                    _GBFFLGOFM_Val;
wire                    GBFFLGOFM_Val;
wire                    _GBFOFM_Val;
wire                    GBFOFM_Val;
wire                    CCUCTRLWEI_Start;
wire                    CCUCTRLWEI_Reset;
//=====================================================================================================================
// Logic Design :
//=====================================================================================================================
assign GBF_Val = GBFFLGWEI_Val && GBFWEI_Val && GBFFLGACT_Val && GBFACT_Val;
assign Reset_WEI = CTRLACT_FnhFrm;
assign Reset_ACT = 0;//CTRLACT_FnhLayer;
assign Reset_OFM = 0;
//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================
CCU CCU(
    .clk ( clk ),
    .rst_n ( rst_n ),
    .IFCFG_RdDone( IF_RdDone),
    .CFG_Req ( CFG_Req ),
    .IFCFG_Val ( IFCFG_Val),
    .GBF_Val ( GBF_Val ),
    .CTRLACT_FnhFrm(CTRLACT_FnhFrm),
    .TOP_Sta ( TOP_Sta),
    .Rst_Layer (Rst_Layer  ),
    .IF_Val (IF_Val),
    .CCUCTRLWEI_Start(CCUCTRLWEI_Start),
    .CCUCTRLWEI_Reset(CCUCTRLWEI_Reset)
    );
assign Reset = 0;
CONFIG CONFIG
  (
    .clk        (clk),
    .rst_n      (rst_n),
    .Rst_Layer ( Rst_Layer),
    .IFCFG    ( IFCFG ),
    .IFCFG_Val (IFCFG_Val),
    .CFG_LenRow (CFG_LenRow),
    .CFG_DepBlk (CFG_DepBlk),
    .CFG_NumBlk (CFG_NumBlk),
    .CFG_NumFrm (CFG_NumFrm),
    .CFG_NumPat (CFG_NumPat),
    .CFG_NumLay (CFG_NumLay),
    .CFG_POOL       ( CFG_POOL)
  );


PEL PEL
  (
    .clk                 (clk),
    .rst_n               (rst_n),
    .PEBPOOL_En (PEBPOOL_En),
    .POOLPEB_EnRd        (POOLPEL_EnRd),
    .POOLPEB_AddrRd      (POOLPEL_AddrRd),
    .PELPOOL_Dat         (PELPOOL_Dat),
    .CTRLACT_FrtBlk      (CTRLACT_FrtBlk), // Modify to pass FrtBlk for every PEC
    .CTRLACT_FrtActRow   (CTRLACT_FrtActRow),
    .CTRLACT_LstActRow   (CTRLACT_LstActRow),
    .CTRLACT_LstActBlk   (CTRLACT_LstActBlk),
    .CTRLACT_ValPsum     (CTRLACT_ValPsum),
    .CTRLACT_ValCol         ( CTRLACT_ValCol),
    .CTRLPEB_FnhFrm      (CTRLACT_EvenFrm),
    .CTRLACT_RdyAct      (DISACT_RdyAct),
    .CTRLACT_GetAct      (CTRLACT_GetAct),
    .CTRLACT_FlgAct      (DISACT_FlgAct),
    .CTRLACT_Act         (DISACT_Act),
    .CTRLWEIPEC_RdyWei   (CTRLWEIPEC_RdyWei),
    .PECCTRLWEI_GetWei   (PECCTRLWEI_GetWei),
    .DISWEIPEC_Wei       (DISWEIPEC_Wei),
    .DISWEIPEC_FlgWei    (DISWEIPEC_FlgWei)
    // .DISWEIPEC_ValNumWei (DISWEIPEC_ValNumWei),
    // .DISWEI_AddrBase     (DISWEI_AddrBase)
  );

// Weight global buffer
CTRLWEI CTRLWEI
  (
    .clk               (clk),
    .rst_n             (rst_n),
    .Start           (CCUCTRLWEI_Start),
    .Reset             (CCUCTRLWEI_Reset),
    .CTRLWEIPEC_RdyWei (CTRLWEIPEC_RdyWei),
    .PECCTRLWEI_GetWei (PECCTRLWEI_GetWei),
    .DISWEI_RdyFIFO     (DISWEI_RdyFIFO),
    .CTRLWEI_PlsFetch  (CTRLWEI_PlsFetch)
  );
DISWEI DISWEI
  (
    .clk              (clk),
    .rst_n            (rst_n),
    .CTRLWEI_PlsFetch (CTRLWEI_PlsFetch),
    .DISWEI_RdyFIFO     (DISWEI_RdyFIFO),
    .DISWEIPEC_Wei    (DISWEIPEC_Wei),
    .DISWEIPEC_FlgWei (DISWEIPEC_FlgWei),
    // .DISWEI_AddrBase  (DISWEI_AddrBase),
    .GBFWEI_Val       (GBFWEI_Val),
    .GBFWEI_BusyRd    (GBFWEI_EnWr),// When GBFWEI Writes, not to Read
    .GBFWEI_EnRd      (GBFWEI_EnRd),
    .GBFWEI_AddrRd    (GBFWEI_AddrRd),
    .GBFWEI_DatRd     (GBFWEI_DatRd),
    .GBFFLGWEI_Val    (FLGWEI_Packed_RdyRd),
    .GBFFLGWEI_EnRd   (FLGWEI_Packed_EnRd),
//    .GBFFLGWEI_AddrRd ( ),
    .GBFFLGWEI_DatRd  (FLGWEI_Packed_DatRd_d),
    .CTRLACT_FnhFrm   (CCUCTRLWEI_Reset)
  );
  ReqGBF #(
    .DEPTH(2**`GBFWEI_ADDRWIDTH ),
    .CNT_WIDTH( `REQ_CNT_WIDTH), //////////////////////////////////////////////////////////
    .DEPTH_REQ( `BLOCK_DEPTH * `KERNEL_SIZE/(`PORT_DATAWIDTH/`DATA_WIDTH)) // at least cfg a PEC
    ) ReqGBFWEI(
    .clk ( clk ),
    .rst_n( rst_n),
    .Reset( Reset_WEI ),
    .AddrWr(GBFWEI_AddrWr ),
    .AddrRd(GBFWEI_AddrRd ),
    .EnWr(GBFWEI_EnWr ),
    .EnRd(GBFWEI_EnRd),
    .Req( _GBFWEI_Val)
    );
assign GBFWEI_Val =~_GBFWEI_Val;

// Activations global buffer
CTRLACT CTRLACT
  (
    .clk               (clk),
    .rst_n             (rst_n),
    .TOP_Sta           (TOP_Sta),
    .CFG_LenRow        (CFG_LenRow),
    .CFG_DepBlk        (CFG_DepBlk),
    .CFG_NumBlk        (CFG_NumBlk),
    .CFG_NumFrm        (CFG_NumFrm),
    .CFG_NumPat        (CFG_NumPat),
    .CFG_NumLay        (CFG_NumLay),
    .CTRLACT_PlsFetch  (CTRLACT_PlsFetch),
    .CTRLACT_GetAct    (CTRLACT_GetAct),
    .CTRLACT_FrtActRow (CTRLACT_FrtActRow),
    .CTRLACT_LstActRow (CTRLACT_LstActRow),
    .CTRLACT_LstActBlk (CTRLACT_LstActBlk),
    .CTRLACT_ValPsum   (CTRLACT_ValPsum),
    .CTRLACT_ValCol     ( CTRLACT_ValCol),
    .CTRLACT_FrtBlk    (CTRLACT_FrtBlk),
    .CTRLACT_FnhFrm    (CTRLACT_FnhFrm),
    .CTRLACT_EvenFrm    (CTRLACT_EvenFrm),

    .POOL_En                   ( POOL_En),
    .POOL_ValFrm    ( POOL_ValFrm),
    .POOL_ValDelta    ( POOL_ValDelta)
  );
DISACT DISACT
  (
    .clk              (clk),
    .rst_n            (rst_n),
    .CTRLACT_PlsFetch (CTRLACT_PlsFetch),
    // .CTRLACT_GetAct   (CTRLACT_GetAct),
    .DISACT_RdyAct    (DISACT_RdyAct),
    // .DISACT_GetAct    (DISACT_GetAct),
    .DISACT_FlgAct    (DISACT_FlgAct),
    .DISACT_Act       (DISACT_Act),
    .GBFACT_Val       (Unpacked_RdyRd),
    .GBFACT_EnRd      (Unpacked_EnRd),
    .GBFACT_AddrRd    ( ),
    .GBFACT_DatRd     (Unpacked_DatRd),
    .GBFFLGACT_Val    (FLGACT_Unpacked_RdyRd),
    .GBFFLGACT_EnRd   (FLGACT_Unpacked_EnRd),
    .GBFFLGACT_AddrRd (),
    .GBFFLGACT_DatRd  (FLGACT_Unpacked_DatRd)
    // .GBFVNACT_Val     (GBFVNACT_Val),
    // .GBFVNACT_EnRd    (GBFVNACT_EnRd),
    // .GBFVNACT_AddrRd  (GBFVNACT_AddrRd),
    // .GBFVNACT_DatRd   (GBFVNACT_DatRd)
  );
  POOL POOL(
    .clk     (clk),
    .rst_n (rst_n)  ,
    .CFG_POOL(CFG_POOL)      ,
    .POOL_En(PEBPOOL_En[`NUMPEB -1]),  // paulse: the last PEB
    .POOL_ValFrm( POOL_ValFrm),
    .POOL_ValDelta( POOL_ValDelta ),
    .POOLPEL_EnRd(POOLPEL_EnRd),// 4 bit ID of PEB
    .POOLPEL_AddrRd(POOLPEL_AddrRd),
    .PELPOOL_Dat(PELPOOL_Dat),
    .GBFOFM_EnWr(GBFOFM_EnWr),
    .GBFOFM_EnRd(GBFOFM_EnRd),
    .GBFOFM_AddrWr(GBFOFM_AddrWr),
    . GBFOFM_DatWr(GBFOFM_DatWr),
    .GBFFLGOFM_EnWr(GBFFLGOFM_EnWr),
    .GBFFLGOFM_EnRd(GBFFLGOFM_EnRd),
    .GBFFLGOFM_AddrWr(GBFFLGOFM_AddrWr),
    . GBFFLGOFM_DatWr(GBFFLGOFM_DatWr)
);

RAM_GBFWEI_wrap #(
        .SRAM_DEPTH_BIT(`GBFWEI_ADDRWIDTH),
        .SRAM_WIDTH(`PORT_DATAWIDTH),
        .INIT_IF ("no"),
        .INIT_FILE ("../testbench/Data/RAM_GBFWEI_12B.dat")
    ) RAM_GBFWEI (
        .clk      ( clk         ),
        .rst_n ( rst_n),
        .addr_r   ( GBFWEI_AddrRd     ),
        .addr_w   ( GBFWEI_AddrWr     ),
        .read_en  ( GBFWEI_EnRd       ),
        .write_en ( GBFWEI_EnWr       ),
        .data_in  ( GBFWEI_DatWr      ),
        .data_out ( GBFWEI_DatRd      )
    );


RAM_GBFFLGWEI_wrap #(
        .SRAM_DEPTH_BIT(`GBFFLGWEI_ADDRWIDTH),
        .SRAM_WIDTH(`PORT_DATAWIDTH),
        .INIT_IF ("no"),
        .INIT_FILE ("../testbench/Data/RAM_GBFFLGWEI_12B.dat")
    ) RAM_GBFFLGWEI (
        .clk      ( clk         ),
        .rst_n  ( rst_n ),
        .addr_r   ( GBFFLGWEI_AddrRd     ),
        .addr_w   ( GBFFLGWEI_AddrWr     ),
        .read_en  ( GBFFLGWEI_EnRd       ),
        .write_en ( GBFFLGWEI_EnWr       ),
        .data_in  ( GBFFLGWEI_DatWr      ),
        .data_out ( GBFFLGWEI_DatRd      )
    );
ReqGBF #(
    .DEPTH(2**`GBFFLGWEI_ADDRWIDTH ),
    .CNT_WIDTH( `REQ_CNT_WIDTH), //////////////////////////////////////////////////////////
    .DEPTH_REQ(`BLOCK_DEPTH*`KERNEL_SIZE/ (`PORT_DATAWIDTH)) // at least cfg a PEC
    ) ReqGBFFLGWEI(
    .clk ( clk ),
    .rst_n( rst_n),
    .Reset( Reset_WEI ),
    .AddrWr(GBFFLGWEI_AddrWr ),
    .AddrRd(GBFFLGWEI_AddrRd ),
    .EnWr(GBFFLGWEI_EnWr ),
    .EnRd(GBFFLGWEI_EnRd),
    .Req( _GBFFLGWEI_Val)
    );
assign GBFFLGWEI_Val =~_GBFFLGWEI_Val && ~GBFFLGWEI_EnWr;// Single Port: Write first
reg ValPacker;
wire GBFFLGWEI_Val_d;
wire CTRLACT_FnhFrm_d;
//wire PreFetch = TOP_Sta || CTRLACT_FnhFrm_d ;//PreFetch per frame
assign GBFFLGWEI_EnRd = FLGWEI_Unpacked_RdyWr&& GBFFLGWEI_Val;
assign FLGWEI_Unpacked_EnWr = GBFFLGWEI_EnRd_d;
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        GBFFLGWEI_AddrRd <= 0;
    end else if ( CTRLACT_FnhFrm) begin
        GBFFLGWEI_AddrRd <= 0;
    end else if ( GBFFLGWEI_EnRd ) begin
        GBFFLGWEI_AddrRd <= GBFFLGWEI_AddrRd + 1;
    end
end
//disable packer so that the first GBFFLGWEI_DatRd is gotten before EnWr
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        ValPacker <= 0;
    end else if ( CTRLACT_FnhFrm)begin
        ValPacker <= 0;
    end else if (TOP_Sta || CTRLACT_FnhFrm_d ) begin
        ValPacker <= 1;
    end
end
packer #(
    .IN_WIDTH(`PORT_DATAWIDTH),
    .OUT_WIDTH (`GBFFLGWEI_DATAWIDTH)
    )packer_GBFFLGWEI(
    .clk ( clk ),
    .rst_n ( rst_n),
    .Reset ( CTRLACT_FnhFrm),
    .Unpacked_RdyWr (FLGWEI_Unpacked_RdyWr ),
    .Unpacked_EnWr(FLGWEI_Unpacked_EnWr ),
    .Unpacked_DatWr(GBFFLGWEI_DatRd),
    .Packed_RdyRd(FLGWEI_Packed_RdyRd ),
    .Packed_EnRd(FLGWEI_Packed_EnRd),
    .Packed_DatRd(FLGWEI_Packed_DatRd)
    );
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        FLGWEI_Packed_DatRd_d <= 0;
    end else if ( FLGWEI_Packed_EnRd ) begin
        FLGWEI_Packed_DatRd_d <= FLGWEI_Packed_DatRd;
    end
end

RAM_GBFACT_wrap #(
        .SRAM_DEPTH_BIT(`GBFACT_ADDRWIDTH),
        .SRAM_WIDTH(`PORT_DATAWIDTH),
        .INIT_IF ("no"),
        .INIT_FILE ("../testbench/Data/RAM_GBFACT_12B.dat")
    ) RAM_GBFACT (
        .clk      ( clk         ),
        .rst_n ( rst_n ),
        .addr_r   ( GBFACT_AddrRd     ),
        .addr_w   ( GBFACT_AddrWr     ),
        .read_en  ( GBFACT_EnRd       ),
        .write_en ( GBFACT_EnWr       ),
        .data_in  ( GBFACT_DatWr      ),
        .data_out ( GBFACT_DatRd      )
    );


ReqGBF #(
    .DEPTH(2**`GBFACT_ADDRWIDTH ),
    .CNT_WIDTH( `REQ_CNT_WIDTH), //////////////////////////////////////////////////////////
    .DEPTH_REQ( 1) // at least cfg a PEC
    ) ReqGBFACT(
    .clk ( clk ),
    .rst_n( rst_n),
    .Reset( Reset_ACT ),
    .AddrWr(GBFACT_AddrWr ),
    .AddrRd(GBFACT_AddrRd ),
    .EnWr(GBFACT_EnWr ),
    .EnRd(GBFACT_EnRd),
    .Req( _GBFACT_Val)
    );
assign GBFACT_Val = ~_GBFACT_Val && ~GBFACT_EnWr;// SRAM Wr and Rd exclude
assign ALLRdy_ACT = Packed_RdyWr && GBFACT_Val;
//assign GBFACT_EnRd = Packed_RdyWr && ~Packed_RdyWr_d; // && posedge;
assign GBFACT_EnRd = ALLRdy_ACT && ~ALLRdy_ACT_d;
assign Packed_EnWr = GBFACT_EnRd_d;
//assign Unpacked_ReqRd = DISACT_EnRd_d;
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        GBFACT_AddrRd <= 0;
    end else if ( GBFACT_EnRd ) begin ///////////////////
        GBFACT_AddrRd <= GBFACT_AddrRd + 1;
    end
end
unpacker_left #(
    .IN_WIDTH(`PORT_DATAWIDTH),
    .OUT_WIDTH(`DATA_WIDTH)
    )data_unpacker_GBFACT(
    .clk (clk),
    .rst_n(rst_n),
    .Packed_RdyWr(Packed_RdyWr),
    .Packed_EnWr(Packed_EnWr),
    .Packed_DatWr(GBFACT_DatRd),
    .Unpacked_RdyRd(Unpacked_RdyRd),
    .Unpacked_EnRd(Unpacked_EnRd),
    .Unpacked_DatRd(Unpacked_DatRd)
    );


RAM_GBFFLGACT_wrap #(
        .SRAM_DEPTH_BIT(`GBFFLGACT_ADDRWIDTH),
        .SRAM_WIDTH(`PORT_DATAWIDTH),
        .INIT_IF ("no"),
        .INIT_FILE ("../testbench/Data/RAM_GBFACT_12B1.dat")
    ) RAM_GBFFLGACT (
        .clk      ( clk         ),
        .rst_n ( rst_n ),
        .addr_r   ( GBFFLGACT_AddrRd     ),
        .addr_w   ( GBFFLGACT_AddrWr     ),
        .read_en  ( GBFFLGACT_EnRd       ),
        .write_en ( GBFFLGACT_EnWr       ),
        .data_in  ( GBFFLGACT_DatWr      ),
        .data_out ( GBFFLGACT_DatRd      )
    );

ReqGBF #(
    .DEPTH(2**`GBFFLGACT_ADDRWIDTH ),
    .CNT_WIDTH( `REQ_CNT_WIDTH), //////////////////////////////////////////////////////////
    .DEPTH_REQ( 1) // at least cfg a PEC
    ) ReqGBFFLGACT(
    .clk ( clk ),
    .rst_n( rst_n),
    .Reset( Reset_ACT ),
    .AddrWr(GBFFLGACT_AddrWr ),
    .AddrRd(GBFFLGACT_AddrRd ),
    .EnWr(GBFFLGACT_EnWr ),
    .EnRd(GBFFLGACT_EnRd),
    .Req( _GBFFLGACT_Val)
    );
assign GBFFLGACT_Val = ~_GBFFLGACT_Val && ~GBFFLGACT_EnWr;// SRAM Wr and Rd exclude
//assign GBFFLGACT_EnRd = FLGACT_Packed_RdyWr && ~FLGACT_Packed_RdyWr_d; // && posedge;
assign ALLRdy_FLGACT = FLGACT_Packed_RdyWr && GBFFLGACT_Val;
assign GBFFLGACT_EnRd =ALLRdy_FLGACT && ~ALLRdy_FLGACT_d;//posedge
assign FLGACT_Packed_EnWr = GBFFLGACT_EnRd_d;
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        GBFFLGACT_AddrRd <= 0;
    end else if ( GBFFLGACT_EnRd ) begin
        GBFFLGACT_AddrRd <= GBFFLGACT_AddrRd + 1;
    end
end
unpacker_left #(
    .IN_WIDTH(`PORT_DATAWIDTH),
    .OUT_WIDTH(`BLOCK_DEPTH)
    )data_unpacker_GBFFLGACT(
    .clk (clk),
    .rst_n(rst_n),
    .Packed_RdyWr(FLGACT_Packed_RdyWr),
    .Packed_EnWr(FLGACT_Packed_EnWr),
    .Packed_DatWr(GBFFLGACT_DatRd),
    .Unpacked_RdyRd(FLGACT_Unpacked_RdyRd),
    .Unpacked_EnRd(FLGACT_Unpacked_EnRd),
    .Unpacked_DatRd(FLGACT_Unpacked_DatRd)
    );

 RAM_GBFOFM_wrap #( // Because of the supest level But POOL maybe write to 1/4 when BUS is busy
         .SRAM_DEPTH_BIT(`GBFOFM_ADDRWIDTH),
         .SRAM_WIDTH(`PORT_DATAWIDTH)
     ) RAM_GBFOFM (
         .clk      ( clk         ),
         .rst_n (rst_n),
         .addr_r   ( GBFOFM_AddrRd     ),
         .addr_w   ( GBFOFM_AddrWr     ),
         .read_en  ( GBFOFM_EnRd       ),
         .write_en ( GBFOFM_EnWr       ),
         .data_in  ( GBFOFM_DatWr      ),
         .data_out ( GBFOFM_DatRd      )
     );

ReqGBF #(
    .DEPTH(2**`GBFOFM_ADDRWIDTH ),
    .CNT_WIDTH( `REQ_CNT_WIDTH), //////////////////////////////////////////////////////////
    .DEPTH_REQ( 1) // at least cfg a PEC
    ) ReqGBFOFM(
    .clk ( clk ),
    .rst_n( rst_n),
    .Reset( Reset_OFM ),
    .AddrWr(GBFOFM_AddrWr ),
    .AddrRd(GBFOFM_AddrRd ),
    .EnWr(GBFOFM_EnWr ),
    .EnRd(GBFOFM_EnRd),
    .Req( _GBFOFM_Val)
    );
assign GBFOFM_Val = ~_GBFOFM_Val;

 RAM_GBFFLGOFM_wrap #(
         .SRAM_DEPTH_BIT(`GBFFLGOFM_ADDRWIDTH),
         .SRAM_WIDTH(`PORT_DATAWIDTH)
     ) RAM_GBFFLGOFM (
         .clk      ( clk         ),
         .rst_n ( rst_n ),
         .addr_r   ( GBFFLGOFM_AddrRd     ),
         .addr_w   ( GBFFLGOFM_AddrWr     ),
         .read_en  ( GBFFLGOFM_EnRd       ),
         .write_en ( GBFFLGOFM_EnWr       ),
         .data_in  ( GBFFLGOFM_DatWr      ),
         .data_out ( GBFFLGOFM_DatRd      )
     );

ReqGBF #(
    .DEPTH(2**`GBFFLGOFM_ADDRWIDTH ),
    .CNT_WIDTH( `REQ_CNT_WIDTH), //////////////////////////////////////////////////////////
    .DEPTH_REQ( 1) // at least cfg a PEC
    ) ReqGBFFLGOFM(
    .clk ( clk ),
    .rst_n( rst_n),
    .Reset( Reset_OFM ),
    .AddrWr(GBFFLGOFM_AddrWr ),
    .AddrRd(GBFFLGOFM_AddrRd ),
    .EnWr(GBFFLGOFM_EnWr ),
    .EnRd(GBFFLGOFM_EnRd),
    .Req( _GBFFLGOFM_Val)
    );
assign GBFFLGOFM_Val = ~_GBFFLGOFM_Val;

Delay #(
    .NUM_STAGES(1),
    .DATA_WIDTH(1)
    )Delay_Packed_RdyWr
    (
        .CLK(clk),
        .RESET_N(rst_n),
        .DIN(Packed_RdyWr),
        .DOUT(Packed_RdyWr_d)
        );
Delay #(
    .NUM_STAGES(1),
    .DATA_WIDTH(1)
    )Delay_FLGACT_Packed_RdyWr_d
    (
        .CLK(clk),
        .RESET_N(rst_n),
        .DIN(FLGACT_Packed_RdyWr),
        .DOUT(FLGACT_Packed_RdyWr_d)
        );
Delay #(
    .NUM_STAGES(1),
    .DATA_WIDTH(1)
    )Delay_GBFACT_EnRd_d
    (
        .CLK(clk),
        .RESET_N(rst_n),
        .DIN(GBFACT_EnRd),
        .DOUT(GBFACT_EnRd_d)
        );

Delay #(
    .NUM_STAGES(1),
    .DATA_WIDTH(1)
    )Delay_GBFFLGACT_EnRd_d
    (
        .CLK(clk),
        .RESET_N(rst_n),
        .DIN(GBFFLGACT_EnRd),
        .DOUT(GBFFLGACT_EnRd_d)
        );
Delay #(
    .NUM_STAGES(1),
    .DATA_WIDTH(1)
    )Delay_AllRdy_FLGACT_d
    (
        .CLK(clk),
        .RESET_N(rst_n),
        .DIN(ALLRdy_FLGACT),
        .DOUT(ALLRdy_FLGACT_d)
        );
Delay #(
    .NUM_STAGES(1),
    .DATA_WIDTH(1)
    )Delay_AllRdy_ACT_d
    (
        .CLK(clk),
        .RESET_N(rst_n),
        .DIN(ALLRdy_ACT),
        .DOUT(ALLRdy_ACT_d)
        );
Delay #(
    .NUM_STAGES(1),
    .DATA_WIDTH(1)
    )Delay_GBFFLGWEI_EnRd_d
    (
        .CLK(clk),
        .RESET_N(rst_n),
        .DIN(GBFFLGWEI_EnRd),
        .DOUT(GBFFLGWEI_EnRd_d)
        );
Delay #(
    .NUM_STAGES(1),
    .DATA_WIDTH(1)
    )Delay_CTRLACT_FnhFrm_d
    (
        .CLK(clk),
        .RESET_N(rst_n),
        .DIN(CTRLACT_FnhFrm),
        .DOUT(CTRLACT_FnhFrm_d)
        );
  Delay #(
    .NUM_STAGES(1),
    .DATA_WIDTH(1)
    )Delay_GBFFLGWEI_Val_d
    (
        .CLK(clk),
        .RESET_N(rst_n),
        .DIN(GBFFLGWEI_Val),
        .DOUT(GBFFLGWEI_Val_d)
        );

endmodule
