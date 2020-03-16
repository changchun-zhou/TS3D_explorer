`timescale 1ns / 100ps
`include "../source/include/dw_params_presim.vh"
module mem_controller_tb;
  parameter integer NUM_AXI            = 1 ;
  parameter integer NUM_RD             = 2;
  localparam integer TID_WIDTH         = 6;
  localparam integer ADDR_W            = 32;
  localparam integer AXI_DATA_W        = 64;
  parameter integer WSTRB_W            = AXI_DATA_W/8 ;
  localparam integer TX_SIZE_WIDTH     = 20;
  parameter integer SPI_WIDTH          = 96;
  parameter integer DATA_WIDTH         = 8 ;
  // parameter integer DDR_BATCH = 11;

    parameter         ACT_DATA_1_ADDR                     = 32'h0800_0000 ;//15bit
    parameter         ACT_DATA_2_ADDR                     = 32'h0800_8000 ;
    parameter         ACT_FLAG_1_ADDR                    = 32'h0801_0000 ; //4MB act
    parameter         ACT_FLAG_2_ADDR                    = 32'h0801_8000 ; //4MB act

    parameter         WEI_DATA_1_ADDR                     = 32'h0802_0000 ;
    parameter         WEI_DATA_2_ADDR                     = 32'h0802_8000 ;
    parameter         WEI_FLAG_1_ADDR                    = 32'h0803_0000 ; //4MB act
    parameter         WEI_FLAG_2_ADDR                    = 32'h0803_8000 ; //4MB act
    parameter         CONFIG_ADDR                       = 32'h0804_0000 ;

    parameter         OF_BASE_ADDR                      = 32'h0804_8000 ; //
    parameter         OF_FLAG_BASE_ADDR                 = 32'h0805_0000 ; //4MB outfm

parameter NumClk = 40000;

wire                                        clk;
wire                                        reset;
/*initial begin
  $shm_open("wave_gds_post_sim");
  $shm_probe(inst_TOP_ASIC, "AC");
  #5000;
  $shm_close;
end
  */
// FPGA clk reset
clk_rst_driver clkgen(
    .clk                      ( clk                      ),
    .reset_n                  (                          ),
    .reset                    ( reset                    )
  );
// ====================================================================================================================


// ====================================================================================================================
// ASIC clk reset
// ====================================================================================================================
reg clk_chip;
reg reset_n_chip;
reg reset_dll;
reg write_ddr;
initial begin
	clk_chip = 0;
//	wait(!reset_n_chip);
//	wait(reset_n_chip);
//	#10;
	forever begin
		#5 clk_chip = !clk_chip;
	end
end
//always

initial begin
    reset_n_chip = 0;
    reset_dll = 1;
    wait( reset)
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    //
    reset_dll = 0;
    @(negedge clk);
    repeat(50) @(negedge clk);
	@(posedge clk);
    reset_dll = 1;
    // wait( reset)
    wait( !reset)
    repeat( 40 )@( negedge clk);
    reset_n_chip = 0;
    @(negedge clk);
    repeat(20)@(negedge clk);
    reset_n_chip = 1;
end
// ====================================================================================================================

reg  [ 4    -1 : 0 ]   config_data   ;
wire [ NUM_AXI              -1 : 0 ]   wr_req        ;
reg  [ NUM_AXI*SPI_WIDTH    -1 : 0 ]   wr_data       ;
reg [ NUM_AXI              -1 : 0 ]   rd_req        ; //
wire [ NUM_AXI*SPI_WIDTH    -1 : 0 ]   rd_data       ;
wire [ NUM_AXI              -1 : 0 ]   valid         ;
wire [ NUM_AXI              -1 : 0 ]   empty         ;


  localparam IDLE = 0, CONFIG = 1, WAIT = 2, RD_DATA = 3,  WR_DATA = 4;
  parameter g = 0;
// generate
//   genvar g;
//   for( g=0; g<NUM_AXI; g=g+1 )
//   begin : TB_ASIC

    reg [ SPI_WIDTH  - 1 : 0 ]  rd_count    ;
    reg                         rw_req      ;
    wire[ 3          - 1 : 0 ]  state       ;
    reg [ 3          - 1 : 0 ]  next_state  ;

    wire                        rd_last     ;
    wire                        wr_last     ;
    wire                        wr_ready    ;
    wire                        rd_ready    ;
    wire                        config_ready;

    // assign wr_req[g*1+:1] = wr_ready && config_data[31] && (state > 0) && ( wr_data < 63 );//
//
    // assign rd_req = rd_ready && config_data[31] == 0;

    // ====================================================================================================================
    // ASIC Initial
    // ====================================================================================================================
    initial begin
      rw_req = 0;
      rd_req = 0;
      config_data = 4'b1000;
      wait( ! reset_n_chip )
      wait( reset_n_chip )
    // ====================================================================================================================
    // ASIC READ
      wait( config_ready )
      @ ( negedge clk_chip);
      rw_req = 1;
      config_data = 4'b1000;
      @ ( negedge clk_chip );
      rw_req = 0;

    // ====================================================================================================================
    // READ
      wait( config_ready )
      @ ( negedge clk_chip);
      rw_req = 1;
      config_data = 4'b1000;
      @ ( negedge clk_chip );
      rw_req = 0;
    end


// ====================================================================================================================

// ====================================================================================================================
  //initial $sdf_annotate("/workspace/home/caoxg/Global_PE/for_post_sim/Global_PE.sdf",inst_TOP_ASIC,, "sdf.log", "MAXIMUM","1.0:1.0:1.0","FROM_MAXIMUM");
// ====================================================================================================================
// ASIC mem_chip instantiation
// ====================================================================================================================
wire pad_in;
wire data_request;

wire rd_valid;

wire [ 63 : 0 ] data_out;
wire            ready;

