//======================================================
// Copyright (C) 2019 By zhoucc
// All Rights Reserved
//======================================================
// Module : Init_DDR
// Author : CC zhou
// Contact :
// Date :  3 . 16.2019
//=======================================================
// Description :
//========================================================
`include "../source/include/dw_params_presim.vh"
module  Init_DDR #(
    parameter TX_SIZE_WIDTH = 20,
    parameter DATA_WIDTH = 8
    )( );
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================





//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================





//=====================================================================================================================
// Logic Design :
//=====================================================================================================================

  integer i;
        // DDR initial
  reg [ TX_SIZE_WIDTH - 1 : 0 ]     ddr_idx;
  reg [`PORT_DATAWIDTH -1 : 0] tmp;
  reg [`PORT_DATAWIDTH -1 : 0]DATA_RF_mem_1[0 : 4095];
  reg [`PORT_DATAWIDTH -1 : 0]DATA_RF_mem_2[0 : 4095];
  reg [`PORT_DATAWIDTH -1 : 0]Flag_RF_mem_1[0 : 4095];
  reg [`PORT_DATAWIDTH -1 : 0]Flag_RF_mem_2[0 : 4095];
  reg [`PORT_DATAWIDTH -1 : 0]DATA_RF_mem_WEI_1[0 : 4095];
  reg [`PORT_DATAWIDTH -1 : 0]DATA_RF_mem_WEI_2[0 : 4095];
  reg [`PORT_DATAWIDTH -1 : 0]Flag_RF_mem_WEI_1[0 : 4095];
  reg [`PORT_DATAWIDTH -1 : 0]Flag_RF_mem_WEI_2[0 : 4095];

  reg [14 : 0]addr_r_BUS_1;
    initial begin
         // write_ddr = 0;
          $readmemh(`FILE_GBFACT, DATA_RF_mem_1);
          ddr_idx = (`CFG_ADDR -32'h0800_0000) ;

          for( addr_r_BUS_1 = 0; addr_r_BUS_1 < 1<<12; addr_r_BUS_1 = addr_r_BUS_1 + 1 ) begin
            if( addr_r_BUS_1 == 0)
              // {CFG_LenRow,CFG_DepBlk,CFG_NumBlk,CFG_NumFrm,   CFG_NumPat,CFG_NumLay,CFG_POOL    }
              //                                                                       {fl, POOL_ValIFM, Stride}
               tmp = {4'd15,     5'd31,     5'd1,     5'd15,         8'd15,      8'd7,      9'd10};//Conv2
              // tmp = {4'd15,5'd31,5'd1,5'd3, 8'd0, 8'd7,      5'd1, 1'd0, 3'd2};
            else
              // tmp = DATA_RF_mem_1[addr_r_BUS_1];
              tmp = 0;
            for( i=0; i<(`PORT_DATAWIDTH/DATA_WIDTH); i = i+1) begin
              mem_controller_tb.S_HP_RD0[0].u_axim_driver.ddr_ram[ddr_idx] = tmp[DATA_WIDTH*i +: DATA_WIDTH];
              //if( addr_r_BUS_1 < 10)
                 //$display (" CONFIG DDR_RAM[%h] = %h", ddr_idx, mem_controller_tb.S_HP_RD0[0].u_axim_driver.ddr_ram[ddr_idx]);
              ddr_idx = ddr_idx + 1;
            end
          end

          ddr_idx = (`ACT_ADDR-32'h0800_0000) ;
          // 11 + C_LOG_2(12) = 15 (8b) => + _6000; 
          for( addr_r_BUS_1 = 0; addr_r_BUS_1 < 1<<12; addr_r_BUS_1 = addr_r_BUS_1 + 1 ) begin//
            tmp = DATA_RF_mem_1[addr_r_BUS_1];
            for( i=0; i<(`PORT_DATAWIDTH/DATA_WIDTH); i = i+1) begin
              mem_controller_tb.S_HP_RD0[0].u_axim_driver.ddr_ram[ddr_idx] = tmp[DATA_WIDTH*i +: DATA_WIDTH];
              //if( addr_r_BUS_1 < 10)
                //$display (" S_HP_RD0 DATA_RF_mem_1 DDR_RAM[%h] = %b", ddr_idx, mem_controller_tb.S_HP_RD0[0].u_axim_driver.ddr_ram[ddr_idx]);
              ddr_idx = ddr_idx + 1;
            end
          end

          ddr_idx = (`FLGACT_ADDR-32'h0800_0000);
          $readmemh(`FILE_GBFFLGACT, Flag_RF_mem_1);
          for( addr_r_BUS_1 = 0; addr_r_BUS_1 < 1<<12; addr_r_BUS_1 = addr_r_BUS_1 + 1 ) begin
            tmp = Flag_RF_mem_1[addr_r_BUS_1];
            for( i=0; i<(`PORT_DATAWIDTH/DATA_WIDTH); i = i+1) begin
              mem_controller_tb.S_HP_RD0[0].u_axim_driver.ddr_ram[ddr_idx] = tmp[DATA_WIDTH*i +: DATA_WIDTH];
               //if( addr_r_BUS_1 < 50)
                 //$display (" Flag_RF_mem_1 S_HP_RD0DDR_RAM[%h] = %b", ddr_idx, mem_controller_tb.S_HP_RD0[0].u_axim_driver.ddr_ram[ddr_idx]);
              ddr_idx = ddr_idx + 1;
            end
          end
          ddr_idx = (`WEI_ADDR-32'h0800_0000) ;
          $readmemh(`FILE_GBFWEI, DATA_RF_mem_WEI_1);
          for( addr_r_BUS_1 = 0; addr_r_BUS_1 < 1<<12; addr_r_BUS_1 = addr_r_BUS_1 + 1 ) begin
            tmp = DATA_RF_mem_WEI_1[addr_r_BUS_1];
            for( i=0; i<(`PORT_DATAWIDTH/DATA_WIDTH); i = i+1) begin
              mem_controller_tb.S_HP_RD0[0].u_axim_driver.ddr_ram[ddr_idx] = tmp[DATA_WIDTH*i +: DATA_WIDTH];
               //if( addr_r_BUS_1 < 120 && addr_r_BUS_1> 116)
                 //$display ("RAM_GBFWEI_12B DDR_RAM[%h] = %h", ddr_idx, mem_controller_tb.S_HP_RD0[0].u_axim_driver.ddr_ram[ddr_idx]);
              ddr_idx = ddr_idx + 1;
            end
          end
          ddr_idx = (`FLGWEI_ADDR-32'h0800_0000) ;
          $readmemh(`FILE_GBFFLGWEI, Flag_RF_mem_WEI_1);
          for( addr_r_BUS_1 = 0; addr_r_BUS_1 < 1<<12; addr_r_BUS_1 = addr_r_BUS_1 + 1 ) begin
            tmp = Flag_RF_mem_WEI_1[addr_r_BUS_1];
            for( i=0; i<(`PORT_DATAWIDTH/DATA_WIDTH); i = i+1) begin
              mem_controller_tb.S_HP_RD0[0].u_axim_driver.ddr_ram[ddr_idx] = tmp[DATA_WIDTH*i +: DATA_WIDTH];
               //if( addr_r_BUS_1 < 10)
                //$display ("S_HP_RD0 DDR_RAM[%h] = %b", ddr_idx, mem_controller_tb.S_HP_RD0[0].u_axim_driver.ddr_ram[ddr_idx]);
              ddr_idx = ddr_idx + 1;
            end
          end
         // ddr_idx = (WEI_FLAG_2_ADDR-32'h0800_0000) ;
         //write_ddr = 1;

            ddr_idx = (`CFG_ADDR-32'h0800_0000) ;

    end






//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================


endmodule
