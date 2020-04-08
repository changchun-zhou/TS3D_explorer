//======================================================
// Copyright (C) 2020 By zhoucc
// All Rights Reserved
//======================================================
// Module : IF
// Author : CC zhou
// Contact :
// Date : 3 .8 .2020
//=======================================================
// Description :
//========================================================
`include "../source/include/dw_params_presim.vh"
module IF(
    input                   clk     ,
    input                   rst_n   ,
    input                                       Reset,
    input                                       Reset_WEI,
    input                                       Reset_ACT,
    input                                       Reset_OFM,
    input                                   IF_Val,
    input                                       CFG_Req,
    output                                  IF_RdDone,
    output [ `PORT_DATAWIDTH         - 1 : 0 ] IFCFG,
    output                                                       IFCFG_Val,
    output [ `PORT_DATAWIDTH         - 1 : 0 ] GBFFLGWEI_DatWr,
    output [ `PORT_DATAWIDTH         - 1 : 0 ] GBFWEI_DatWr,
    output [ `PORT_DATAWIDTH         - 1 : 0 ] GBFFLGACT_DatWr,
    output [ `PORT_DATAWIDTH         - 1 : 0 ] GBFACT_DatWr,
    input   [`PORT_DATAWIDTH          - 1 : 0 ] GBFFLGOFM_DatRd,
    input   [`PORT_DATAWIDTH          - 1 : 0 ] GBFOFM_DatRd,
    output reg[ `GBFFLGWEI_ADDRWIDTH           -1 : 0] GBFFLGWEI_AddrWr,
    input [ `GBFFLGWEI_ADDRWIDTH           -1 : 0] GBFFLGWEI_AddrRd,
    output  reg [ `GBFWEI_ADDRWIDTH           -1 : 0] GBFWEI_AddrWr,
    input [ `GBFWEI_ADDRWIDTH           -1 : 0] GBFWEI_AddrRd,
    output  reg [ `GBFFLGACT_ADDRWIDTH           -1 : 0] GBFFLGACT_AddrWr,
    input [ `GBFFLGACT_ADDRWIDTH           -1 : 0] GBFFLGACT_AddrRd,
    output reg [ `GBFACT_ADDRWIDTH           -1 : 0] GBFACT_AddrWr,
    input [ `GBFACT_ADDRWIDTH           -1 : 0] GBFACT_AddrRd,
    input  [ `GBFFLGOFM_ADDRWIDTH        -1 : 0] GBFFLGOFM_AddrWr,
    output reg [ `GBFFLGOFM_ADDRWIDTH        -1 : 0] GBFFLGOFM_AddrRd,
    input  [ `GBFOFM_ADDRWIDTH           -1 : 0] GBFOFM_AddrWr,
    output reg [ `GBFOFM_ADDRWIDTH           -1 : 0] GBFOFM_AddrRd,
    output                                       GBFFLGWEI_EnWr,
    input                                       GBFFLGWEI_EnRd,
    output                                       GBFWEI_EnWr,
    input                                       GBFWEI_EnRd,
    output                                       GBFFLGACT_EnWr,
    input                                       GBFFLGACT_EnRd,
    output                                       GBFACT_EnWr,
    input                                       GBFACT_EnRd,
    input                                       GBFFLGOFM_EnWr,
    output                                       GBFFLGOFM_EnRd,
    input                                       GBFOFM_EnWr,
    output                                       GBFOFM_EnRd,
    input                                   O_spi_sck     , //FPGA //PAD 100 pad
    input [ `PORT_DATAWIDTH         - 1 : 0 ]     I_spi_data,
    output [ `PORT_DATAWIDTH         - 1 : 0 ]    O_spi_data,
    input                                   O_spi_cs_n    , //FPGA //PAD
    output                               config_req    , //FPGA //PAD
    output                                  near_full,
    output reg                          Switch_RdWr

);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================
localparam IFCFG_CFG = 4'd0;
localparam IFCFG_FLGWEI = 4'd8;
localparam IFCFG_WEI = 4'd6;
localparam IFCFG_FLGACT = 4'd4;
localparam IFCFG_ACT = 4'd2;
localparam IFCFG_FLGOFM = 4'd10;/////////////////////////////////////////////
localparam IFCFG_OFM = 4'd11;


