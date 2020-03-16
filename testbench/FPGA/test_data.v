//======================================================
// Copyright (C) 2019 By zhoucc
// All Rights Reserved
//======================================================
// Module : test_data
// Author : CC zhou
// Contact :
// Date : 3 .16 .2019
//=======================================================
// Description :
//========================================================
`include "../source/include/dw_params_presim.vh"
module test_data #(
    parameter NumClk = 40000
    )();
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================





//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================





//=====================================================================================================================
// Logic Design :
//=====================================================================================================================
// ****************** TEST INTERFACE ********************************************
integer SPRS_MEM_Ref0;
integer Suc_SPRS0;
integer GBFFLGACT_DatWr_File;
integer GBFACT_DatWr_File;
integer GBFFLGWEI_DatWr_File;
integer Suc_GBFFLGACT_DatWr;
integer Suc_GBFACT_DatWr;
integer Suc_GBFFLGWEI_DatWr;
reg [`PORT_DATAWIDTH                - 1 : 0 ] GBFFLGACT_DatWr;
reg [`PORT_DATAWIDTH                - 1 : 0 ] GBFACT_DatWr;
reg [`PORT_DATAWIDTH                - 1 : 0 ] GBFFLGWEI_DatWr;
reg [ `PORT_DATAWIDTH               - 1 : 0 ] SPRS_MEM_RefDat0;
initial begin:GBF_DatWr
    GBFFLGWEI_DatWr_File = $fopen("../testbench/Data/RAM_GBFFLGWEI_12B.dat","r");//Initial
    SPRS_MEM_Ref0 = $fopen("../testbench/Data/RAM_GBFWEI_12B.dat","r");
    GBFFLGACT_DatWr_File = $fopen("../testbench/Data/RAM_GBFACT_12B1.dat","r");
    GBFACT_DatWr_File = $fopen("../testbench/Data/RAM_GBFACT_12B.dat","r");
    repeat(NumClk) begin
        @(negedge mem_controller_tb.ASIC.TS3D.clk);// use mem_controller_tb.ASIC.clk
        if (mem_controller_tb.ASIC.TS3D.Reset_WEI)begin//paulse
            GBFFLGWEI_DatWr_File = $fopen("../testbench/Data/RAM_GBFFLGWEI_12B.dat","r");//Reset
            SPRS_MEM_Ref0 = $fopen("../testbench/Data/RAM_GBFWEI_12B.dat","r");
        end
        if(mem_controller_tb.ASIC.TS3D.Reset_ACT) begin
              GBFFLGACT_DatWr_File = $fopen("../testbench/Data/RAM_GBFACT_12B1.dat","r");//Reset
              GBFACT_DatWr_File = $fopen("../testbench/Data/RAM_GBFACT_12B.dat","r");
        end
        if ( mem_controller_tb.ASIC.TS3D.GBFFLGWEI_EnWr) begin
            Suc_GBFFLGWEI_DatWr=$fscanf(GBFFLGWEI_DatWr_File, "%h",GBFFLGWEI_DatWr);
            if(mem_controller_tb.ASIC.TS3D.GBFFLGWEI_DatWr !=GBFFLGWEI_DatWr )
                $display("ERROR time: %t GBFFLGACT_DatWr_Mon = %h,GBFFLGWEI_DatWr_Ref = %h, ", $time,mem_controller_tb.ASIC.TS3D.GBFFLGWEI_DatWr,GBFFLGWEI_DatWr);
        end
        if ( mem_controller_tb.ASIC.TS3D.GBFWEI_EnWr) begin
            Suc_SPRS0=$fscanf(SPRS_MEM_Ref0, "%h",SPRS_MEM_RefDat0);
            if(mem_controller_tb.ASIC.TS3D.GBFWEI_DatWr !=SPRS_MEM_RefDat0 )
                $display("ERROR time: %t GBFWEI_DatWr = %h, ", $time,SPRS_MEM_RefDat0);
        end
        if ( mem_controller_tb.ASIC.TS3D.GBFFLGACT_EnWr) begin
            Suc_GBFFLGACT_DatWr=$fscanf(GBFFLGACT_DatWr_File, "%h",GBFFLGACT_DatWr);
            if(mem_controller_tb.ASIC.TS3D.GBFFLGACT_DatWr !=GBFFLGACT_DatWr )
                $display("ERROR time: %t GBFFLGACT_DatWr_Mon = %h, GBFFLGACT_DatWr_Ref = %h", $time,mem_controller_tb.ASIC.TS3D.GBFFLGACT_DatWr,GBFFLGACT_DatWr);
        end
        if ( mem_controller_tb.ASIC.TS3D.GBFACT_EnWr) begin
            Suc_GBFACT_DatWr=$fscanf(GBFACT_DatWr_File, "%h",GBFACT_DatWr);
            if(mem_controller_tb.ASIC.TS3D.GBFACT_DatWr !=GBFACT_DatWr )
                $display("ERROR time: %t GBFACT_DatWr_Mon = %h, GBFACT_DatWr_Ref = %h", $time,mem_controller_tb.ASIC.TS3D.GBFACT_DatWr,GBFACT_DatWr);
        end
    end
end

// ******************************* TEST PEC *******************************
integer cnt;
generate
    genvar i,m0;
    for(i=0;i<`NUMPEB;i=i+1) begin:Mon_PEB
        for(m0=0;m0<3;m0=m0+1) begin:Mon_PEC

            integer PECMAC_FlgAct_Mon;
            integer PECMAC_FlgAct_Gen;
            integer PECMAC_Act_Mon;
            integer PECMAC_Act_Gen;
            integer PECMAC_FlgWei0_Mon;
            integer PECMAC_FlgWei0_Ref;
            integer PECMAC_Wei0_Mon;
            integer PECMAC_Wei0_Ref;
            integer Suc_FlgAct;
            integer Suc_Act;
            integer Suc_DatWr;
            integer Suc_FlgWei0;
            integer Suc_Wei0;
            reg [`BLOCK_DEPTH -  1 : 0]PECMAC_FlgAct_GenDat;
            reg [ `DATA_WIDTH * `BLOCK_DEPTH             -1 : 0]PECMAC_Act_GenDat;
            reg [ `BLOCK_DEPTH * `NUMPEC * `KERNEL_SIZE -1 : 0] PECMAC_FlgWei0_RefDat;
            reg [ `DATA_WIDTH * `BLOCK_DEPTH         - 1: 0] PECMAC_Wei0_RefDat;
            reg [5 : 0] addr,NumVal;

            reg [ 8 -1 :0 ] Number;
            //Number = i*m0;


            initial begin:PECMAC_FlgAct_MonPECMAC_Act_Mon
                PECMAC_FlgAct_Mon = $fopen("../testbench/Data/MonRTL/PECMAC_FlgAct_Mon.dat"+Number,"w");
                PECMAC_FlgAct_Gen = $fopen("../testbench/Data/GenTest/PECMAC_FlgAct_Gen.dat","r");
                PECMAC_Act_Mon = $fopen("../testbench/Data/MonRTL/PECMAC_Act_Mon.dat","w");
                PECMAC_Act_Gen = $fopen("../testbench/Data/GenTest/PECMAC_Act_Gen.dat","r");
                repeat(NumClk) begin
                    @(negedge mem_controller_tb.ASIC.clk);
                  if( mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.CfgMac) begin
                        @(negedge mem_controller_tb.ASIC.clk);
                        $fdisplay(PECMAC_FlgAct_Mon,"%b",mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_FlgAct);
                        $fdisplay(PECMAC_Act_Mon,"%h",mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_Act);
                        Suc_FlgAct = $fscanf(PECMAC_FlgAct_Gen,"%b",PECMAC_FlgAct_GenDat);
                        Suc_Act=$fscanf(PECMAC_Act_Gen,"%h",PECMAC_Act_GenDat);

                        if(mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_FlgAct != PECMAC_FlgAct_GenDat)
                            $display("ERROR time: %t  PEB[%d].PEC[%d].Ref_PECMAC_FlgAct = %h; Mon_PECMAC_FlgAct = %h", $time,i,m0, PECMAC_FlgAct_GenDat,mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_FlgAct);
                        if(mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_Act != PECMAC_Act_GenDat)
                            $display("ERROR time: %t  PEB[%d].PEC[%d].PECMAC_Act = %h",  $time,i,m0, PECMAC_Act_GenDat);
                    end
                end
            end

            initial begin:PECMAC_FlgWei0_MonPECMAC_Wei0_Ref
                PECMAC_FlgWei0_Mon = $fopen("../testbench/Data/MonRTL/PECMAC_FlgWei0_Mon.dat","w");
                PECMAC_FlgWei0_Ref = $fopen("../testbench/Data/GenTest/PECMAC_FlgWei0_Ref.dat","r");
                PECMAC_Wei0_Ref = $fopen("../testbench/Data/GenTest/PECMAC_Wei0_Ref.dat","r");
                repeat(NumClk) begin
                    @(negedge mem_controller_tb.ASIC.clk)
                    @(negedge mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.CfgWei) begin
                        @(negedge mem_controller_tb.ASIC.clk)//mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_FlgAct);
                        //@(negedge mem_controller_tb.ASIC.clk)//mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_FlgAct);
                        //$display("Test CfgWei");
                        //$fdisplay(PECMAC_FlgWei0_Mon,"%b",mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_FlgWei0);
                        //$fdisplay(PECMAC_Wei0_Mon,"%h",mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_Wei0);
                        Suc_FlgWei0 = $fscanf(PECMAC_FlgWei0_Ref,"%b",PECMAC_FlgWei0_RefDat);
                        Suc_Wei0=$fscanf(PECMAC_Wei0_Ref,"%h",PECMAC_Wei0_RefDat);

                        if(mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_FlgWei0[0+:`BLOCK_DEPTH] != PECMAC_FlgWei0_RefDat[ `BLOCK_DEPTH*(`NUMPEC-(3*i+m0) )*`KERNEL_SIZE -1 -: `BLOCK_DEPTH])
                            $display("ERROR time: %t  PEB[%d].PEC[%d].PECMAC_FlgWei0_Mon= %h PECMAC_FlgWei0_Ref = %h", $time,i,m0, mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_FlgWei0[0+:`BLOCK_DEPTH],PECMAC_FlgWei0_RefDat[ `BLOCK_DEPTH*(`NUMPEC-(3*i+m0) )*`KERNEL_SIZE -1 -: `BLOCK_DEPTH]);

                        NumVal <= 0;
                        for (addr=0;addr<32;addr=addr+1) begin
                            if(mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_FlgWei0[addr])
                                NumVal <= NumVal + 1;
                        end
                        for(addr=0;addr<NumVal;addr=addr+1)begin
                            if(mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_Wei0[`DATA_WIDTH*addr +: `DATA_WIDTH]!=PECMAC_Wei0_RefDat[`DATA_WIDTH*addr +: `DATA_WIDTH])
                                $display("ERROR time: %t  PEB[%d].PEC[%d].PECMAC_Wei0 = %h",  $time,i,m0, PECMAC_Wei0_RefDat);
                        end
                        //if(mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_Wei0 != PECMAC_Wei0_GenDat)
                            //$display("ERROR time: %t  PEB[%d].PEC[%d].PECMAC_Wei0 = %h",  $time,i,m0, PECMAC_Wei0_GenDat);


                    end
                end
            end


            integer PECRAM_DatWr_Mon;
            integer PECRAM_DatWr_Ref;
            //integer PECRAM_DatWr_Mon;
            integer RAMPEC_DatRd_Ref;
            integer Suc_DatRd;
            // .py zfill(81)

            reg [  `DATA_WIDTH*`CEIL(`PSUM_WIDTH, `DATA_WIDTH) *`NUMPEC               -1 : 0] PECRAM_DatWr_RefDat;
            reg [  `DATA_WIDTH*`CEIL(`PSUM_WIDTH, `DATA_WIDTH) *`NUMPEC               -1 : 0] RAMPEC_DatRd_RefDat;

            initial begin:PECRAM_DatWr_MonRAMPEC_DatRd_Ref
                PECRAM_DatWr_Mon = $fopen("../testbench/Data/MonRTL/PECRAM_DatWr_Mon.dat","w");
                PECRAM_DatWr_Ref = $fopen("../testbench/Data/GenTest/PECRAM_DatWr_Ref.dat","r");
                RAMPEC_DatRd_Ref = $fopen("../testbench/Data/GenTest/RAMPEC_DatRd_Ref.dat","r");
                repeat(NumClk) begin
                    @(negedge mem_controller_tb.ASIC.clk);
                    if(mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECRAM_EnWr) begin
                        // @(negedge mem_controller_tb.ASIC.clk);
                        $fdisplay(PECRAM_DatWr_Mon,"%h",mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECRAM_DatWr);
                        Suc_DatWr = $fscanf(PECRAM_DatWr_Ref,"%h",PECRAM_DatWr_RefDat);

                        if(~(mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECRAM_DatWr == PECRAM_DatWr_RefDat[`DATA_WIDTH*`CEIL(`PSUM_WIDTH, `DATA_WIDTH)  * (`NUMPEC -(3*i+m0) -1)   +:`PSUM_WIDTH ]))
                            $display("ERROR time: %t  PEB[%d].PEC[%d].PECRAM_DatWr_Ref = %h,PECRAM_DatWr_Mon = %h", $time, i,m0,PECRAM_DatWr_RefDat[`DATA_WIDTH*`CEIL(`PSUM_WIDTH, `DATA_WIDTH)  * (`NUMPEC -(3*i+m0) -1)   +:`PSUM_WIDTH ],mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECRAM_DatWr);
                    end

                    if(mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECRAM_EnRd && mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].PECRAM_AddrRd < 8'hc4) begin // 14 rows
                        @(negedge mem_controller_tb.ASIC.clk);
                        //$fdisplay(PECRAM_DatWr_Mon,"%h",mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECRAM_DatWr);
                        Suc_DatRd = $fscanf(RAMPEC_DatRd_Ref,"%h",RAMPEC_DatRd_RefDat);

                        if(~(mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.RAMPEC_DatRd == RAMPEC_DatRd_RefDat[`DATA_WIDTH*`CEIL(`PSUM_WIDTH, `DATA_WIDTH)  * (`NUMPEC -(3*i+m0) -1)   +:`PSUM_WIDTH ]))
                            $display("ERROR time: %t  PEB[%d].PEC[%d].RAMPEC_DatRd = %h", $time, i,m0,mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.RAMPEC_DatRd);
                    end
                end
            end

        end
    end
endgenerate



integer SPRS_MEM_Ref;
integer Suc_SPRS;
reg [ `DATA_WIDTH               - 1 : 0 ] SPRS_MEM_RefDat;
reg [ `C_LOG_2(`NUMPEB)      - 1 : 0 ]Addr;

initial begin: GBFOFM_DatWr_Ref
    SPRS_MEM_Ref = $fopen("../testbench/Data/GenTest/GBFOFM_DatWr_Ref.dat","r");
    repeat(NumClk) begin
        @(negedge mem_controller_tb.ASIC.clk);
        if ( mem_controller_tb.ASIC.TS3D.POOL.SIPO_OFM.enable) begin
            Suc_SPRS=$fscanf(SPRS_MEM_Ref, "%h",SPRS_MEM_RefDat);
            Addr <= mem_controller_tb.ASIC.TS3D.POOL.SPRS_Addr;
            if(mem_controller_tb.ASIC.TS3D.POOL.SIPO_OFM.data_in !=SPRS_MEM_RefDat )
                $display("ERROR time: %t  SPRS_MEM[%h] = %h, SPRS %h", $time,Addr,mem_controller_tb.ASIC.TS3D.POOL.SIPO_OFM.data_in, SPRS_MEM_RefDat);
        end
    end
end
//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================


endmodule
