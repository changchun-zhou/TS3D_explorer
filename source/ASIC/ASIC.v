//======================================================
// Copyright (C) 2020 By zhoucc
// All Rights Reserved
//======================================================
// Module : ASIC
// Author : CC zhou
// Contact :
// Date : 3 .8 .2020
//=======================================================
// Description :
//========================================================
`include "../source/include/dw_params_presim.vh"
module ASIC (
    input reset_n_pad         ,
    input reset_dll_pad      ,
    inout   [ `PORT_DATAWIDTH    -1 : 0 ] IO_spi_data_rd0_pad,
    input                           O_spi_sck_rd0_pad,
    input                           O_spi_cs_n_rd0_pad,
    input                           OE_req_rd0_pad,
    output                          config_req_rd0_pad,
    output                          near_full_rd0_pad,
    output                          Switch_RdWr_pad,
    input                           DLL_BYPASS_i_pad,
    output                           DLL_clock_out_pad,
    input                           clk_to_dll_i_pad    ,
    input                           S0_dll_pad

);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================





//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================
wire                                            clk;
wire                                            rst_n;
    wire                                     Reset;
    wire                                     Reset_WEI;
    wire                                     Reset_ACT;
    wire                                     Reset_OFM;
    wire                                     CFG_Req;
    wire [ `PORT_DATAWIDTH         - 1 : 0 ] IFCFG;
    wire                                                       IFCFG_Val;
    wire [ `PORT_DATAWIDTH         - 1 : 0 ] GBFFLGWEI_DatWr;
    wire [ `PORT_DATAWIDTH         - 1 : 0 ] GBFWEI_DatWr;
    wire [ `PORT_DATAWIDTH         - 1 : 0 ] GBFFLGACT_DatWr;
    wire [ `PORT_DATAWIDTH         - 1 : 0 ] GBFACT_DatWr;
    wire [`PORT_DATAWIDTH          - 1 : 0 ] GBFFLGOFM_DatRd;
    wire [`PORT_DATAWIDTH          - 1 : 0 ] GBFOFM_DatRd;
    wire [ `GBFFLGWEI_ADDRWIDTH           -1 : 0] GBFFLGWEI_AddrWr;
    wire [ `GBFFLGWEI_ADDRWIDTH           -1 : 0] GBFFLGWEI_AddrRd;
    wire [ `GBFWEI_ADDRWIDTH           -1 : 0] GBFWEI_AddrWr;
    wire [ `GBFWEI_ADDRWIDTH           -1 : 0] GBFWEI_AddrRd;
    wire [ `GBFFLGACT_ADDRWIDTH           -1 : 0] GBFFLGACT_AddrWr;
    wire [ `GBFFLGACT_ADDRWIDTH           -1 : 0] GBFFLGACT_AddrRd;
    wire [ `GBFACT_ADDRWIDTH           -1 : 0] GBFACT_AddrWr;
    wire [ `GBFACT_ADDRWIDTH           -1 : 0] GBFACT_AddrRd;
    wire [ `GBFFLGOFM_ADDRWIDTH        -1 : 0] GBFFLGOFM_AddrRd;
    wire [ `GBFFLGOFM_ADDRWIDTH        -1 : 0] GBFFLGOFM_AddrWr;
    wire [ `GBFOFM_ADDRWIDTH           -1 : 0] GBFOFM_AddrWr;
    wire [ `GBFOFM_ADDRWIDTH           -1 : 0] GBFOFM_AddrRd;
    wire                                       GBFFLGWEI_EnWr;
    wire                                     GBFFLGWEI_EnRd;
    wire                                       GBFWEI_EnWr;
    wire                                     GBFWEI_EnRd;
    wire                                       GBFFLGACT_EnWr;
    wire                                     GBFFLGACT_EnRd;
    wire                                       GBFACT_EnWr;
    wire                                     GBFACT_EnRd;
    wire                                     GBFFLGOFM_EnWr;
    wire                                       GBFFLGOFM_EnRd;
    wire                                     GBFOFM_EnWr;
    wire                                       GBFOFM_EnRd;
reg  pad_OE_rd0;
wire [ `PORT_DATAWIDTH  - 1 : 0 ] I_spi_data_rd0;
wire [ `PORT_DATAWIDTH  - 1 : 0 ] O_spi_data_rd0;
wire                                                config_req_rd0;
wire                                                    OE_req_rd0;
wire                                                IF_Val;
wire                                                Switch_RdWr;
//=====================================================================================================================
// Logic Design :
//=====================================================================================================================
always @ ( posedge clk ) begin
    pad_OE_rd0 <= ( config_req_rd0 && !OE_req_rd0 )|| ~Switch_RdWr; // PAD turns direction needs time: default = 0 write
end





//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================
  supply0 VSS,VSSIO,VSSA;
  supply1 VDD,VDDIO,VDDA;

IPOC IPOC_cell (.PORE(PORE),.VDD(VDD), .VSS(VSS),.VDDIO(VDDIO));
IUMBFS reset_n_PAD  (.DO (1'b0 ), .IDDQ (1'b0), .IE (1'b1), .OE (1'b0), .PD (1'b0), .PIN1 (1'b0), .PIN2 (1'b0), .PU (1'b0), .SMT (1'b0), .DI (rst_n), .PAD (reset_n_pad ), .PORE (PORE));
IUMBFS reset_dll_PAD  (.DO (1'b0 ), .IDDQ (1'b0), .IE (1'b1), .OE (1'b0), .PD (1'b0), .PIN1 (1'b0), .PIN2 (1'b0), .PU (1'b0), .SMT (1'b0), .DI (reset_dll), .PAD (reset_dll_pad ), .PORE (PORE));
wire DLL_BYPASS_i;
wire DLL_S1_i    ;
wire clk_to_dll_i;


  IUMBFS BYPASS_PAD(.DO (1'b0), .IDDQ (1'b0), .IE(1'b1), .OE (1'b0), .PD (1'b0), .PIN1 (1'b0), .PIN2 (1'b0), .PU(1'b0), .SMT (1'b0), .DI (DLL_BYPASS_i), .PAD(DLL_BYPASS_i_pad), .PORE (PORE));

  IUMBFS DLL_CLOCK_OUT_PAD(.DO (clk), .IDDQ (1'b0), .IE
       (1'b0), .OE (1'b1), .PD (1'b0), .PIN1 (1'b1), .PIN2 (1'b1), .PU
       (1'b0), .SMT (1'b0), .DI ( ), .PAD
       (DLL_clock_out_pad), .PORE (PORE));

  IUMBFS DLL_clk_PAD(.DO (1'b0), .IDDQ (1'b0), .IE
       (1'b1), .OE (1'b0), .PD (1'b0), .PIN1 (1'b1), .PIN2 (1'b1), .PU
       (1'b0), .SMT (1'b0), .DI (clk), .PAD
       (clk_to_dll_i_pad), .PORE (PORE));


  IUMBFS S0_dll_PAD  (.DO (1'b0 ), .IDDQ (1'b0), .IE (1'b1), .OE (1'b0), .PD (1'b0), .PIN1 (1'b0), .PIN2 (1'b0), .PU (1'b0), .SMT (1'b0), .DI (S0_dll), .PAD (S0_dll_pad ), .PORE (PORE));
//wire outclk_dll;
//  DLL DLL_i (.CLK(clk), .RST(reset_dll), .BYPASS(DLL_BYPASS_i), .S1(1'b0), .S0( S0_dll), .OUTCLK(outclk_dll ), .VDDA(VDDA), .VSSA(VSSA) );

generate
  genvar k;
  for ( k=0; k<`PORT_DATAWIDTH; k=k+1 ) begin: IO_spi_data_PAD_rd0_GEN
    IUMBFS IO_spi_data_PAD_rd0 (.DO (O_spi_data_rd0[k]), .IDDQ (1'b0), .IE (1'b1), .OE (pad_OE_rd0), .PD (1'b0), .PIN1 (1'b0), .PIN2 (1'b0), .PU (1'b0), .SMT (1'b0), .DI (I_spi_data_rd0[k]), .PAD (IO_spi_data_rd0_pad[k]), .PORE (PORE));
  end
endgenerate

IUMBFS O_spi_sck_PAD_rd0    (.DO ( 1'b0              ), .IDDQ (1'b0), .IE (1'b1), .OE (1'b0), .PD (1'b0), .PIN1 (1'b0), .PIN2 (1'b0), .PU (1'b0), .SMT (1'b0), .DI (O_spi_sck_rd0     ), .PAD (O_spi_sck_rd0_pad    ), .PORE (PORE));
IUMBFS O_spi_cs_n_PAD_rd0   (.DO ( 1'b0              ), .IDDQ (1'b0), .IE (1'b1), .OE (1'b0), .PD (1'b0), .PIN1 (1'b0), .PIN2 (1'b0), .PU (1'b0), .SMT (1'b0), .DI (O_spi_cs_n_rd0    ), .PAD (O_spi_cs_n_rd0_pad   ), .PORE (PORE));
IUMBFS OE_req_PAD_rd0       (.DO ( 1'b0              ), .IDDQ (1'b0), .IE (1'b1), .OE (1'b0), .PD (1'b0), .PIN1 (1'b0), .PIN2 (1'b0), .PU (1'b0), .SMT (1'b0), .DI (OE_req_rd0        ), .PAD (OE_req_rd0_pad       ), .PORE (PORE));
IUMBFS near_full_PAD_rd0    (.DO (near_full_rd0   ),.IDDQ (1'b0), .IE (1'b0), .OE (1'b1), .PD (1'b0), .PIN1 (1'b1), .PIN2 (1'b1), .PU (1'b0), .SMT (1'b0), .DI (                  ), .PAD (near_full_rd0_pad    ), .PORE (PORE));
IUMBFS Switch_RdWr_PAD    (.DO (Switch_RdWr   ),.IDDQ (1'b0), .IE (1'b0), .OE (1'b1), .PD (1'b0), .PIN1 (1'b1), .PIN2 (1'b1), .PU (1'b0), .SMT (1'b0), .DI (                  ), .PAD (Switch_RdWr_pad    ), .PORE (PORE));
IUMBFS config_req_PAD_rd0   (.DO ( config_req_rd0 ),.IDDQ (1'b0), .IE (1'b0), .OE (1'b1), .PD (1'b0), .PIN1 (1'b0), .PIN2 (1'b0), .PU (1'b0), .SMT (1'b0), .DI (                  ), .PAD (config_req_rd0_pad   ), .PORE (PORE));
wire IF_RdDone;

    IF IF
        (
            .clk              (clk),
            .rst_n            (rst_n),
            .Reset            (Reset),
            .Reset_WEI   ( Reset_WEI),
            .Reset_ACT   ( Reset_ACT),
            .Reset_OFM   ( Reset_OFM),
            .IF_Val               ( IF_Val),
            .IF_RdDone ( IF_RdDone ),
            .CFG_Req          (CFG_Req),
            .IFCFG            (IFCFG),
            .IFCFG_Val        (IFCFG_Val),
            .GBFFLGWEI_DatWr  (GBFFLGWEI_DatWr),
            .GBFWEI_DatWr     (GBFWEI_DatWr),
            .GBFFLGACT_DatWr  (GBFFLGACT_DatWr),
            .GBFACT_DatWr     (GBFACT_DatWr),
            .GBFFLGOFM_DatRd   (GBFFLGOFM_DatRd),
            .GBFOFM_DatRd      (GBFOFM_DatRd),
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
            .O_spi_sck        (O_spi_sck_rd0),
            .I_spi_data       (I_spi_data_rd0),
            .O_spi_data       (O_spi_data_rd0),
            .O_spi_cs_n       (O_spi_cs_n_rd0),
            .config_req       (config_req_rd0),
            .near_full        (near_full_rd0),
            .Switch_RdWr ( Switch_RdWr)

        );
TS3D  TS3D (
    .clk                     ( clk                                                              ),
    .rst_n                   ( rst_n                                                            ),
    .IF_RdDone    ( IF_RdDone),
    .IF_Val             ( IF_Val),
    .IFCFG                   ( IFCFG                                 ),
    .IFCFG_Val               ( IFCFG_Val                                                        ),
 //   .GBFWEI_Val              ( 1'b1                                                       ),
    .GBFWEI_EnWr             ( GBFWEI_EnWr                                                      ),
    .GBFWEI_AddrWr           ( GBFWEI_AddrWr               ),
    .GBFWEI_AddrRd           ( GBFWEI_AddrRd              ),
    .GBFWEI_DatWr            ( GBFWEI_DatWr                 ),
   // .GBFFLGWEI_Val           ( 1'b1                                                    ),
    .GBFFLGWEI_EnWr          ( GBFFLGWEI_EnWr                                                   ),
    .GBFFLGWEI_AddrWr        ( GBFFLGWEI_AddrWr         ),
    .GBFFLGWEI_AddrRd        ( GBFFLGWEI_AddrRd           ),
    .GBFFLGWEI_DatWr         ( GBFFLGWEI_DatWr                 ),
    .GBFACT_EnWr             ( GBFACT_EnWr                                                      ),
    .GBFACT_AddrWr           ( GBFACT_AddrWr                ),
    .GBFACT_AddrRd           ( GBFACT_AddrRd               ),
    .GBFACT_DatWr            ( GBFACT_DatWr             ),
   // .GBFFLGACT_Val           ( 1'b1                                                    ),
    .GBFFLGACT_EnWr          ( GBFFLGACT_EnWr                                                   ),
    .GBFFLGACT_AddrWr        ( GBFFLGACT_AddrWr            ),
    .GBFFLGACT_AddrRd        ( GBFFLGACT_AddrRd             ),
    .GBFFLGACT_DatWr         ( GBFFLGACT_DatWr           ),
    .GBFOFM_EnRd             ( GBFOFM_EnRd                                                      ),
    .GBFOFM_AddrRd           ( GBFOFM_AddrRd       ),
    .GBFOFM_AddrWr           ( GBFOFM_AddrWr        ),
    .GBFFLGOFM_EnRd          ( GBFFLGOFM_EnRd                                                   ),
    .GBFFLGOFM_AddrRd        ( GBFFLGOFM_AddrRd       ),
    .GBFFLGOFM_AddrWr        ( GBFFLGOFM_AddrWr       ),

    .Reset                   ( Reset                                                            ),
            .Reset_WEI   ( Reset_WEI),
            .Reset_ACT   ( Reset_ACT),
            .Reset_OFM   ( Reset_OFM),
    .CFG_Req                 ( CFG_Req                                                          ),
    .GBFWEI_EnRd             ( GBFWEI_EnRd                                                      ),
    .GBFFLGWEI_EnRd          ( GBFFLGWEI_EnRd                                                   ),
    .GBFACT_EnRd             ( GBFACT_EnRd                                                      ),
    .GBFFLGACT_EnRd          ( GBFFLGACT_EnRd                                                   ),
    .GBFOFM_EnWr             ( GBFOFM_EnWr                                                      ),
    .GBFOFM_DatRd            ( GBFOFM_DatRd      ),
    .GBFFLGOFM_EnWr          ( GBFFLGOFM_EnWr                                                   ),
    .GBFFLGOFM_DatRd         ( GBFFLGOFM_DatRd   )
);

endmodule