//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================
wire                        IF_Rdy;
wire                        IF_Req;
wire [4         - 1:0]   IF_Cfg;
wire                        ValRd;
wire [`PORT_DATAWIDTH  - 1: 0] DatRd;
wire [`PORT_DATAWIDTH  - 1: 0] DatWr;
reg [ 4               - 1 : 0 ]O_config_data;

wire                        RdyWr;
wire                          ValWr;
wire                        GBFFLGOFM_EnRd_d;
wire                        GBFOFM_EnRd_d;
wire                        config_req_rd;
wire                        config_req_wr;
reg                         Reset_WEI_IF_CFG;
//=====================================================================================================================
// Logic Design :
//=====================================================================================================================


always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        GBFFLGWEI_AddrWr <= 0;
    end else if (Reset_WEI ) begin
        GBFFLGWEI_AddrWr <= 0;
    end else if ( GBFFLGWEI_EnWr ) begin
        GBFFLGWEI_AddrWr <= GBFFLGWEI_AddrWr + 1;
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        GBFWEI_AddrWr <= 0;
    end else if (Reset_WEI ) begin
        GBFWEI_AddrWr <= 0;
    end else if ( GBFWEI_EnWr ) begin
        GBFWEI_AddrWr <= GBFWEI_AddrWr + 1;
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        GBFFLGACT_AddrWr <= 0;
    end else if (Reset_ACT ) begin
        GBFFLGACT_AddrWr <= 0;
    end else if ( GBFFLGACT_EnWr ) begin
        GBFFLGACT_AddrWr <= GBFFLGACT_AddrWr + 1;
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        GBFACT_AddrWr <= 0;
    end else if ( Reset_ACT) begin
        GBFACT_AddrWr <= 0;
    end else if ( GBFACT_EnWr ) begin
        GBFACT_AddrWr <= GBFACT_AddrWr + 1;
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        GBFFLGOFM_AddrRd <= 0;
    end else if ( Reset_OFM) begin
        GBFFLGOFM_AddrRd <= 0;
    end else if ( GBFFLGOFM_EnRd ) begin
        GBFFLGOFM_AddrRd <= GBFFLGOFM_AddrRd + 1;
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        GBFOFM_AddrRd <= 0;
    end else if ( Reset_OFM) begin
        GBFOFM_AddrRd <= 0;
    end else if ( GBFOFM_EnRd ) begin
        GBFOFM_AddrRd <= GBFOFM_AddrRd + 1;
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        O_config_data <= 0;
    end else if ( IF_Req ) begin
        O_config_data <= IF_Cfg;
    end
end

assign IFCFG_Val = O_config_data==IFCFG_CFG  && ValRd;
assign GBFFLGWEI_EnWr = O_config_data==IFCFG_FLGWEI  && ValRd;
assign GBFWEI_EnWr = O_config_data==IFCFG_WEI  && ValRd;
assign GBFFLGACT_EnWr = O_config_data==IFCFG_FLGACT && ValRd;
assign GBFACT_EnWr = O_config_data==IFCFG_ACT && ValRd;

assign IFCFG = O_config_data == IFCFG_CFG? DatRd : 0;
assign GBFFLGWEI_DatWr = O_config_data==IFCFG_FLGWEI ? DatRd : 0;
assign GBFWEI_DatWr = O_config_data==IFCFG_WEI ? DatRd : 0;
assign GBFFLGACT_DatWr = O_config_data==IFCFG_FLGACT ? DatRd: 0;
assign GBFACT_DatWr = O_config_data==IFCFG_ACT ? DatRd : 0;
assign DatWr = O_config_data == IFCFG_FLGOFM? GBFFLGOFM_DatRd : GBFOFM_DatRd;
assign ValWr = O_config_data == IFCFG_FLGOFM? GBFFLGOFM_EnRd_d : GBFOFM_EnRd_d;

