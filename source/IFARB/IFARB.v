//======================================================
// Copyright (C) 2019 By zhoucc
// All Rights Reserved
//======================================================
// Module : IFARB
// Author : CC zhou
// Contact :
// Date : 3 .7 .2019
//=======================================================
// Description :
//========================================================
`include "../source/include/dw_params_presim.vh"
module IFARB (
    input                                       clk     ,
    input                                       rst_n   ,
    input                                       Reset,
    input                                       IF_Val,
    input                                       CFG_Req,
    input [ `GBFWEI_ADDRWIDTH           -1 : 0] GBFFLGWEI_AddrWr,
    input [ `GBFWEI_ADDRWIDTH           -1 : 0] GBFFLGWEI_AddrRd,
    input [ `GBFWEI_ADDRWIDTH           -1 : 0] GBFWEI_AddrWr,
    input [ `GBFWEI_ADDRWIDTH           -1 : 0] GBFWEI_AddrRd,
    input [ `GBFACT_ADDRWIDTH           -1 : 0] GBFFLGACT_AddrWr,
    input [ `GBFACT_ADDRWIDTH           -1 : 0] GBFFLGACT_AddrRd,
    input [ `GBFACT_ADDRWIDTH           -1 : 0] GBFACT_AddrWr,
    input [ `GBFACT_ADDRWIDTH           -1 : 0] GBFACT_AddrRd,
    input [ `GBFFLGOFM_ADDRWIDTH        -1 : 0] GBFFLGOFM_AddrWr,
    input [ `GBFFLGOFM_ADDRWIDTH        -1 : 0] GBFFLGOFM_AddrRd,
    input [ `GBFOFM_ADDRWIDTH           -1 : 0] GBFOFM_AddrWr,
    input [ `GBFOFM_ADDRWIDTH           -1 : 0] GBFOFM_AddrRd,
    input                                       GBFFLGWEI_EnWr,
    input                                       GBFFLGWEI_EnRd,
    input                                       GBFWEI_EnWr,
    input                                       GBFWEI_EnRd,
    input                                       GBFFLGACT_EnWr,
    input                                       GBFFLGACT_EnRd,
    input                                       GBFACT_EnWr,
    input                                       GBFACT_EnRd,
    input                                       GBFFLGOFM_EnWr,
    input                                       GBFFLGOFM_EnRd,
    input                                       GBFOFM_EnWr,
    input                                       GBFOFM_EnRd,
    output reg [ 4                          -1 : 0] IF_Cfg,
    output                                      IF_RdWr,
    input                                       IF_Rdy,
    output                                      IF_Req // Level
);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================





//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================
wire                        Req_FLGWEI;
wire                        Req_WEI;
wire                        Req_FLGACT;
wire                        Req_ACT;
wire                        _Req_FLGOFM;
wire                        Req_FLGOFM;
wire                        _Req_OFM;
wire                        Req_OFM;
wire                        IF_Req_rd;
wire                        IF_Req_wr;



//=====================================================================================================================
// Logic Design :
//=====================================================================================================================
// Error when one cycle finished
assign IF_Req_rd =IF_Val &&  IF_Rdy && (CFG_Req || Req_FLGWEI || Req_WEI|| Req_FLGACT || Req_ACT );
assign IF_Req_wr = IF_Val &&  IF_Rdy && (Req_FLGOFM || Req_OFM);
assign IF_RdWr = ~(Req_FLGOFM || Req_OFM);

assign IF_Req = IF_Req_rd || IF_Req_wr;
localparam IFCFG_CFG = 4'd0;
localparam IFCFG_FLGWEI = 4'd8;
localparam IFCFG_WEI = 4'd6;
localparam IFCFG_FLGACT = 4'd4;
localparam IFCFG_ACT = 4'd2;
localparam IFCFG_FLGOFM = 4'd10;/////////////////////////////////////////////
localparam IFCFG_OFM = 4'd11;
always @ ( * ) begin
    if ( CFG_Req ) begin
       IF_Cfg  = IFCFG_CFG;//
       //IF_RdWr = 1;
    end else if( Req_FLGWEI) begin
        IF_Cfg = IFCFG_FLGWEI;
        //IF_RdWr = 1;
    end else if( Req_WEI) begin
        IF_Cfg = IFCFG_WEI;
        //IF_RdWr = 1;
    end else if( Req_FLGACT) begin
        IF_Cfg = IFCFG_FLGACT;
        //IF_RdWr = 1;
    end else if ( Req_ACT)begin
        IF_Cfg = IFCFG_ACT;
        //IF_RdWr = 1;
    end else if(Req_FLGOFM) begin
        IF_Cfg = IFCFG_FLGOFM;
        //IF_RdWr = 0;
    end else if(Req_OFM) begin
        IF_Cfg = IFCFG_OFM;
        //IF_RdWr = 0;
    end else
        IF_Cfg = 4'd0; //
        //IF_RdWr = 1;
end


//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================
ReqGBF #(
    .DEPTH(2**`GBFWEI_ADDRWIDTH/8 ),
    .CNT_WIDTH( 8), //////////////////////////////////////////////////////////
    .DEPTH_REQ(2**`GBFWEI_ADDRWIDTH / 32 )
    ) ReqGBF_FLGWEI(
    .clk ( clk ),
    .rst_n( rst_n),
    .Reset( Reset ),
    .AddrWr(GBFFLGWEI_AddrWr ),
    .AddrRd(GBFFLGWEI_AddrRd ),
    .EnWr(GBFFLGWEI_EnWr ),
    .EnRd(GBFFLGWEI_EnRd),
    .Req( Req_FLGWEI)
    );
ReqGBF #(
    .DEPTH(2**`GBFWEI_ADDRWIDTH ),
    .CNT_WIDTH( 8), //////////////////////////////////////////////////////////
    .DEPTH_REQ(2**`GBFWEI_ADDRWIDTH / 4 )
    ) ReqGBF_WEI(
    .clk ( clk ),
    .rst_n( rst_n),
    .Reset( Reset ),
    .AddrWr(GBFWEI_AddrWr ),
    .AddrRd(GBFWEI_AddrRd ),
    .EnWr(GBFWEI_EnWr ),
    .EnRd(GBFWEI_EnRd),
    .Req( Req_WEI)
    );
ReqGBF #(
    .DEPTH(2**`GBFACT_ADDRWIDTH /8),
    .CNT_WIDTH( 8), //////////////////////////////////////////////////////////
    .DEPTH_REQ(2**`GBFACT_ADDRWIDTH / 32 )
    ) ReqGBF_FLGACT(
    .clk ( clk ),
    .rst_n( rst_n),
    .Reset( Reset ),
    .AddrWr(GBFFLGACT_AddrWr ),
    .AddrRd(GBFFLGACT_AddrRd ),
    .EnWr(GBFFLGACT_EnWr ),
    .EnRd(GBFFLGACT_EnRd),
    .Req( Req_FLGACT)
    );
ReqGBF #(
    .DEPTH(2**`GBFACT_ADDRWIDTH ),
    .CNT_WIDTH( 8), //////////////////////////////////////////////////////////
    .DEPTH_REQ(2**`GBFACT_ADDRWIDTH / 4 )
    ) ReqGBF_ACT(
    .clk ( clk ),
    .rst_n( rst_n),
    .Reset( Reset ),
    .AddrWr(GBFACT_AddrWr ),
    .AddrRd(GBFACT_AddrRd ),
    .EnWr(GBFACT_EnWr ),
    .EnRd(GBFACT_EnRd),
    .Req( Req_ACT)
    );

// Write
ReqGBF #(
    .DEPTH(2**`GBFFLGOFM_ADDRWIDTH ),
    .CNT_WIDTH( 8), //////////////////////////////////////////////////////////
    .DEPTH_REQ(2**`GBFFLGOFM_ADDRWIDTH / 2 )
    ) ReqGBF_FLGOFM(
    .clk ( clk ),
    .rst_n( rst_n),
    .Reset( Reset ),
    .AddrWr(GBFFLGOFM_AddrWr ),
    .AddrRd(GBFFLGOFM_AddrRd ),
    .EnWr(GBFFLGOFM_EnWr ),
    .EnRd(GBFFLGOFM_EnRd),
    .Req( _Req_FLGOFM)
    );
assign Req_FLGOFM = ~_Req_FLGOFM;
ReqGBF #(
    .DEPTH(2**`GBFOFM_ADDRWIDTH ),
    .CNT_WIDTH( 8), //////////////////////////////////////////////////////////
   // .DEPTH_REQ(2**`GBFOFM_ADDRWIDTH / 2 )///////////////////////////////////
    .DEPTH_REQ(16)
    ) ReqGBF_OFM(
    .clk ( clk ),
    .rst_n( rst_n),
    .Reset( Reset ),
    .AddrWr(GBFOFM_AddrWr ),
    .AddrRd(GBFOFM_AddrRd ),
    .EnWr(GBFOFM_EnWr ),
    .EnRd(GBFOFM_EnRd),
    .Req( _Req_OFM)
    );
assign Req_OFM = ~_Req_OFM;

endmodule
