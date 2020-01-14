//======================================================
// Copyright (C) 2019 By zhoucc
// All Rights Reserved
//======================================================
// Module : TS3D
// Author : CC zhou
// Contact : 
// Date : 8 .1 .2019
//=======================================================
// Description :
//========================================================
// `include
// `ifdef SYNTH
`include "../include/dw_params_presim.vh"
// `endif
module TS3D #(
    parameter PSUM_WIDTH = (`DATA_WIDTH *2 + `C_LOG_2(`BLOCK_DEPTH) + 2 )
)(
    input                                       clk     ,
    input                                       rst_n   ,

    input  [ `C_LOG_2 ( `NUMPEB)        -1 : 0] POOLPEB_EnRd,// 4 bit ID of PEB
    input  [ `C_LOG_2(`LENPSUM)         -1 : 0] POOLPEB_AddrRd,
    output [ PSUM_WIDTH * `LENPSUM      -1 : 0] PELPOOL_Dat,

    input                                       GBFWEI_Val, //valid 
    input                                       GBFWEI_EnWr,
    input [ `GBFWEI_ADDRWIDTH           -1 : 0] GBFWEI_AddrWr,
    input [ `GBFWEI_DATAWIDTH           -1 : 0] GBFWEI_DatWr,

    input                                       GBFFLGWEI_Val, //valid 
    input                                       GBFFLGWEI_EnWr,
    input [ `GBFWEI_ADDRWIDTH           -1 : 0] GBFFLGWEI_AddrWr,
    input [ `GBFFLGWEI_DATAWIDTH        -1 : 0] GBFFLGWEI_DatWr,

    input                                       GBFACT_Val, //valid 
    input                                       GBFACT_EnWr,
    input  [ `GBFACT_ADDRWIDTH          -1 : 0] GBFACT_AddrWr,
    input  [ `DATA_WIDTH                -1 : 0] GBFACT_DatWr,

    input                                       GBFFLGACT_Val, //valid 
    input                                       GBFFLGACT_EnWr,
    input  [ `GBFACT_ADDRWIDTH          -1 : 0] GBFFLGACT_AddrWr,
    input  [ `BLOCK_DEPTH               -1 : 0] GBFFLGACT_DatWr,

    input                                       GBFVNACT_Val, //valid num ACT
    input                                       GBFVNACT_EnWr,
    input  [ `GBFACT_ADDRWIDTH          -1 : 0] GBFVNACT_AddrWr,
    input  [ `C_LOG_2(`BLOCK_DEPTH)     -1 : 0] GBFVNACT_DatWr
                        
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
wire                                                        DISWEI_RdyWei;
wire                                                        CTRLWEI_PlsFetch;
// wire    [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE)    -1 : 0] DISWEI_AddrBase ;
wire                                                        GBFWEI_EnRd     ;
wire    [ `GBFWEI_ADDRWIDTH                         -1 : 0] GBFWEI_AddrRd   ;
wire    [ `GBFWEI_DATAWIDTH                         -1 : 0] GBFWEI_DatRd    ;
wire                                                        GBFFLGWEI_EnRd  ;
wire    [ `GBFWEI_ADDRWIDTH                         -1 : 0] GBFFLGWEI_AddrRd;
wire    [ `GBFFLGWEI_DATAWIDTH                      -1 : 0] GBFFLGWEI_DatRd ;
wire                                                        CTRLACT_PlsFetch;
wire                                                        CTRLACT_GetAct;
wire                                                        GBFACT_EnRd;
wire    [ `GBFACT_ADDRWIDTH                         -1 : 0] GBFACT_AddrRd;
wire    [ `DATA_WIDTH                               -1 : 0] GBFACT_DatRd;
wire                                                        GBFFLGACT_EnRd;
wire    [ `GBFACT_ADDRWIDTH                         -1 : 0] GBFFLGACT_AddrRd;
wire    [ `BLOCK_DEPTH                              -1 : 0] GBFFLGACT_DatRd;
wire                                                        GBFVNACT_EnRd;
wire    [ `GBFACT_ADDRWIDTH                         -1 : 0] GBFVNACT_AddrRd;
wire    [ `C_LOG_2(`BLOCK_DEPTH)                    -1 : 0] GBFVNACT_DatRd;


//=====================================================================================================================
// Logic Design :
//=====================================================================================================================
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        TOP_Sta_reg <= 0;
        TOP_Sta_reg_d<=0;
    end else begin // automatic
        TOP_Sta_reg <= 1;
        TOP_Sta_reg_d<=TOP_Sta_reg;
    end
end
assign TOP_Sta = TOP_Sta_reg && ~TOP_Sta_reg_d; // paulse


//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================
CONFIG inst_CONFIG
  (
    .clk        (clk),
    .rst_n      (rst_n),
    .CFG_LenRow (CFG_LenRow),
    .CFG_DepBlk (CFG_DepBlk),
    .CFG_NumBlk (CFG_NumBlk),
    .CFG_NumFrm (CFG_NumFrm),
    .CFG_NumPat (CFG_NumPat),
    .CFG_NumLay (CFG_NumLay)
  );


PEL inst_PEL
  (
    .clk                 (clk),
    .rst_n               (rst_n),
    .POOLPEB_EnRd        (POOLPEB_EnRd),
    .POOLPEB_AddrRd      (POOLPEB_AddrRd),
    .PELPOOL_Dat         (PELPOOL_Dat),
    .CTRLACT_FrtBlk      (CTRLACT_FrtBlk),
    .CTRLACT_FrtActRow   (CTRLACT_FrtActRow),
    .CTRLACT_LstActRow   (CTRLACT_LstActRow),
    .CTRLACT_LstActBlk   (CTRLACT_LstActBlk),
    .CTRLPEB_FnhFrm      (CTRLACT_FnhFrm),
    .CTRLACT_RdyAct      (DISACT_RdyAct),
    .CTRLACT_GetAct      (DISACT_GetAct),
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
CTRLWEI inst_CTRLWEI
  (
    .clk               (clk),
    .rst_n             (rst_n),
    .TOP_Sta           (TOP_Sta),
    .CTRLWEIPEC_RdyWei (CTRLWEIPEC_RdyWei),
    .PECCTRLWEI_GetWei (PECCTRLWEI_GetWei),
    .DISWEI_RdyWei     (DISWEI_RdyWei),
    .CTRLWEI_PlsFetch  (CTRLWEI_PlsFetch)
  );
DISWEI inst_DISWEI
  (
    .clk              (clk),
    .rst_n            (rst_n),
    .CTRLWEI_PlsFetch (CTRLWEI_PlsFetch),
    .DISWEI_RdyWei     (DISWEI_RdyWei),
    .DISWEIPEC_Wei    (DISWEIPEC_Wei),
    .DISWEIPEC_FlgWei (DISWEIPEC_FlgWei),
    // .DISWEI_AddrBase  (DISWEI_AddrBase),
    .GBFWEI_Val       (GBFWEI_Val),
    .GBFWEI_EnRd      (GBFWEI_EnRd),
    .GBFWEI_AddrRd    (GBFWEI_AddrRd),
    .GBFWEI_DatRd     (GBFWEI_DatRd),
    .GBFFLGWEI_Val    (GBFFLGWEI_Val),
    .GBFFLGWEI_EnRd   (GBFFLGWEI_EnRd),
    .GBFFLGWEI_AddrRd (GBFFLGWEI_AddrRd),
    .GBFFLGWEI_DatRd  (GBFFLGWEI_DatRd)
  );

// `ifdef SYNTH_MINI
SRAM_DUAL #(
        .SRAM_DEPTH_BIT(`GBFWEI_ADDRWIDTH),   
        .SRAM_WIDTH(`GBFWEI_DATAWIDTH),
        .INIT_IF ("yes"),
        .INIT_FILE ("../testbench/Data/RAM_GBFWEI.dat")
    ) RAM_GBFWEI (
        .clk      ( clk         ),
        .addr_r   ( GBFWEI_AddrRd     ),
        .addr_w   ( GBFWEI_AddrWr     ),
        .read_en  ( GBFWEI_EnRd       ),
        .write_en ( GBFWEI_EnWr       ),
        .data_in  ( GBFWEI_DatWr      ),
        .data_out ( GBFWEI_DatRd      )
    );
// `elsif SYNTH_AREA or 
// MEM X MEM
// `endif

SRAM_DUAL #(
        .SRAM_DEPTH_BIT(`GBFWEI_ADDRWIDTH),   
        .SRAM_WIDTH(`GBFFLGWEI_DATAWIDTH),
        .INIT_IF ("yes"),
        .INIT_FILE ("../testbench/Data/RAM_GBFFLGWEI_HEX.dat")
    ) RAM_GBFFLGWEI (
        .clk      ( clk         ),
        .addr_r   ( GBFFLGWEI_AddrRd     ),
        .addr_w   ( GBFFLGWEI_AddrWr     ),
        .read_en  ( GBFFLGWEI_EnRd       ),
        .write_en ( GBFFLGWEI_EnWr       ),
        .data_in  ( GBFFLGWEI_DatWr      ),
        .data_out ( GBFFLGWEI_DatRd      )
    );
// Activations global buffer
CTRLACT inst_CTRLACT
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
    .CTRLACT_FnhFrm    (CTRLACT_FnhFrm)
  );
DISACT inst_DISACT
  (
    .clk              (clk),
    .rst_n            (rst_n),
    .CTRLACT_PlsFetch (CTRLACT_PlsFetch),
    .CTRLACT_GetAct   (CTRLACT_GetAct),
    .DISACT_RdyAct    (DISACT_RdyAct),
    .DISACT_GetAct    (DISACT_GetAct),
    .DISACT_FlgAct    (DISACT_FlgAct),
    .DISACT_Act       (DISACT_Act),
    .GBFACT_Val       (GBFACT_Val),
    .GBFACT_EnRd      (GBFACT_EnRd),
    .GBFACT_AddrRd    (GBFACT_AddrRd),
    .GBFACT_DatRd     (GBFACT_DatRd),
    .GBFFLGACT_Val    (GBFFLGACT_Val),
    .GBFFLGACT_EnRd   (GBFFLGACT_EnRd),
    .GBFFLGACT_AddrRd (GBFFLGACT_AddrRd),
    .GBFFLGACT_DatRd  (GBFFLGACT_DatRd),
    .GBFVNACT_Val     (GBFVNACT_Val),
    .GBFVNACT_EnRd    (GBFVNACT_EnRd),
    .GBFVNACT_AddrRd  (GBFVNACT_AddrRd),
    .GBFVNACT_DatRd   (GBFVNACT_DatRd)
  );
SRAM_DUAL #(
        .SRAM_DEPTH_BIT(`GBFACT_ADDRWIDTH),   
        .SRAM_WIDTH(`DATA_WIDTH)
    ) RAM_GBFACT (
        .clk      ( clk         ),
        .addr_r   ( GBFACT_AddrRd     ),
        .addr_w   ( GBFACT_AddrWr     ),
        .read_en  ( GBFACT_EnRd       ),
        .write_en ( GBFACT_EnWr       ),
        .data_in  ( GBFACT_DatWr      ),
        .data_out ( GBFACT_DatRd      )
    );