assign GBFFLGOFM_EnRd = O_config_data == IFCFG_FLGOFM && RdyWr;////////////////////// write part
assign GBFOFM_EnRd = O_config_data == IFCFG_OFM && RdyWr;
wire [`PORT_DATAWIDTH        -1 : 0] O_spi_data_rd;
wire [`PORT_DATAWIDTH        -1 : 0] O_spi_data_wr;
wire                                                    IF_Rdy_rd;
wire                                                    IF_Rdy_wr;
//reg Switch_RdWr;
wire            IF_RdWr;
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        Switch_RdWr<= 1;
    end else if ( IF_Req ) begin //
        Switch_RdWr <= IF_RdWr;
    end
end

assign O_spi_data = Switch_RdWr ? O_spi_data_rd : O_spi_data_wr;
assign config_req = Switch_RdWr ? config_req_rd : config_req_wr;
assign IF_Rdy = Switch_RdWr ? IF_Rdy_rd: IF_Rdy_wr;

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        Reset_WEI_IF_CFG <= 0;
    end else if ( Reset_WEI ) begin
        Reset_WEI_IF_CFG <= 1;
    end else if ( IF_Req )begin//Fetched by _rd
        Reset_WEI_IF_CFG <= 0;
    end
end
//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================
   IFARB IFARB
        (
            .clk              (clk),
            .rst_n            (rst_n),
            .Reset            (Reset),
            .Reset_WEI  ( Reset_WEI),
            .Reset_ACT  ( Reset_ACT),
            .Reset_OFM ( Reset_OFM),
            .IF_Val             (IF_Val ),
            .CFG_Req          (CFG_Req),
            .GBFFLGWEI_AddrWr (GBFFLGWEI_AddrWr),
            .GBFFLGWEI_AddrRd (GBFFLGWEI_AddrRd),
            .GBFWEI_AddrWr    (GBFWEI_AddrWr),
            .GBFWEI_AddrRd    (GBFWEI_AddrRd),
            .GBFFLGACT_AddrWr (GBFFLGACT_AddrWr),
            .GBFFLGACT_AddrRd (GBFFLGACT_AddrRd),
            .GBFACT_AddrWr    (GBFACT_AddrWr),
            .GBFACT_AddrRd    (GBFACT_AddrRd),
            .GBFFLGOFM_AddrWr (GBFFLGOFM_AddrWr),
            .GBFFLGOFM_AddrRd (GBFFLGOFM_AddrRd),
            .GBFOFM_AddrWr    (GBFOFM_AddrWr),
            .GBFOFM_AddrRd    (GBFOFM_AddrRd),
            .GBFFLGWEI_EnWr   (GBFFLGWEI_EnWr),
            .GBFFLGWEI_EnRd   (GBFFLGWEI_EnRd),
            .GBFWEI_EnWr      (GBFWEI_EnWr),
            .GBFWEI_EnRd      (GBFWEI_EnRd),
            .GBFFLGACT_EnWr   (GBFFLGACT_EnWr),
            .GBFFLGACT_EnRd   (GBFFLGACT_EnRd),
            .GBFACT_EnWr      (GBFACT_EnWr),
            .GBFACT_EnRd      (GBFACT_EnRd),
            .GBFFLGOFM_EnWr   (GBFFLGOFM_EnWr),
            .GBFFLGOFM_EnRd   (GBFFLGOFM_EnRd),
            .GBFOFM_EnWr      (GBFOFM_EnWr),
            .GBFOFM_EnRd      (GBFOFM_EnRd),
            .IF_Cfg           (IF_Cfg),
            .IF_RdWr          (IF_RdWr),
            .IF_Rdy           (IF_Rdy),
            .IF_Req           (IF_Req)
        );

