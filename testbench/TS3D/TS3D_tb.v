`include "../include/dw_params_presim.vh"

module TS3D_tb;
parameter PSUM_WIDTH = (`DATA_WIDTH *2 + `C_LOG_2(`CHANNEL_DEPTH) + 2 );
parameter NumClk = 32000;
// TS3D Inputs
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;
reg   [ `NUMPEB                    -1 : 0]  POOLPEB_EnRd = 0 ;
reg   [ `C_LOG_2(`LENPSUM)         -1 : 0]  POOLPEB_AddrRd = 0 ;
reg   GBFWEI_Val                           = 1 ;
reg   GBFWEI_EnWr                          = 0 ;
reg   [ `GBFWEI_ADDRWIDTH           -1 : 0]  GBFWEI_AddrWr = 0 ;
reg   [ `GBFWEI_DATAWIDTH           -1 : 0]  GBFWEI_DatWr = 0 ;
reg   GBFFLGWEI_Val                        = 1 ;
reg   GBFFLGWEI_EnWr                       = 0 ;
reg   [ `GBFWEI_ADDRWIDTH           -1 : 0]  GBFFLGWEI_AddrWr = 0 ;
reg   [ `GBFFLGWEI_DATAWIDTH        -1 : 0]  GBFFLGWEI_DatWr = 0 ;
reg   GBFACT_Val                           = 1 ;
reg   GBFACT_EnWr                          = 0 ;
reg   [ `GBFACT_ADDRWIDTH          -1 : 0]  GBFACT_AddrWr = 0 ;
reg   [ `DATA_WIDTH                -1 : 0]  GBFACT_DatWr = 0 ;
reg   GBFFLGACT_Val                        = 1 ;
reg   GBFFLGACT_EnWr                       = 0 ;
reg   [ `GBFACT_ADDRWIDTH          -1 : 0]  GBFFLGACT_AddrWr = 0 ;
reg   [ `BLOCK_DEPTH               -1 : 0]  GBFFLGACT_DatWr = 0 ;
reg   GBFVNACT_Val                         = 1 ;
reg   GBFVNACT_EnWr                        = 0 ;
reg   [ `GBFACT_ADDRWIDTH          -1 : 0]  GBFVNACT_AddrWr = 0 ;
reg   [ `C_LOG_2(`BLOCK_DEPTH)     -1 : 0]  GBFVNACT_DatWr = 0 ;

// TS3D Outputs
wire  [ PSUM_WIDTH * `LENPSUM      -1 : 0]  PELPOOL_Dat ;

// TS3D Bidirs
    reg                                                                    GBFOFM_EnRd;
    reg  [ `GBFOFM_ADDRWIDTH                  -1 : 0] GBFOFM_AddrRd;
    wire [ `PORT_DATAWIDTH                      -1 : 0] GBFOFM_DatRd;
    reg                                                                    GBFFLGOFM_EnRd;
    reg   [ `GBFFLGOFM_ADDRWIDTH           - 1 :0 ] GBFFLGOFM_AddrRd;
    wire  [ `PORT_DATAWIDTH                    - 1 : 0 ] GBFFLGOFM_DatRd;


initial
begin
    //$shm_open ("db_name", is_sequence_time, db_size, is_compression, incsize,incfiles);
    $shm_open ("shm_presim");
    $shm_probe(TS3D, "AS");
end
`ifdef SYNTH_MINI
    initial begin
        // $fsdbDumpfile("TS3D_tb.fsdb");
        // $fsdbDumpvars();
        // $dumpfile("TS3D_tb.vcd");
        // $dumpvars;
        repeat(NumClk) @(posedge clk);
        $finish;
    end
`endif
initial
begin
    clk= 1;
    forever #5  clk=~clk;
end

initial
begin
    rst_n  =  1;
    #25  rst_n  =  0;
    #100 rst_n  =  1;
end

generate
    genvar i,j;
    for(i=0;i<`NUMPEB;i=i+1) begin:Mon_PEB
        for(j=0;j<3;j=j+1) begin:Mon_PEC

            integer PECMAC_FlgAct_Mon;
            integer PECMAC_FlgAct_Gen;
            integer PECMAC_Act_Mon;
            integer PECMAC_Act_Gen;
            integer Suc_FlgAct;
            integer Suc_Act;
            integer Suc_DatWr;
            reg [`BLOCK_DEPTH -  1 : 0]PECMAC_FlgAct_GenDat;
            reg [ `DATA_WIDTH * `BLOCK_DEPTH             -1 : 0]PECMAC_Act_GenDat;
            reg [ 8 -1 :0 ] Number;
            //Number = i*j;
            initial begin
                PECMAC_FlgAct_Mon = $fopen("../testbench/Data/MonRTL/PECMAC_FlgAct_Mon.dat"+Number,"w");
                PECMAC_FlgAct_Gen = $fopen("../testbench/Data/GenTest/PECMAC_FlgAct_Gen.dat","r");
                PECMAC_Act_Mon = $fopen("../testbench/Data/MonRTL/PECMAC_Act_Mon.dat","w");
                PECMAC_Act_Gen = $fopen("../testbench/Data/GenTest/PECMAC_Act_Gen.dat","r");


                repeat(NumClk) begin
                    @(negedge clk);
                    if(TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[j].inst_PEC.CfgMac) begin
                        @(negedge clk);
                        $fdisplay(PECMAC_FlgAct_Mon,"%b",TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[j].inst_PEC.PECMAC_FlgAct);
                        $fdisplay(PECMAC_Act_Mon,"%h",TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[j].inst_PEC.PECMAC_Act);
                        Suc_FlgAct = $fscanf(PECMAC_FlgAct_Gen,"%b",PECMAC_FlgAct_GenDat);
                        Suc_Act=$fscanf(PECMAC_Act_Gen,"%h",PECMAC_Act_GenDat);

                        if(TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[j].inst_PEC.PECMAC_FlgAct != PECMAC_FlgAct_GenDat)
                            $display("ERROR time: %t  PEB[%d].PEC[%d].PECMAC_FlgAct = %b", $time,i,j, PECMAC_FlgAct_GenDat);

                        if(TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[j].inst_PEC.PECMAC_Act != PECMAC_Act_GenDat)
                            $display("ERROR time: %t  PEB[%d].PEC[%d].PECMAC_Act = %h",  $time,i,j, PECMAC_Act_GenDat);
                    end
                end
            end

            integer PECRAM_DatWr_Mon;
            integer PECRAM_DatWr_Ref;

            // .py zfill(81)
            reg [  `PSUM_WIDTH*`NUMPEC               -1 : 0] PECRAM_DatWr_RefDat;

            initial begin
                PECRAM_DatWr_Mon = $fopen("../testbench/Data/MonRTL/PECRAM_DatWr_Mon.dat","w");
                PECRAM_DatWr_Ref = $fopen("../testbench/Data/GenTest/PECRAM_DatWr_Ref.dat","r");


                repeat(NumClk) begin
                    @(negedge clk);
                    if(TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[j].inst_PEC.PECRAM_EnWr) begin
                        // @(negedge clk);
                        $fdisplay(PECRAM_DatWr_Mon,"%h",TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[j].inst_PEC.PECRAM_DatWr);
                        Suc_DatWr = $fscanf(PECRAM_DatWr_Ref,"%h",PECRAM_DatWr_RefDat);

                        if(TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[j].inst_PEC.PECRAM_DatWr != PECRAM_DatWr_RefDat[`PSUM_WIDTH * (`NUMPEC -(3*i+j))        -1 -:`PSUM_WIDTH ])
                            $display("ERROR time: %t  PEB[%d].PEC[%d].PECRAM_DatWr = %b", $time, i,j,TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[j].inst_PEC.PECRAM_DatWr);
                    end
                end
            end
        end
    end