// ====================================================================================================================
// S_HP_RD0 instantiation
// ====================================================================================================================
localparam j = 0;
generate
  genvar k;
  for( k=0; k<1; k=k+1 )
  begin: S_HP_RD0
    // Master Interface Write Address
  wire  [ NUM_AXI*TID_WIDTH    -1 : 0 ]        M_AXI_AWID;
  wire  [ NUM_AXI*ADDR_W       -1 : 0 ]        M_AXI_AWADDR;
  wire  [ NUM_AXI*4            -1 : 0 ]        M_AXI_AWLEN;
  wire  [ NUM_AXI*3            -1 : 0 ]        M_AXI_AWSIZE;
  wire  [ NUM_AXI*2            -1 : 0 ]        M_AXI_AWBURST;
  wire  [ NUM_AXI*2            -1 : 0 ]        M_AXI_AWLOCK;
  wire  [ NUM_AXI*4            -1 : 0 ]        M_AXI_AWCACHE;
  wire  [ NUM_AXI*3            -1 : 0 ]        M_AXI_AWPROT;
  wire  [ NUM_AXI*4            -1 : 0 ]        M_AXI_AWQOS;
  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_AWVALID;
  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_AWREADY;

    // Master Interface Write Data
  wire  [ NUM_AXI*TID_WIDTH    -1 : 0 ]        M_AXI_WID;
  wire  [ NUM_AXI*AXI_DATA_W   -1 : 0 ]        M_AXI_WDATA;
  wire  [ NUM_AXI*WSTRB_W      -1 : 0 ]        M_AXI_WSTRB;
  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_WLAST;
  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_WVALID;
  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_WREADY;

    // Master Interface Write Response
  wire  [ NUM_AXI*TID_WIDTH    -1 : 0 ]        M_AXI_BID;
  wire  [ NUM_AXI*2            -1 : 0 ]        M_AXI_BRESP;
  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_BVALID;
  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_BREADY;

    // Master Interface Read Address
  wire  [ NUM_AXI*TID_WIDTH    -1 : 0 ]        M_AXI_ARID;
  wire  [ NUM_AXI*ADDR_W       -1 : 0 ]        M_AXI_ARADDR;
  wire  [ NUM_AXI*4            -1 : 0 ]        M_AXI_ARLEN;
  wire  [ NUM_AXI*3            -1 : 0 ]        M_AXI_ARSIZE;
  wire  [ NUM_AXI*2            -1 : 0 ]        M_AXI_ARBURST;
  wire  [ NUM_AXI*2            -1 : 0 ]        M_AXI_ARLOCK;
  wire  [ NUM_AXI*4            -1 : 0 ]        M_AXI_ARCACHE;
  wire  [ NUM_AXI*3            -1 : 0 ]        M_AXI_ARPROT;
  wire  [ NUM_AXI*4            -1 : 0 ]        M_AXI_ARQOS;
  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_ARVALID;
  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_ARREADY;

    // Master Interface Read Data
  wire  [ NUM_AXI*TID_WIDTH    -1 : 0 ]        M_AXI_RID;
  wire  [ NUM_AXI*AXI_DATA_W   -1 : 0 ]        M_AXI_RDATA;
  wire  [ NUM_AXI*2            -1 : 0 ]        M_AXI_RRESP;
  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_RLAST;
  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_RVALID;
  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_RREADY;


  wire [ NUM_AXI              -1 : 0 ]        O_spi_sck;
  wire [ NUM_AXI*SPI_WIDTH    -1 : 0 ]        IO_spi_data;
  wire [ NUM_AXI              -1 : 0 ]        O_spi_cs_n;
  wire [ NUM_AXI              -1 : 0 ]        near_full;
  wire [ NUM_AXI              -1 : 0 ]        config_req;
  wire [ NUM_AXI              -1 : 0 ]   full          ;
  wire OE_req;
  wire [ 4 - 1 : 0 ] which_write;
  mem_controller_top_rd #(
  .NUM_AXI( NUM_AXI )
  )mem_controller_top0 ( // PORTS
    .clk                      ( clk                      ),
    .reset                    ( reset                    ),

    .O_spi_sck                ( O_spi_sck                 ),
    .IO_spi_data              ( IO_spi_data               ),
    .O_spi_cs_n               ( O_spi_cs_n                ),
    // .near_full                ( 1'b0                 ),
    .config_req_              ( config_req                ),
    .pad_in ( OE_req ),
    .full   ( full ),
    .which_write ( which_write ),
    .M_AXI_AWID               ( M_AXI_AWID               ),
    .M_AXI_AWADDR             ( M_AXI_AWADDR             ),
    .M_AXI_AWLEN              ( M_AXI_AWLEN              ),
    .M_AXI_AWSIZE             ( M_AXI_AWSIZE             ),
    .M_AXI_AWBURST            ( M_AXI_AWBURST            ),
    .M_AXI_AWLOCK             ( M_AXI_AWLOCK             ),
    .M_AXI_AWCACHE            ( M_AXI_AWCACHE            ),
    .M_AXI_AWPROT             ( M_AXI_AWPROT             ),
    .M_AXI_AWQOS              ( M_AXI_AWQOS              ),
    .M_AXI_AWVALID            ( M_AXI_AWVALID            ),
    .M_AXI_AWREADY            ( M_AXI_AWREADY            ),
    .M_AXI_WID                ( M_AXI_WID                ),
    .M_AXI_WDATA              ( M_AXI_WDATA              ),
    .M_AXI_WSTRB              ( M_AXI_WSTRB              ),
    .M_AXI_WLAST              ( M_AXI_WLAST              ),
    .M_AXI_WVALID             ( M_AXI_WVALID             ),
    .M_AXI_WREADY             ( M_AXI_WREADY             ),
    .M_AXI_BID                ( M_AXI_BID                ),
    .M_AXI_BRESP              ( M_AXI_BRESP              ),
    .M_AXI_BVALID             ( M_AXI_BVALID             ),
    .M_AXI_BREADY             ( M_AXI_BREADY             ),
    .M_AXI_ARID               ( M_AXI_ARID               ),
    .M_AXI_ARADDR             ( M_AXI_ARADDR             ),
    .M_AXI_ARLEN              ( M_AXI_ARLEN              ),
    .M_AXI_ARSIZE             ( M_AXI_ARSIZE             ),
    .M_AXI_ARBURST            ( M_AXI_ARBURST            ),
    .M_AXI_ARLOCK             ( M_AXI_ARLOCK             ),
    .M_AXI_ARCACHE            ( M_AXI_ARCACHE            ),
    .M_AXI_ARPROT             ( M_AXI_ARPROT             ),
    .M_AXI_ARQOS              ( M_AXI_ARQOS              ),
    .M_AXI_ARVALID            ( M_AXI_ARVALID            ),
    .M_AXI_ARREADY            ( M_AXI_ARREADY            ),
    .M_AXI_RID                ( M_AXI_RID                ),
    .M_AXI_RDATA              ( M_AXI_RDATA              ),
    .M_AXI_RRESP              ( M_AXI_RRESP              ),
    .M_AXI_RLAST              ( M_AXI_RLAST              ),
    .M_AXI_RVALID             ( M_AXI_RVALID             ),
    .M_AXI_RREADY             ( M_AXI_RREADY             )
  );