SRAM_DUAL #(
        .SRAM_DEPTH_BIT(`GBFACT_ADDRWIDTH),   
        .SRAM_WIDTH(`BLOCK_DEPTH)
    ) RAM_GBFFLGACT (
        .clk      ( clk         ),
        .addr_r   ( GBFFLGACT_AddrRd     ),
        .addr_w   ( GBFFLGACT_AddrWr     ),
        .read_en  ( GBFFLGACT_EnRd       ),
        .write_en ( GBFFLGACT_EnWr       ),
        .data_in  ( GBFFLGACT_DatWr      ),
        .data_out ( GBFFLGACT_DatRd      )
    );
SRAM_DUAL #(
        .SRAM_DEPTH_BIT(`GBFACT_ADDRWIDTH),   
        .SRAM_WIDTH(`C_LOG_2(`BLOCK_DEPTH))
    ) RAM_GBFVNACT (
        .clk      ( clk         ),
        .addr_r   ( GBFVNACT_AddrRd     ),
        .addr_w   ( GBFVNACT_AddrWr     ),
        .read_en  ( GBFVNACT_EnRd       ),
        .write_en ( GBFVNACT_EnWr       ),
        .data_in  ( GBFVNACT_DatWr      ),
        .data_out ( GBFVNACT_DatRd      )
    );

endmodule