endgenerate





TS3D  TS3D (
    .clk                     ( clk                                                     ),
    .rst_n                   ( rst_n                                                   ),

    .GBFWEI_Val              ( GBFWEI_Val                                              ),
    .GBFWEI_EnWr             ( GBFWEI_EnWr                                             ),
    .GBFWEI_AddrWr           ( GBFWEI_AddrWr     [ `GBFWEI_ADDRWIDTH           -1 : 0] ),
    .GBFWEI_DatWr            ( GBFWEI_DatWr      [ `GBFWEI_DATAWIDTH           -1 : 0] ),
    .GBFFLGWEI_Val           ( GBFFLGWEI_Val                                           ),
    .GBFFLGWEI_EnWr          ( GBFFLGWEI_EnWr                                          ),
    .GBFFLGWEI_AddrWr        ( GBFFLGWEI_AddrWr  [ `GBFWEI_ADDRWIDTH           -1 : 0] ),
    .GBFFLGWEI_DatWr         ( GBFFLGWEI_DatWr   [ `GBFFLGWEI_DATAWIDTH        -1 : 0] ),
    .GBFACT_Val              ( GBFACT_Val                                              ),
    .GBFACT_EnWr             ( GBFACT_EnWr                                             ),
    .GBFACT_AddrWr           ( GBFACT_AddrWr     [ `GBFACT_ADDRWIDTH          -1 : 0]  ),
    .GBFACT_DatWr            ( GBFACT_DatWr      [ `DATA_WIDTH                -1 : 0]  ),
    .GBFFLGACT_Val           ( GBFFLGACT_Val                                           ),
    .GBFFLGACT_EnWr          ( GBFFLGACT_EnWr                                          ),
    .GBFFLGACT_AddrWr        ( GBFFLGACT_AddrWr  [ `GBFACT_ADDRWIDTH          -1 : 0]  ),
    .GBFFLGACT_DatWr         ( GBFFLGACT_DatWr   [ `BLOCK_DEPTH               -1 : 0]  ),
    // .GBFVNACT_Val            ( GBFVNACT_Val                                            ),
    // .GBFVNACT_EnWr           ( GBFVNACT_EnWr                                           ),
    // .GBFVNACT_AddrWr         ( GBFVNACT_AddrWr   [ `GBFACT_ADDRWIDTH          -1 : 0]  ),
    // .GBFVNACT_DatWr          ( GBFVNACT_DatWr    [ `C_LOG_2(`BLOCK_DEPTH)     -1 : 0]  ),

    .GBFOFM_EnRd                (GBFOFM_EnRd),
    .GBFOFM_AddrRd          (GBFOFM_AddrRd),
    .GBFOFM_DatRd               (GBFOFM_DatRd),
    .GBFFLGOFM_EnRd             (GBFFLGOFM_EnRd),
    . GBFFLGOFM_AddrRd          ( GBFFLGOFM_AddrRd),
    . GBFFLGOFM_DatRd           ( GBFFLGOFM_DatRd)
);
endmodule
