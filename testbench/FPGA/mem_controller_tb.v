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
//reg write_ddr;
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
//    File_data_in_1 = $fopen("File_data_in_1.txt");
//    File_data_in_2 = $fopen("File_data_in_2.txt");
//    File_data_out_BUS = $fopen("File_data_out_BUS.txt");
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
//`ifdef SYNTH_MINI // hieracal
    test_data #(
    .NumClk(NumClk)
    )test_data();
//`endif
Init_DDR Init_DDR();

endmodule
