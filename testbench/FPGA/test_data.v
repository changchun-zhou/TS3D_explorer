﻿//======================================================
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

// ********************* TEST INTERFACE ********************************************
integer SPRS_MEM_Ref0;
integer Suc_SPRS0;
integer GBFFLGACT_DatWr_File;
integer GBFACT_DatWr_File;
integer GBFFLGOFM_DatRd_File;
integer GBFOFM_DatRd_File;
integer GBFFLGWEI_DatWr_File;
integer Suc_GBFFLGACT_DatWr;
integer Suc_GBFACT_DatWr;
integer Suc_GBFFLGOFM_DatRd;
integer Suc_GBFOFM_DatRd;
integer Suc_GBFFLGWEI_DatWr;
reg [`PORT_DATAWIDTH                - 1 : 0 ] GBFFLGACT_DatWr;
reg [`PORT_DATAWIDTH                - 1 : 0 ] GBFACT_DatWr;
reg [`PORT_DATAWIDTH                - 1 : 0 ] GBFFLGOFM_DatRd;
reg [`PORT_DATAWIDTH                - 1 : 0 ] GBFOFM_DatRd;
reg [`PORT_DATAWIDTH                - 1 : 0 ] GBFFLGWEI_DatWr;
reg [ `PORT_DATAWIDTH               - 1 : 0 ] SPRS_MEM_RefDat0;
initial begin:GBF_DatWr
    GBFFLGWEI_DatWr_File = $fopen(`FILE_GBFFLGWEI,"r");//Initial
    GBFFLGWEI_DatWr_File = $fopen("../testbench/Data/dequant_data/Weight_45_conv4a.float_weight_flag.dat","r");//Initial
    SPRS_MEM_Ref0 = $fopen(`FILE_GBFWEI,"r");
    GBFFLGACT_DatWr_File = $fopen(`FILE_GBFFLGACT,"r");
    GBFACT_DatWr_File = $fopen(`FILE_GBFACT,"r");
    GBFFLGOFM_DatRd_File = $fopen("../testbench/Data/RAM_GBFFLGOFM_12B.dat","r");
    GBFOFM_DatRd_File = $fopen("../testbench/Data/RAM_GBFOFM_12B.dat","r");
    repeat(NumClk) begin
        @(negedge mem_controller_tb.ASIC.TS3D.clk);// use mem_controller_tb.ASIC.clk
        if (mem_controller_tb.ASIC.TS3D.Reset_WEI)begin//paulse
            GBFFLGWEI_DatWr_File = $fopen("../testbench/Data/dequant_data/Weight_45_conv4a.float_weight_flag.dat","r");//Reset
            SPRS_MEM_Ref0 = $fopen(`FILE_GBFWEI,"r");
        end
        if(mem_controller_tb.ASIC.TS3D.Reset_ACT) begin
              GBFFLGACT_DatWr_File = $fopen(`FILE_GBFFLGACT,"r");//Reset
              GBFACT_DatWr_File = $fopen(`FILE_GBFACT,"r");
        end
        if(mem_controller_tb.ASIC.TS3D.Reset_OFM) begin
            GBFFLGOFM_DatRd_File = $fopen("../testbench/Data/RAM_GBFFLGOFM_12B.dat","r");
            GBFOFM_DatRd_File = $fopen("../testbench/Data/RAM_GBFOFM_12B.dat","r");
        end
        if ( mem_controller_tb.ASIC.TS3D.GBFFLGWEI_EnWr) begin
            Suc_GBFFLGWEI_DatWr=$fscanf(GBFFLGWEI_DatWr_File, "%h",GBFFLGWEI_DatWr);
            if(mem_controller_tb.ASIC.TS3D.GBFFLGWEI_DatWr !=GBFFLGWEI_DatWr )
                $display("ERROR time: %t GBFFLGWEI_DatWr_Mon = %h,GBFFLGWEI_DatWr_Ref = %h, ", $time,mem_controller_tb.ASIC.TS3D.GBFFLGWEI_DatWr,GBFFLGWEI_DatWr);
        end
        if ( mem_controller_tb.ASIC.TS3D.GBFWEI_EnWr) begin
            Suc_SPRS0=$fscanf(SPRS_MEM_Ref0, "%h",SPRS_MEM_RefDat0);
            if(mem_controller_tb.ASIC.TS3D.GBFWEI_DatWr !=SPRS_MEM_RefDat0 )
                $display("ERROR time: %t GBFWEI_DatWr_Mon = %h,  GBFWEI_DatWr_Ref = %h, ", $time,mem_controller_tb.ASIC.TS3D.GBFWEI_DatWr, SPRS_MEM_RefDat0);
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
        if ( mem_controller_tb.ASIC.TS3D.GBFOFM_EnRd) begin
            Suc_GBFOFM_DatRd=$fscanf(GBFOFM_DatRd_File, "%h",GBFOFM_DatRd);
            if(mem_controller_tb.ASIC.TS3D.GBFOFM_DatRd!=GBFOFM_DatRd )
                $display("ERROR time: %t GBFOFM_DatRd_Mon = %h, GBFOFM_DatRd_Ref = %h", $time,mem_controller_tb.ASIC.TS3D.GBFOFM_DatRd,GBFOFM_DatRd);
        end
        if ( mem_controller_tb.ASIC.TS3D.GBFFLGOFM_EnRd) begin
            Suc_GBFFLGOFM_DatRd=$fscanf(GBFFLGOFM_DatRd_File, "%h",GBFFLGOFM_DatRd);
            if(mem_controller_tb.ASIC.TS3D.GBFFLGOFM_DatRd!=GBFFLGOFM_DatRd )
                $display("ERROR time: %t GBFFLGOFM_DatRd_Mon = %h, GBFFLGOFM_DatRd_Ref = %h", $time,mem_controller_tb.ASIC.TS3D.GBFFLGOFM_DatRd,GBFFLGOFM_DatRd);
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
            
            
            integer Suc_FlgAct;
            integer Suc_Act;
            integer Suc_DatWr;
            integer Suc_FlgWei0;
            //integer Suc_Wei0;
            reg [`BLOCK_DEPTH -  1 : 0]PECMAC_FlgAct_GenDat;
            reg [ `DATA_WIDTH * `BLOCK_DEPTH             -1 : 0]PECMAC_Act_GenDat;
            reg [0: `BLOCK_DEPTH * `NUMPEC * `KERNEL_SIZE -1 ] PECMAC_FlgWei_RefDat_r;
            
            reg [5 : 0] addr,NumVal;
            reg [10:0]id_wei;
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

            // ******************************  Test PECMAC0 for Every PEC *******************
            initial begin:PECMAC_FlgWei0_MonPECMAC_Wei_Ref
                PECMAC_FlgWei0_Mon = $fopen("../testbench/Data/MonRTL/PECMAC_FlgWei0_Mon.dat","w");
                PECMAC_FlgWei0_Ref = $fopen("../testbench/Data/GenTest/PECMAC_FlgWei_Ref.dat","r");
                
                repeat(NumClk) begin
                    @(negedge mem_controller_tb.ASIC.clk)
                    @(negedge mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.CfgWei) begin
                        @(negedge mem_controller_tb.ASIC.clk)//mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_FlgAct);
                        
                        //$fdisplay(PECMAC_FlgWei0_Mon,"%b",mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_FlgWei0);
                        Suc_FlgWei0 = $fscanf(PECMAC_FlgWei0_Ref,"%h",PECMAC_FlgWei_RefDat_r);
                        
                        //$display("%h",PECMAC_Wei_RefDat);

                        if(mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_FlgWei0[0+:`BLOCK_DEPTH] 
                                != PECMAC_FlgWei_RefDat_r[ `BLOCK_DEPTH*(3*i+m0)*`KERNEL_SIZE  +: `BLOCK_DEPTH])
                            $display("ERROR time: %t  PEB[%d].PEC[%d].PECMAC_FlgWei0_Mon= %h PECMAC_FlgWei0_Ref = %h", 
                                $time,i,m0, mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_FlgWei0[0+:`BLOCK_DEPTH],
                                PECMAC_FlgWei_RefDat_r[ `BLOCK_DEPTH*((3*i+m0) *`KERNEL_SIZE) +: `BLOCK_DEPTH]);
                    end
                end
            end

            // ************************  TEST PECRAM_DatWr/Rd *****************************
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
                            $display("ERROR time: %t  PEB[%d].PEC[%d].PECRAM_DatWr_Ref = %h,PECRAM_DatWr_Mon = %h", 
                                $time, i,m0,PECRAM_DatWr_RefDat[`DATA_WIDTH*`CEIL(`PSUM_WIDTH, `DATA_WIDTH)  * (`NUMPEC -(3*i+m0) -1)   +:`PSUM_WIDTH ],
                                mem_controller_tb.ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECRAM_DatWr);
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


// *********************** TEST POOL output **********************************************
integer SPRS_MEM_Ref;
integer FLAG_MEM_Ref;

integer Suc_SPRS;
integer Suc_FLAG;
reg [ `DATA_WIDTH               - 1 : 0 ] SPRS_MEM_RefDat;
reg [ `NUMPEB               - 1 : 0 ] FLAG_MEM_RefDat;
reg [ `C_LOG_2(`NUMPEB)      - 1 : 0 ]Addr;

initial begin: POOL_SPRS_MEM_Ref
    SPRS_MEM_Ref = $fopen("../testbench/Data/GenTest/POOL_SPRS_MEM_Ref.dat","r");
    FLAG_MEM_Ref = $fopen("../testbench/Data/GenTest/POOL_FLAG_MEM_Ref.dat","r");
    repeat(NumClk) begin
        @(negedge mem_controller_tb.ASIC.clk);
        if ( mem_controller_tb.ASIC.TS3D.POOL.SIPO_OFM.enable) begin
            Suc_SPRS=$fscanf(SPRS_MEM_Ref, "%h",SPRS_MEM_RefDat);
            Addr <= mem_controller_tb.ASIC.TS3D.POOL.SPRS_Addr;
            if(mem_controller_tb.ASIC.TS3D.POOL.SIPO_OFM.data_in !=SPRS_MEM_RefDat )
                $display("ERROR time: %t  SPRS_MEM[%h] = %h, SPRS %h", $time,Addr,mem_controller_tb.ASIC.TS3D.POOL.SIPO_OFM.data_in, SPRS_MEM_RefDat);
        end
        if ( mem_controller_tb.ASIC.TS3D.POOL.SIPO_FLGOFM.enable) begin
            Suc_FLAG=$fscanf(FLAG_MEM_Ref, "%b",FLAG_MEM_RefDat);
            if(mem_controller_tb.ASIC.TS3D.POOL.SIPO_FLGOFM.data_in !=FLAG_MEM_RefDat )
                $display("ERROR time: %t  FLAG_MEM_Mon = %h, FLAG_MEM_Ref = %h", $time,mem_controller_tb.ASIC.TS3D.POOL.SIPO_FLGOFM.data_in, FLAG_MEM_RefDat);
        end
    end
end

// **************************** TEST DISWEI's DISWEIPEC_Wei ****************************
integer PECMAC_Wei_Ref;
integer Suc_Wei0;
reg [ `DATA_WIDTH * `BLOCK_DEPTH * `KERNEL_SIZE        - 1: 0] PECMAC_Wei_RefDat;// a PEC
reg [10:0]id_pec;
initial begin: CHECK_Wei0ch31
    
    id_pec = 0;
    @(posedge mem_controller_tb.ASIC.rst_n)
    repeat(NumClk) begin 
        @(negedge mem_controller_tb.ASIC.clk)
        if ( mem_controller_tb.ASIC.TS3D.Reset_WEI) // Reset WEI every new frame
            id_pec = 0;
        if(mem_controller_tb.ASIC.TS3D.DISWEI.fifo_pop) begin
            @(negedge mem_controller_tb.ASIC.clk)//delay a clk, then get DISWEIPEC_Wei
            Suc_Wei0=$fscanf(PECMAC_Wei_Ref,"%h",PECMAC_Wei_RefDat);
            //$display("whole Ref: %h",PECMAC_Wei_RefDat);
            //$display("TEST: %t,FSCAF:%d,id_pec:%d,Mon_wei0:%h Ref:%h,",$time,Suc_Wei0,id_pec,mem_controller_tb.ASIC.TS3D.DISWEI.DISWEIPEC_Wei[`DATA_WIDTH*`BLOCK_DEPTH*8 +: `DATA_WIDTH]
            //    ,PECMAC_Wei_RefDat[`DATA_WIDTH*`BLOCK_DEPTH*8 +: `DATA_WIDTH]);
            if( mem_controller_tb.ASIC.TS3D.DISWEI.DISWEIPEC_Wei[`DATA_WIDTH*`BLOCK_DEPTH*8 +: `DATA_WIDTH]
            != PECMAC_Wei_RefDat[`DATA_WIDTH*`BLOCK_DEPTH*8 +: `DATA_WIDTH]
            && mem_controller_tb.ASIC.TS3D.DISWEI.DISWEIPEC_FlgWei[1*`BLOCK_DEPTH*8 +: `BLOCK_DEPTH] !=0
            && id_pec != `NUMPEC*(mem_controller_tb.ASIC.TS3D.CONFIG.CFG_NumBlk+1)) begin// Wei0 's ch31   超过的一组wei是会从fifo取出，但不会被PEC所get到；即id_pec != all NumPECxNumBlk
                $display("ERROR: %t,id_pec:%d,Mon_wei0:%h Ref:%h,",$time,id_pec,mem_controller_tb.ASIC.TS3D.DISWEI.DISWEIPEC_Wei[`DATA_WIDTH*`BLOCK_DEPTH*8 +: `DATA_WIDTH]
                ,PECMAC_Wei_RefDat[`DATA_WIDTH*`BLOCK_DEPTH*8 +: `DATA_WIDTH]);
            
            end
            id_pec = id_pec + 1;
        end
    end
end
initial begin: Set_PECMAC_Wei_Ref
    PECMAC_Wei_Ref = $fopen("../testbench/Data/GenTest/PECMAC_Wei_Ref.dat","r");
    repeat(NumClk) begin
        @(negedge mem_controller_tb.ASIC.clk)
        if ( mem_controller_tb.ASIC.TS3D.Reset_WEI) //  Reset WEI every new frame
            PECMAC_Wei_Ref = $fopen("../testbench/Data/GenTest/PECMAC_Wei_Ref.dat","r");
    end 
end


//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================


endmodule