`include "../source/include/dw_params_presim.vh"
module test_GBF #(
    parameter NumClk = 1,
    parameter FILE_GBFFLGWEI = "",
    parameter FILE_GBFFLGWEI_FTRGRPADDR = "",
    parameter DATA_WIDTH = 96,
    parameter Str_Name = "",
    parameter PEB = 0,
    parameter PEC = 0

    )(
    input                               Reset_FtrLay,
    input                               Reset_FtrGrp,
    input                               Next_FtrGrp,

    input                               GBFFLGWEI_EnWr,
    input [ DATA_WIDTH          -1 : 0] GBFFLGWEI_DatWr_Mon

  );

reg [DATA_WIDTH                - 1 : 0 ] GBFFLGWEI_DatWr[0:2**20 - 1];
reg [DATA_WIDTH                - 1 : 0 ] GBFFLGWEI_FtrGrpAddr[0:2**10 - 1];

reg [ 30                            - 1 : 0 ] GBFFLGWEI_AddrWr;
reg [ 10                            - 1 : 0 ] GBFFLGWEI_CntFtrGrp;

initial begin : GBFWEI_fopen
    $readmemh(FILE_GBFFLGWEI, GBFFLGWEI_DatWr);
    GBFFLGWEI_AddrWr = 0;
    $readmemh(FILE_GBFFLGWEI_FTRGRPADDR, GBFFLGWEI_FtrGrpAddr);// absolute Addr
    GBFFLGWEI_CntFtrGrp = 0;  

    @(posedge mem_controller_tb.ASIC.TS3D.rst_n );
    repeat(NumClk) begin
        @(negedge mem_controller_tb.ASIC.TS3D.clk);// use mem_controller_tb.ASIC.clk
        if (Reset_FtrLay ) begin // upest
            @(negedge mem_controller_tb.ASIC.IF.top_asyncFIFO_rd0.config_paulse )
            GBFFLGWEI_AddrWr = 0;
            GBFFLGWEI_CntFtrGrp = 0;
        end
        if (Next_FtrGrp) begin 
            @(negedge mem_controller_tb.ASIC.IF.top_asyncFIFO_rd0.config_paulse ) //Wait re Config Rd
            GBFFLGWEI_CntFtrGrp = GBFFLGWEI_CntFtrGrp + 1;
            GBFFLGWEI_AddrWr = GBFFLGWEI_FtrGrpAddr[GBFFLGWEI_CntFtrGrp];
        end
        if (Reset_FtrGrp)begin//paulse
            @(negedge mem_controller_tb.ASIC.IF.top_asyncFIFO_rd0.config_paulse ) //Wait re Config Rd
            GBFFLGWEI_AddrWr = GBFFLGWEI_FtrGrpAddr[GBFFLGWEI_CntFtrGrp];
        end

        if ( GBFFLGWEI_EnWr) begin
            if(GBFFLGWEI_DatWr_Mon !=GBFFLGWEI_DatWr[GBFFLGWEI_AddrWr] )
                $display("ERROR time: %t, PEB[%d].PEC[%d]. %s : Mon = %h <=> Ref = %h", $time, PEB, PEC, Str_Name, GBFFLGWEI_DatWr_Mon,GBFFLGWEI_DatWr[GBFFLGWEI_AddrWr]);
            GBFFLGWEI_AddrWr = GBFFLGWEI_AddrWr + 1;
        end
    end
end

endmodule 

module test_PECMAC #(
    parameter NumClk = 1,
    parameter FILE_GBFFLGWEI = "",
    parameter FILE_GBFFLGWEI_FTRGRPADDR = "",
    parameter DATA_WIDTH = 96,
    parameter Str_Name = "",
    parameter PEB = 0,
    parameter PEC = 0

    )(
    input                               Reset_FtrLay,
    input                               Reset_FtrGrp,
    input                               Next_FtrGrp,

    input                               GBFFLGWEI_EnWr,
    input [ DATA_WIDTH          -1 : 0] GBFFLGWEI_DatWr_Mon,
    input                               Wait

  );

reg [DATA_WIDTH                - 1 : 0 ] GBFFLGWEI_DatWr[0:2**20 - 1];
reg [DATA_WIDTH                - 1 : 0 ] GBFFLGWEI_FtrGrpAddr[0:2**10 - 1];

reg [ 30                            - 1 : 0 ] GBFFLGWEI_AddrWr;
reg [ 10                            - 1 : 0 ] GBFFLGWEI_CntFtrGrp;

initial begin : GBFWEI_fopen
    $readmemh(FILE_GBFFLGWEI, GBFFLGWEI_DatWr);
    GBFFLGWEI_AddrWr = 0;
    $readmemh(FILE_GBFFLGWEI_FTRGRPADDR, GBFFLGWEI_FtrGrpAddr);// absolute Addr
    GBFFLGWEI_CntFtrGrp = 0;  

    @(posedge mem_controller_tb.ASIC.TS3D.rst_n );
    repeat(NumClk) begin
        @(negedge mem_controller_tb.ASIC.TS3D.clk);// use mem_controller_tb.ASIC.clk
        if (Reset_FtrLay ) begin // upest
            @(negedge Wait )
            GBFFLGWEI_AddrWr = 0;
            GBFFLGWEI_CntFtrGrp = 0;
        end
        if (Next_FtrGrp) begin 
            @(negedge Wait ) //Wait re Config Rd
            GBFFLGWEI_CntFtrGrp = GBFFLGWEI_CntFtrGrp + 1;
            GBFFLGWEI_AddrWr = GBFFLGWEI_FtrGrpAddr[GBFFLGWEI_CntFtrGrp];
        end
        if (Reset_FtrGrp)begin//paulse
            @(negedge Wait ) //Wait re Config Rd
            GBFFLGWEI_AddrWr = GBFFLGWEI_FtrGrpAddr[GBFFLGWEI_CntFtrGrp];
        end

        if ( GBFFLGWEI_EnWr) begin
            if(GBFFLGWEI_DatWr_Mon !=GBFFLGWEI_DatWr[GBFFLGWEI_AddrWr] )
                $display("ERROR time: %t, PEB[%d].PEC[%d]. %s : Mon = %h <=> Ref = %h", $time, PEB, PEC, Str_Name, GBFFLGWEI_DatWr_Mon,GBFFLGWEI_DatWr[GBFFLGWEI_AddrWr]);
            GBFFLGWEI_AddrWr = GBFFLGWEI_AddrWr + 1;
        end
    end
end

endmodule 