top_asyncFIFO_rd #(
        .SPI_WIDTH(`PORT_DATAWIDTH),
        .ADDR_WIDTH_FIFO(`ASYSFIFO_ADDRWIDTH)
    ) top_asyncFIFO_rd0 (
        .clk_chip      (clk),
        .reset_n_chip  (rst_n),
        .O_spi_sck     (O_spi_sck),
        .I_spi_data    (I_spi_data),
        .O_spi_data    (O_spi_data_rd),
        .O_spi_cs_n    (O_spi_cs_n),
        .config_req    (config_req_rd),
        .full          (near_full      ),

        .config_ready  (IF_Rdy_rd),
        .config_paulse (IF_Req && IF_RdWr),
        .config_data   (IF_Cfg),
        .Reset_WEI_IF_CFG ( Reset_WEI_IF_CFG),
        .O_config_data (  ),
        .rd_req        (1'b1),
        .rd_valid      (ValRd),
        .rd_data       (DatRd),
        .rd_done        ( IF_RdDone)
    );


    top_asyncFIFO_wr #(
            .SPI_WIDTH(`PORT_DATAWIDTH),
            .ADDR_WIDTH_FIFO(`ASYSFIFO_ADDRWIDTH)
        ) top_asyncFIFO_wr (
            .clk_chip      (clk),
            .reset_n_chip  (rst_n),
            .O_spi_sck     (O_spi_sck),
            .IO_spi_data   (O_spi_data_wr),
            .O_spi_cs_n    (O_spi_cs_n ),
            .config_req    (config_req_wr),//save enough, then req to FPGA

            .config_ready  (IF_Rdy_wr),
            .config_paulse (IF_Req&&~IF_RdWr),
            .config_data   (O_config_data),
            .wr_ready      (RdyWr),/////////////////////////////////////////////////////////////////
            .wr_req        (ValWr),
            .wr_data       (DatWr)
        );
Delay #(
    .NUM_STAGES(1),
    .DATA_WIDTH(1)
    )Delay_GBFFLGOFM_EnRd_d
    (
        .CLK(clk),
        .RESET_N(rst_n),
        .DIN(GBFFLGOFM_EnRd),
        .DOUT(GBFFLGOFM_EnRd_d)
        );
Delay #(
    .NUM_STAGES(1),
    .DATA_WIDTH(1)
    )Delay_GBFOFM_EnRd_d
    (
        .CLK(clk),
        .RESET_N(rst_n),
        .DIN(GBFOFM_EnRd),
        .DOUT(GBFOFM_EnRd_d)
        );
/*
always @ ( posedge clk or negedge rst_n ) begin
    if(~ rst_n) begin
        IF_Cfg <= 0;
        IF_RdWr <= 0;
    end else if ( CFG_Req ) begin
       IF_Cfg  <= IFCFG_CFG;//
       IF_RdWr = 1;
    end else if( Req_FLGWEI) begin
        IF_Cfg <= IFCFG_FLGWEI;
        IF_RdWr <= 1;
    end else if( Req_WEI) begin
        IF_Cfg <= IFCFG_WEI;
        IF_RdWr <= 1;
    end else if( Req_FLGACT) begin
        IF_Cfg <= IFCFG_FLGACT;
        IF_RdWr <= 1;
    end else if ( Req_ACT)begin
        IF_Cfg <= IFCFG_ACT;
        IF_RdWr <= 1;
    end else if(Req_FLGOFM) begin
        IF_Cfg <= IFCFG_FLGOFM;
        IF_RdWr <= 0;
    end else if(Req_OFM) begin
        IF_Cfg <= IFCFG_OFM;
        IF_RdWr <= 0;
    end else
        IF_Cfg <= 4'd0; //
        IF_RdWr <= 1;
end
*/
endmodule