// ==================================================================


// ==================================================================
// AXI to DDR
// ==================================================================

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
          write_ddr = 0;
          $readmemh("../testbench/Data/RAM_GBFACT_12B.dat", DATA_RF_mem_1);
          ddr_idx = (CONFIG_ADDR -32'h0800_0000) ;

          for( addr_r_BUS_1 = 0; addr_r_BUS_1 < 1<<9; addr_r_BUS_1 = addr_r_BUS_1 + 1 ) begin
            if( addr_r_BUS_1 == 0)
              tmp = {4'd15,5'd31,5'd1,5'd3, 8'd0, 8'd7, 5'd0, 1'd1, 3'd2};
            else
              // tmp = DATA_RF_mem_1[addr_r_BUS_1];
              tmp = 0;
            for( i=0; i<(`PORT_DATAWIDTH/DATA_WIDTH); i = i+1) begin
              u_axim_driver.ddr_ram[ddr_idx] = tmp[DATA_WIDTH*i +: DATA_WIDTH];
              if( addr_r_BUS_1 < 10)
                 $display (" CONFIG DDR_RAM[%h] = %h", ddr_idx, u_axim_driver.ddr_ram[ddr_idx]);
              ddr_idx = ddr_idx + 1;
            end
          end

          ddr_idx = (ACT_DATA_1_ADDR-32'h0800_0000) ;

          for( addr_r_BUS_1 = 0; addr_r_BUS_1 < 1<<11; addr_r_BUS_1 = addr_r_BUS_1 + 1 ) begin//
            tmp = DATA_RF_mem_1[addr_r_BUS_1];
            for( i=0; i<(`PORT_DATAWIDTH/DATA_WIDTH); i = i+1) begin
              u_axim_driver.ddr_ram[ddr_idx] = tmp[DATA_WIDTH*i +: DATA_WIDTH];
              if( addr_r_BUS_1 < 10)
                $display (" S_HP_RD0 DATA_RF_mem_1 DDR_RAM[%h] = %b", ddr_idx, u_axim_driver.ddr_ram[ddr_idx]);
              ddr_idx = ddr_idx + 1;
            end
          end

          ddr_idx = (ACT_FLAG_1_ADDR-32'h0800_0000);
          $readmemh("../testbench/Data/RAM_GBFACT_12B1.dat", Flag_RF_mem_1);
          for( addr_r_BUS_1 = 0; addr_r_BUS_1 < 1<<10; addr_r_BUS_1 = addr_r_BUS_1 + 1 ) begin
            tmp = Flag_RF_mem_1[addr_r_BUS_1];
            for( i=0; i<(`PORT_DATAWIDTH/DATA_WIDTH); i = i+1) begin
              u_axim_driver.ddr_ram[ddr_idx] = tmp[DATA_WIDTH*i +: DATA_WIDTH];
              // if( addr_r_BUS_1 < 50)
              //   $display (" Flag_RF_mem_1 S_HP_RD0DDR_RAM[%h] = %b", ddr_idx, u_axim_driver.ddr_ram[ddr_idx]);
              ddr_idx = ddr_idx + 1;
            end
          end
          ddr_idx = (WEI_DATA_1_ADDR-32'h0800_0000) ;
          $readmemh("../testbench/Data/RAM_GBFWEI_12B.dat", DATA_RF_mem_WEI_1);
          for( addr_r_BUS_1 = 0; addr_r_BUS_1 < 1<<12; addr_r_BUS_1 = addr_r_BUS_1 + 1 ) begin
            tmp = DATA_RF_mem_WEI_1[addr_r_BUS_1];
            for( i=0; i<(`PORT_DATAWIDTH/DATA_WIDTH); i = i+1) begin
              u_axim_driver.ddr_ram[ddr_idx] = tmp[DATA_WIDTH*i +: DATA_WIDTH];
               if( addr_r_BUS_1 < 120 && addr_r_BUS_1> 116)
                 $display ("RAM_GBFWEI_12B DDR_RAM[%h] = %h", ddr_idx, u_axim_driver.ddr_ram[ddr_idx]);
              ddr_idx = ddr_idx + 1;
            end
          end
          ddr_idx = (WEI_FLAG_1_ADDR-32'h0800_0000) ;
          $readmemh("../testbench/Data/RAM_GBFFLGWEI_12B.dat", Flag_RF_mem_WEI_1);
          for( addr_r_BUS_1 = 0; addr_r_BUS_1 < 1<<12; addr_r_BUS_1 = addr_r_BUS_1 + 1 ) begin
            tmp = Flag_RF_mem_WEI_1[addr_r_BUS_1];
            for( i=0; i<(`PORT_DATAWIDTH/DATA_WIDTH); i = i+1) begin
              u_axim_driver.ddr_ram[ddr_idx] = tmp[DATA_WIDTH*i +: DATA_WIDTH];
              // if( addr_r_BUS_1 < 10)
              //   $display ("S_HP_RD0 DDR_RAM[%h] = %b", ddr_idx, u_axim_driver.ddr_ram[ddr_idx]);
              ddr_idx = ddr_idx + 1;
            end
          end
          ddr_idx = (WEI_FLAG_2_ADDR-32'h0800_0000) ;
         write_ddr = 1;

            ddr_idx = (CONFIG_ADDR-32'h0800_0000) ;
          // for( i=0; i<10; i=i+1)
          //     $display (" TEST S_HP_RD0 DDR_RAM[%h] = %b", (ddr_idx+i), u_axim_driver.ddr_ram[ddr_idx+i]);

    end


    axi_master_tb_driver #(
        .AXI_DATA_WIDTH           ( AXI_DATA_W               ),
        .DATA_WIDTH               ( 8                        ),
        .NUM_PE                   ( 8                        ),
        .TX_SIZE_WIDTH            ( TX_SIZE_WIDTH            )
    ) u_axim_driver (
        .clk                      ( clk                                                     ),
        .reset                    ( reset                                                   ),
        .M_AXI_AWID               ( M_AXI_AWID               [ j*TID_WIDTH   +: TID_WIDTH  ]),
        .M_AXI_AWADDR             ( M_AXI_AWADDR             [ j*ADDR_W      +: ADDR_W     ]),
        .M_AXI_AWLEN              ( M_AXI_AWLEN              [ j*4           +: 4          ]),
        .M_AXI_AWSIZE             ( M_AXI_AWSIZE             [ j*3           +: 3          ]),
        .M_AXI_AWBURST            ( M_AXI_AWBURST            [ j*2           +: 2          ]),
        .M_AXI_AWLOCK             ( M_AXI_AWLOCK             [ j*2           +: 2          ]),
        .M_AXI_AWCACHE            ( M_AXI_AWCACHE            [ j*4           +: 4          ]),
        .M_AXI_AWPROT             ( M_AXI_AWPROT             [ j*3           +: 3          ]),
        .M_AXI_AWQOS              ( M_AXI_AWQOS              [ j*4           +: 4          ]),
        .M_AXI_AWVALID            ( M_AXI_AWVALID            [ j*1           +: 1          ]),
        .M_AXI_AWREADY            ( M_AXI_AWREADY            [ j*1           +: 1          ]),
        .M_AXI_WID                ( M_AXI_WID                [ j*TID_WIDTH   +: TID_WIDTH  ]),
        .M_AXI_WDATA              ( M_AXI_WDATA              [ j*AXI_DATA_W  +: AXI_DATA_W ]),
        .M_AXI_WSTRB              ( M_AXI_WSTRB              [ j*WSTRB_W     +: WSTRB_W    ]),
        .M_AXI_WLAST              ( M_AXI_WLAST              [ j*1           +: 1          ]),
        .M_AXI_WVALID             ( M_AXI_WVALID             [ j*1           +: 1          ]),
        .M_AXI_WREADY             ( M_AXI_WREADY             [ j*1           +: 1          ]),
        .M_AXI_BID                ( M_AXI_BID                [ j*TID_WIDTH   +: TID_WIDTH  ]),
        .M_AXI_BRESP              ( M_AXI_BRESP              [ j*2           +: 2          ]),
        .M_AXI_BVALID             ( M_AXI_BVALID             [ j*1           +: 1          ]),
        .M_AXI_BREADY             ( M_AXI_BREADY             [ j*1           +: 1          ]),
        .M_AXI_ARID               ( M_AXI_ARID               [ j*TID_WIDTH   +: TID_WIDTH  ]),
        .M_AXI_ARADDR             ( M_AXI_ARADDR         [ j*ADDR_W      +: ADDR_W     ]),
        .M_AXI_ARLEN              ( M_AXI_ARLEN              [ j*4           +: 4          ]),
        .M_AXI_ARSIZE             ( M_AXI_ARSIZE             [ j*3           +: 3          ]),
        .M_AXI_ARBURST            ( M_AXI_ARBURST            [ j*2           +: 2          ]),
        .M_AXI_ARLOCK             ( M_AXI_ARLOCK             [ j*2           +: 2          ]),
        .M_AXI_ARCACHE            ( M_AXI_ARCACHE            [ j*4           +: 4          ]),
        .M_AXI_ARPROT             ( M_AXI_ARPROT             [ j*3           +: 3          ]),
        .M_AXI_ARQOS              ( M_AXI_ARQOS              [ j*4           +: 4          ]),
        .M_AXI_ARVALID            ( M_AXI_ARVALID            [ j*1           +: 1          ]),
        .M_AXI_ARREADY            ( M_AXI_ARREADY            [ j*1           +: 1          ]),
        .M_AXI_RID                ( M_AXI_RID                [ j*TID_WIDTH   +: TID_WIDTH  ]),
        .M_AXI_RDATA              ( M_AXI_RDATA              [ j*AXI_DATA_W  +: AXI_DATA_W ]),
        .M_AXI_RRESP              ( M_AXI_RRESP              [ j*2           +: 2          ]),
        .M_AXI_RLAST              ( M_AXI_RLAST              [ j*1           +: 1          ]),
        .M_AXI_RVALID             ( M_AXI_RVALID             [ j*1           +: 1          ]),
        .M_AXI_RREADY             ( M_AXI_RREADY             [ j*1           +: 1          ])
    );
    end
endgenerate
//S_HP_WR
generate
  genvar m;
  for( m=0; m<1; m=m+1 )
  begin: S_HP_WR

  wire  [ NUM_AXI*TID_WIDTH    -1 : 0 ]        M_AXI_AWID;
  wire  [ NUM_AXI*ADDR_W       -1 : 0 ]        M_AXI_AWADDR;
  wire  [ NUM_AXI*4            -1 : 0 ]        M_AXI_AWLEN;
  wire  [ NUM_AXI*3            -1 : 0 ]        M_AXI_AWSIZE;
  wire  [ NUM_AXI*2            -1 : 0 ]        M_AXI_AWBURST;
  wire  [ NUM_AXI*2            -1 : 0 ]        M_AXI_AWLOCK;
  wire  [ NUM_AXI*4            -1 : 0 ]        M_AXI_AWCACHE;
  wire  [ NUM_AXI*3            -1 : 0 ]        M_AXI_AWPROT;
  wire  [ NUM_AXI*4            -1 : 0 ]        M_AXI_AWQOS;
  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_AWVALID;
  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_AWREADY;

    // Master Interface Write Data
  wire  [ NUM_AXI*TID_WIDTH    -1 : 0 ]        M_AXI_WID;
  wire  [ NUM_AXI*AXI_DATA_W   -1 : 0 ]        M_AXI_WDATA;
  wire  [ NUM_AXI*WSTRB_W      -1 : 0 ]        M_AXI_WSTRB;
  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_WLAST;
  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_WVALID;
  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_WREADY;

    // Master Interface Write Response
  wire  [ NUM_AXI*TID_WIDTH    -1 : 0 ]        M_AXI_BID;
  wire  [ NUM_AXI*2            -1 : 0 ]        M_AXI_BRESP;
  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_BVALID;
  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_BREADY;

    // Master Interface Read Address
  wire  [ NUM_AXI*TID_WIDTH    -1 : 0 ]        M_AXI_ARID;
  wire  [ NUM_AXI*ADDR_W       -1 : 0 ]        M_AXI_ARADDR;
  wire  [ NUM_AXI*4            -1 : 0 ]        M_AXI_ARLEN;
  wire  [ NUM_AXI*3            -1 : 0 ]        M_AXI_ARSIZE;
  wire  [ NUM_AXI*2            -1 : 0 ]        M_AXI_ARBURST;
  wire  [ NUM_AXI*2            -1 : 0 ]        M_AXI_ARLOCK;
  wire  [ NUM_AXI*4            -1 : 0 ]        M_AXI_ARCACHE;
  wire  [ NUM_AXI*3            -1 : 0 ]        M_AXI_ARPROT;
  wire  [ NUM_AXI*4            -1 : 0 ]        M_AXI_ARQOS;
  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_ARVALID;
  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_ARREADY;

    // Master Interface Read Data
  wire  [ NUM_AXI*TID_WIDTH    -1 : 0 ]        M_AXI_RID;
  wire  [ NUM_AXI*AXI_DATA_W   -1 : 0 ]        M_AXI_RDATA;
  wire  [ NUM_AXI*2            -1 : 0 ]        M_AXI_RRESP;
  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_RLAST;
  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_RVALID;
  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_RREADY;

wire [ NUM_AXI              -1 : 0 ]        O_spi_sck;
wire [ NUM_AXI*SPI_WIDTH    -1 : 0 ]        IO_spi_data;
wire [ NUM_AXI              -1 : 0 ]        O_spi_cs_n;
wire [ NUM_AXI              -1 : 0 ]        near_full;
wire [ NUM_AXI              -1 : 0 ]        config_req;
wire [ NUM_AXI              -1 : 0 ]   full          ;
wire OE_req;



// ====================================================================================================================
// FPGA mem_controller_top instantiation
// ====================================================================================================================
  mem_controller_top_wr #(
  .NUM_AXI( NUM_AXI )
  )mem_controller_top ( // PORTS
    .clk                      ( clk                      ),
    .reset                    ( reset                    ),

    .O_spi_sck                ( O_spi_sck                 ),
    .IO_spi_data              ( IO_spi_data               ),
    .O_spi_cs_n               ( O_spi_cs_n                ),
    .near_full                ( full                 ),
    .config_req_              ( config_req                ),

    .M_AXI_AWID               ( M_AXI_AWID               ),
    .M_AXI_AWADDR             ( M_AXI_AWADDR             ),
    .M_AXI_AWLEN              ( M_AXI_AWLEN              ),
    .M_AXI_AWSIZE             ( M_AXI_AWSIZE             ),
    .M_AXI_AWBURST            ( M_AXI_AWBURST            ),
    .M_AXI_AWLOCK             ( M_AXI_AWLOCK             ),
    .M_AXI_AWCACHE            ( M_AXI_AWCACHE            ),
    .M_AXI_AWPROT             ( M_AXI_AWPROT             ),
    .M_AXI_AWQOS              ( M_AXI_AWQOS              ),
    .M_AXI_AWVALID            ( M_AXI_AWVALID            ),
    .M_AXI_AWREADY            ( M_AXI_AWREADY            ),
    .M_AXI_WID                ( M_AXI_WID                ),
    .M_AXI_WDATA              ( M_AXI_WDATA              ),
    .M_AXI_WSTRB              ( M_AXI_WSTRB              ),
    .M_AXI_WLAST              ( M_AXI_WLAST              ),
    .M_AXI_WVALID             ( M_AXI_WVALID             ),
    .M_AXI_WREADY             ( M_AXI_WREADY             ),
    .M_AXI_BID                ( M_AXI_BID                ),
    .M_AXI_BRESP              ( M_AXI_BRESP              ),
    .M_AXI_BVALID             ( M_AXI_BVALID             ),
    .M_AXI_BREADY             ( M_AXI_BREADY             ),
    .M_AXI_ARID               ( M_AXI_ARID               ),
    .M_AXI_ARADDR             ( M_AXI_ARADDR             ),
    .M_AXI_ARLEN              ( M_AXI_ARLEN              ),
    .M_AXI_ARSIZE             ( M_AXI_ARSIZE             ),
    .M_AXI_ARBURST            ( M_AXI_ARBURST            ),
    .M_AXI_ARLOCK             ( M_AXI_ARLOCK             ),
    .M_AXI_ARCACHE            ( M_AXI_ARCACHE            ),
    .M_AXI_ARPROT             ( M_AXI_ARPROT             ),
    .M_AXI_ARQOS              ( M_AXI_ARQOS              ),
    .M_AXI_ARVALID            ( M_AXI_ARVALID            ),
    .M_AXI_ARREADY            ( M_AXI_ARREADY            ),
    .M_AXI_RID                ( M_AXI_RID                ),
    .M_AXI_RDATA              ( M_AXI_RDATA              ),
    .M_AXI_RRESP              ( M_AXI_RRESP              ),
    .M_AXI_RLAST              ( M_AXI_RLAST              ),
    .M_AXI_RVALID             ( M_AXI_RVALID             ),
    .M_AXI_RREADY             ( M_AXI_RREADY             )
  );


      // DDR initial
    // integer ddr_idx;
    // integer tmp;

    // initial begin
    //       ddr_idx = (32'h080d8f90-32'h080d8f90) >> 1;
    //       tmp = 0;
    //         repeat (8192 ) begin //1024X8
    //           u_axim_driver.ddr_ram[ddr_idx] = tmp;
    //           // $display ("DDR_RAM[%h] = %b", ddr_idx, u_axim_driver.ddr_ram[ddr_idx]);
    //           ddr_idx = ddr_idx + 1;
    //           if( tmp < 255 )
    //             tmp = tmp + 1;
    //           else
    //             tmp = 0;
    //         end

    // end
    axi_master_tb_driver #(
        .AXI_DATA_WIDTH           ( AXI_DATA_W               ),
        .DATA_WIDTH               ( 8                        ),
        .NUM_PE                   ( 8                        ),
        .TX_SIZE_WIDTH            ( TX_SIZE_WIDTH            )
    ) u_axim_driver (
        .clk                      ( clk                                                     ),
        .reset                    ( reset                                                   ),
        .M_AXI_AWID               ( M_AXI_AWID               [ j*TID_WIDTH   +: TID_WIDTH  ]),
        .M_AXI_AWADDR             ( M_AXI_AWADDR             [ j*ADDR_W      +: ADDR_W     ]),
        .M_AXI_AWLEN              ( M_AXI_AWLEN              [ j*4           +: 4          ]),
        .M_AXI_AWSIZE             ( M_AXI_AWSIZE             [ j*3           +: 3          ]),
        .M_AXI_AWBURST            ( M_AXI_AWBURST            [ j*2           +: 2          ]),
        .M_AXI_AWLOCK             ( M_AXI_AWLOCK             [ j*2           +: 2          ]),
        .M_AXI_AWCACHE            ( M_AXI_AWCACHE            [ j*4           +: 4          ]),
        .M_AXI_AWPROT             ( M_AXI_AWPROT             [ j*3           +: 3          ]),
        .M_AXI_AWQOS              ( M_AXI_AWQOS              [ j*4           +: 4          ]),
        .M_AXI_AWVALID            ( M_AXI_AWVALID            [ j*1           +: 1          ]),
        .M_AXI_AWREADY            ( M_AXI_AWREADY            [ j*1           +: 1          ]),
        .M_AXI_WID                ( M_AXI_WID                [ j*TID_WIDTH   +: TID_WIDTH  ]),
        .M_AXI_WDATA              ( M_AXI_WDATA              [ j*AXI_DATA_W  +: AXI_DATA_W ]),
        .M_AXI_WSTRB              ( M_AXI_WSTRB              [ j*WSTRB_W     +: WSTRB_W    ]),
        .M_AXI_WLAST              ( M_AXI_WLAST              [ j*1           +: 1          ]),
        .M_AXI_WVALID             ( M_AXI_WVALID             [ j*1           +: 1          ]),
        .M_AXI_WREADY             ( M_AXI_WREADY             [ j*1           +: 1          ]),
        .M_AXI_BID                ( M_AXI_BID                [ j*TID_WIDTH   +: TID_WIDTH  ]),
        .M_AXI_BRESP              ( M_AXI_BRESP              [ j*2           +: 2          ]),
        .M_AXI_BVALID             ( M_AXI_BVALID             [ j*1           +: 1          ]),
        .M_AXI_BREADY             ( M_AXI_BREADY             [ j*1           +: 1          ]),
        .M_AXI_ARID               ( M_AXI_ARID               [ j*TID_WIDTH   +: TID_WIDTH  ]),
        .M_AXI_ARADDR             ( M_AXI_ARADDR             [ j*ADDR_W      +: ADDR_W     ]),
        .M_AXI_ARLEN              ( M_AXI_ARLEN              [ j*4           +: 4          ]),
        .M_AXI_ARSIZE             ( M_AXI_ARSIZE             [ j*3           +: 3          ]),
        .M_AXI_ARBURST            ( M_AXI_ARBURST            [ j*2           +: 2          ]),
        .M_AXI_ARLOCK             ( M_AXI_ARLOCK             [ j*2           +: 2          ]),
        .M_AXI_ARCACHE            ( M_AXI_ARCACHE            [ j*4           +: 4          ]),
        .M_AXI_ARPROT             ( M_AXI_ARPROT             [ j*3           +: 3          ]),
        .M_AXI_ARQOS              ( M_AXI_ARQOS              [ j*4           +: 4          ]),
        .M_AXI_ARVALID            ( M_AXI_ARVALID            [ j*1           +: 1          ]),
        .M_AXI_ARREADY            ( M_AXI_ARREADY            [ j*1           +: 1          ]),
        .M_AXI_RID                ( M_AXI_RID                [ j*TID_WIDTH   +: TID_WIDTH  ]),
        .M_AXI_RDATA              ( M_AXI_RDATA              [ j*AXI_DATA_W  +: AXI_DATA_W ]),
        .M_AXI_RRESP              ( M_AXI_RRESP              [ j*2           +: 2          ]),
        .M_AXI_RLAST              ( M_AXI_RLAST              [ j*1           +: 1          ]),
        .M_AXI_RVALID             ( M_AXI_RVALID             [ j*1           +: 1          ]),
        .M_AXI_RREADY             ( M_AXI_RREADY             [ j*1           +: 1          ])
    );
    end
    endgenerate
// ==================================================================
integer File_data_in_1;
integer File_data_in_2;
integer File_data_out_BUS;
wire    Switch_RdWr;
wire      ASIC_O_spi_cs_n;
wire      ASIC_OE_req;
wire      ASIC_config_req;
assign S_HP_WR[0].IO_spi_data  = S_HP_RD0[0].IO_spi_data;// input
assign ASIC_O_spi_cs_n = Switch_RdWr ? S_HP_RD0[0].O_spi_cs_n : S_HP_WR[0].O_spi_cs_n;
assign ASIC_OE_req = Switch_RdWr? S_HP_RD0[0].OE_req: 1;
assign S_HP_WR[0].config_req = Switch_RdWr? 0 : ASIC_config_req;
assign S_HP_RD0[0].config_req = Switch_RdWr? ASIC_config_req: 0;
wire DLL_clock_out_pad;
   supply1 VDD;
   supply1 VDDIO;
   supply0 VSS;
   supply0 VSSIO;
  ASIC
  ASIC (
      // .clk_chip            (clk_chip),
      .reset_n_pad         (reset_n_chip),
      .reset_dll_pad       (reset_dll   ),

      .IO_spi_data_rd0_pad (S_HP_RD0[0].IO_spi_data),
      .O_spi_sck_rd0_pad   (S_HP_RD0[0].O_spi_sck),
      .O_spi_cs_n_rd0_pad  (ASIC_O_spi_cs_n),
      .OE_req_rd0_pad      (ASIC_OE_req),
      .config_req_rd0_pad  (ASIC_config_req),
      .near_full_rd0_pad   (S_HP_RD0[0].full),
      .Switch_RdWr_pad            ( Switch_RdWr ),

      .DLL_BYPASS_i_pad    ( 1'b0 ),
      .DLL_clock_out_pad   ( DLL_clock_out_pad ),
      .clk_to_dll_i_pad    ( clk_chip  ),
      .S0_dll_pad          ( 1'b0     )
    );

initial begin
    File_data_in_1 = $fopen("File_data_in_1.txt");
    File_data_in_2 = $fopen("File_data_in_2.txt");
    File_data_out_BUS = $fopen("File_data_out_BUS.txt");
//    $dumpfile("mem_controller_tb.vcd");
 //   $dumpvars;
//save wave data ---------------------------------------------
    $shm_open("wave_gds_sim_20ns.shm" ,,,,1024);//1G
    $shm_probe(mem_controller_tb,"AC");
repeat(NumClk*2/3) @(negedge clk_chip);
    $shm_close;
repeat(NumClk/3) @(negedge clk_chip);
    $fclose(File_data_in_1);
    $fclose(File_data_in_2);
    $fclose(File_data_out_BUS);
    $finish;
  end

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
        @(negedge ASIC.TS3D.clk);// use ASIC.clk
        if (ASIC.TS3D.Reset_WEI)begin//paulse
            GBFFLGWEI_DatWr_File = $fopen("../testbench/Data/RAM_GBFFLGWEI_12B.dat","r");//Reset
            SPRS_MEM_Ref0 = $fopen("../testbench/Data/RAM_GBFWEI_12B.dat","r");
        end
        if(ASIC.TS3D.Reset_ACT) begin
              GBFFLGACT_DatWr_File = $fopen("../testbench/Data/RAM_GBFACT_12B1.dat","r");//Reset
              GBFACT_DatWr_File = $fopen("../testbench/Data/RAM_GBFACT_12B.dat","r");
        end
        if ( ASIC.TS3D.GBFFLGWEI_EnWr) begin
            Suc_GBFFLGWEI_DatWr=$fscanf(GBFFLGWEI_DatWr_File, "%h",GBFFLGWEI_DatWr);
            if(ASIC.TS3D.GBFFLGWEI_DatWr !=GBFFLGWEI_DatWr )
                $display("ERROR time: %t GBFFLGACT_DatWr_Mon = %h,GBFFLGWEI_DatWr_Ref = %h, ", $time,ASIC.TS3D.GBFFLGWEI_DatWr,GBFFLGWEI_DatWr);
        end
        if ( ASIC.TS3D.GBFWEI_EnWr) begin
            Suc_SPRS0=$fscanf(SPRS_MEM_Ref0, "%h",SPRS_MEM_RefDat0);
            if(ASIC.TS3D.GBFWEI_DatWr !=SPRS_MEM_RefDat0 )
                $display("ERROR time: %t GBFWEI_DatWr = %h, ", $time,SPRS_MEM_RefDat0);
        end
        if ( ASIC.TS3D.GBFFLGACT_EnWr) begin
            Suc_GBFFLGACT_DatWr=$fscanf(GBFFLGACT_DatWr_File, "%h",GBFFLGACT_DatWr);
            if(ASIC.TS3D.GBFFLGACT_DatWr !=GBFFLGACT_DatWr )
                $display("ERROR time: %t GBFFLGACT_DatWr_Mon = %h, GBFFLGACT_DatWr_Ref = %h", $time,ASIC.TS3D.GBFFLGACT_DatWr,GBFFLGACT_DatWr);
        end
        if ( ASIC.TS3D.GBFACT_EnWr) begin
            Suc_GBFACT_DatWr=$fscanf(GBFACT_DatWr_File, "%h",GBFACT_DatWr);
            if(ASIC.TS3D.GBFACT_DatWr !=GBFACT_DatWr )
                $display("ERROR time: %t GBFACT_DatWr_Mon = %h, GBFACT_DatWr_Ref = %h", $time,ASIC.TS3D.GBFACT_DatWr,GBFACT_DatWr);
        end
    end
end

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
                    @(negedge ASIC.clk);
                  if( ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.CfgMac) begin
                        @(negedge ASIC.clk);
                        $fdisplay(PECMAC_FlgAct_Mon,"%b",ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_FlgAct);
                        $fdisplay(PECMAC_Act_Mon,"%h",ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_Act);
                        Suc_FlgAct = $fscanf(PECMAC_FlgAct_Gen,"%b",PECMAC_FlgAct_GenDat);
                        Suc_Act=$fscanf(PECMAC_Act_Gen,"%h",PECMAC_Act_GenDat);

                        if(ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_FlgAct != PECMAC_FlgAct_GenDat)
                            $display("ERROR time: %t  PEB[%d].PEC[%d].Ref_PECMAC_FlgAct = %h; Mon_PECMAC_FlgAct = %h", $time,i,m0, PECMAC_FlgAct_GenDat,ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_FlgAct);
                        if(ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_Act != PECMAC_Act_GenDat)
                            $display("ERROR time: %t  PEB[%d].PEC[%d].PECMAC_Act = %h",  $time,i,m0, PECMAC_Act_GenDat);
                    end
                end
            end

            initial begin:PECMAC_FlgWei0_MonPECMAC_Wei0_Ref
                PECMAC_FlgWei0_Mon = $fopen("../testbench/Data/MonRTL/PECMAC_FlgWei0_Mon.dat","w");
                PECMAC_FlgWei0_Ref = $fopen("../testbench/Data/GenTest/PECMAC_FlgWei0_Ref.dat","r");
                PECMAC_Wei0_Ref = $fopen("../testbench/Data/GenTest/PECMAC_Wei0_Ref.dat","r");
                repeat(NumClk) begin
                    @(negedge ASIC.clk)
                    @(negedge ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.CfgWei) begin
                        @(negedge ASIC.clk)//ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_FlgAct);
                        //@(negedge ASIC.clk)//ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_FlgAct);
                        //$display("Test CfgWei");
                        //$fdisplay(PECMAC_FlgWei0_Mon,"%b",ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_FlgWei0);
                        //$fdisplay(PECMAC_Wei0_Mon,"%h",ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_Wei0);
                        Suc_FlgWei0 = $fscanf(PECMAC_FlgWei0_Ref,"%b",PECMAC_FlgWei0_RefDat);
                        Suc_Wei0=$fscanf(PECMAC_Wei0_Ref,"%h",PECMAC_Wei0_RefDat);

                        if(ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_FlgWei0[0+:`BLOCK_DEPTH] != PECMAC_FlgWei0_RefDat[ `BLOCK_DEPTH*(`NUMPEC-(3*i+m0) )*`KERNEL_SIZE -1 -: `BLOCK_DEPTH])
                            $display("ERROR time: %t  PEB[%d].PEC[%d].PECMAC_FlgWei0_Mon= %h PECMAC_FlgWei0_Ref = %h", $time,i,m0, ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_FlgWei0[0+:`BLOCK_DEPTH],PECMAC_FlgWei0_RefDat[ `BLOCK_DEPTH*(`NUMPEC-(3*i+m0) )*`KERNEL_SIZE -1 -: `BLOCK_DEPTH]);

                        NumVal <= 0;
                        for (addr=0;addr<32;addr=addr+1) begin
                            if(ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_FlgWei0[addr])
                                NumVal <= NumVal + 1;
                        end
                        for(addr=0;addr<NumVal;addr=addr+1)begin
                            if(ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_Wei0[`DATA_WIDTH*addr +: `DATA_WIDTH]!=PECMAC_Wei0_RefDat[`DATA_WIDTH*addr +: `DATA_WIDTH])
                                $display("ERROR time: %t  PEB[%d].PEC[%d].PECMAC_Wei0 = %h",  $time,i,m0, PECMAC_Wei0_RefDat);
                        end
                        //if(ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECMAC_Wei0 != PECMAC_Wei0_GenDat)
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
                    @(negedge ASIC.clk);
                    if(ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECRAM_EnWr) begin
                        // @(negedge ASIC.clk);
                        $fdisplay(PECRAM_DatWr_Mon,"%h",ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECRAM_DatWr);
                        Suc_DatWr = $fscanf(PECRAM_DatWr_Ref,"%h",PECRAM_DatWr_RefDat);

                        if(~(ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECRAM_DatWr == PECRAM_DatWr_RefDat[`DATA_WIDTH*`CEIL(`PSUM_WIDTH, `DATA_WIDTH)  * (`NUMPEC -(3*i+m0) -1)   +:`PSUM_WIDTH ]))
                            $display("ERROR time: %t  PEB[%d].PEC[%d].PECRAM_DatWr_Ref = %h,PECRAM_DatWr_Mon = %h", $time, i,m0,PECRAM_DatWr_RefDat[`DATA_WIDTH*`CEIL(`PSUM_WIDTH, `DATA_WIDTH)  * (`NUMPEC -(3*i+m0) -1)   +:`PSUM_WIDTH ],ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECRAM_DatWr);
                    end

                    if(ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECRAM_EnRd && ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].PECRAM_AddrRd < 8'hc4) begin // 14 rows
                        @(negedge ASIC.clk);
                        //$fdisplay(PECRAM_DatWr_Mon,"%h",ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.PECRAM_DatWr);
                        Suc_DatRd = $fscanf(RAMPEC_DatRd_Ref,"%h",RAMPEC_DatRd_RefDat);

                        if(~(ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.RAMPEC_DatRd == RAMPEC_DatRd_RefDat[`DATA_WIDTH*`CEIL(`PSUM_WIDTH, `DATA_WIDTH)  * (`NUMPEC -(3*i+m0) -1)   +:`PSUM_WIDTH ]))
                            $display("ERROR time: %t  PEB[%d].PEC[%d].RAMPEC_DatRd = %h", $time, i,m0,ASIC.TS3D.PEL.GENPEB[i].inst_PEB.GENPEC[m0].inst_PEC.RAMPEC_DatRd);
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
        @(negedge ASIC.clk);
        if ( ASIC.TS3D.POOL.SIPO_OFM.enable) begin
            Suc_SPRS=$fscanf(SPRS_MEM_Ref, "%h",SPRS_MEM_RefDat);
            Addr <= ASIC.TS3D.POOL.SPRS_Addr;
            if(ASIC.TS3D.POOL.SIPO_OFM.data_in !=SPRS_MEM_RefDat )
                $display("ERROR time: %t  SPRS_MEM[%h] = %h, SPRS %h", $time,Addr,ASIC.TS3D.POOL.SIPO_OFM.data_in, SPRS_MEM_RefDat);
        end
    end
end




endmodule
