`timescale 1ns/1ps
`include "../source/include/dw_params_presim.vh"
module mem_controller_top_wr
#( // INPUT PARAMETERS
  parameter integer NUM_AXI                           = 1             ,
  parameter integer AXI_DATA_W                        = 64            ,
  parameter integer ADDR_W                            = 32            ,
  parameter integer TX_SIZE_WIDTH                     = 20            ,
  parameter integer RUSER_W                           = 1             ,
  parameter integer BUSER_W                           = 1             ,
  parameter integer AWUSER_W                          = 1             ,
  parameter integer WUSER_W                           = 1             ,
  parameter integer TID_WIDTH                         = 6             ,
  parameter integer AXI_RD_BUFFER_W                   = 6             ,
  parameter integer WSTRB_W                           = AXI_DATA_W/8  ,
  parameter integer AXI_OUT_DATA_W                    = AXI_DATA_W * 1,
  parameter integer PU_ID_W                           = 1             ,
  parameter integer DATA_WIDTH                        = 96            ,

  parameter integer CONFIG_ADDR_WIDTH                 = 20            ,
  parameter integer CONFIG_SIZE_WIDTH                 = 9


)( // PORTS
  input  wire                                         clk        ,
  input  wire                                         reset      ,

  output wire  [ NUM_AXI              -1 : 0 ]        O_spi_sck  ,
  input  wire  [ NUM_AXI*DATA_WIDTH   -1 : 0 ]        IO_spi_data,
  output wire  [ NUM_AXI              -1 : 0 ]        O_spi_cs_n ,
  input  wire  [ NUM_AXI              -1 : 0 ]        config_req_,
  input  wire  [ NUM_AXI              -1 : 0 ]        near_full  ,
//=====================================================================================================================

  // Master Interface Write Address
  output wire  [ NUM_AXI*TID_WIDTH    -1 : 0 ]        M_AXI_AWID,
  output wire  [ NUM_AXI*ADDR_W       -1 : 0 ]        M_AXI_AWADDR,
  output wire  [ NUM_AXI*4            -1 : 0 ]        M_AXI_AWLEN,
  output wire  [ NUM_AXI*3            -1 : 0 ]        M_AXI_AWSIZE,
  output wire  [ NUM_AXI*2            -1 : 0 ]        M_AXI_AWBURST,
  output wire  [ NUM_AXI*2            -1 : 0 ]        M_AXI_AWLOCK,
  output wire  [ NUM_AXI*4            -1 : 0 ]        M_AXI_AWCACHE,
  output wire  [ NUM_AXI*3            -1 : 0 ]        M_AXI_AWPROT,
  output wire  [ NUM_AXI*4            -1 : 0 ]        M_AXI_AWQOS,
  output wire  [ NUM_AXI              -1 : 0 ]        M_AXI_AWVALID,
  input  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_AWREADY,

  // Master Interface Write Data
  output wire  [ NUM_AXI*TID_WIDTH    -1 : 0 ]        M_AXI_WID,
  output wire  [ NUM_AXI*AXI_DATA_W   -1 : 0 ]        M_AXI_WDATA,
  output wire  [ NUM_AXI*WSTRB_W      -1 : 0 ]        M_AXI_WSTRB,
  output wire  [ NUM_AXI              -1 : 0 ]        M_AXI_WLAST,
  output wire  [ NUM_AXI              -1 : 0 ]        M_AXI_WVALID,
  input  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_WREADY,

  // Master Interface Write Response
  input  wire  [ NUM_AXI*TID_WIDTH    -1 : 0 ]        M_AXI_BID,
  input  wire  [ NUM_AXI*2            -1 : 0 ]        M_AXI_BRESP,
  input  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_BVALID,
  output wire  [ NUM_AXI              -1 : 0 ]        M_AXI_BREADY,

  // Master Interface Read Address
  output wire  [ NUM_AXI*TID_WIDTH    -1 : 0 ]        M_AXI_ARID,
  output wire  [ NUM_AXI*ADDR_W       -1 : 0 ]        M_AXI_ARADDR,
  output wire  [ NUM_AXI*4            -1 : 0 ]        M_AXI_ARLEN,
  output wire  [ NUM_AXI*3            -1 : 0 ]        M_AXI_ARSIZE,
  output wire  [ NUM_AXI*2            -1 : 0 ]        M_AXI_ARBURST,
  output wire  [ NUM_AXI*2            -1 : 0 ]        M_AXI_ARLOCK,
  output wire  [ NUM_AXI*4            -1 : 0 ]        M_AXI_ARCACHE,
  output wire  [ NUM_AXI*3            -1 : 0 ]        M_AXI_ARPROT,
  output wire  [ NUM_AXI*4            -1 : 0 ]        M_AXI_ARQOS,
  output wire  [ NUM_AXI              -1 : 0 ]        M_AXI_ARVALID,
  input  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_ARREADY,

  // Master Interface Read Data
  input  wire  [ NUM_AXI*TID_WIDTH    -1 : 0 ]        M_AXI_RID,
  input  wire  [ NUM_AXI*AXI_DATA_W   -1 : 0 ]        M_AXI_RDATA,
  input  wire  [ NUM_AXI*2            -1 : 0 ]        M_AXI_RRESP,
  input  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_RLAST,
  input  wire  [ NUM_AXI              -1 : 0 ]        M_AXI_RVALID,
  output wire  [ NUM_AXI              -1 : 0 ]        M_AXI_RREADY

  );

// ====================================================================================================================
// WIRES
// ====================================================================================================================
// read
    parameter         OF_BASE_ADDR                      = 32'h0804_8000 ; //
    parameter         OF_FLAG_BASE_ADDR                 = 32'h0805_0000 ; //4MB outfm
    parameter         OF_DEFAULT_ADDR                   = 32'h0806_0000  ;

    parameter         ACT_BASE_ADDR                     = 32'h080d_8f90 ;
    parameter         ACT_FLAG_BASE_ADDR                = 32'h0840_0000 ; //4MB act
    // parameter OF_BASE_ADDR                             = 32'h0850_0000, //1MB act
    parameter         WEI_BASE_ADDR                     = 32'h0950_0000 ; //
    parameter         WEI_FLAG_BASE_ADDR                = 32'h1950_0000 ;  //256MB WEI
    parameter         CONFIG_ADDR                       = 32'h1b00_0000 ;
    localparam IDLE = 0, CONFIG = 1, WAIT = 2, RD_DATA = 3, WR_WAIT = 4, WR_DATA = 5;

    parameter g = 0;
    parameter BYTE_WIDTH = 8;
// genvar g;
// generate
// for ( g=0 ; g<NUM_AXI; g=g+1)
// begin: AXI_GEN

    wire                                    config_req;
    reg                                     rd_req;
    reg  [ TX_SIZE_WIDTH          - 1 : 0 ] rd_req_size;
    reg  [ TX_SIZE_WIDTH          - 1 : 0 ] rd_req_size_config;
    reg  [ ADDR_W                 - 1 : 0 ] rd_addr;
    reg  [ ADDR_W                 - 1 : 0 ] rd_addr_config;
    wire                                    rd_ready;
    wire                                    axi_rd_ready;
    wire [ AXI_DATA_W             - 1 : 0 ] axi_rd_buffer_data_in;
    wire                                    axi_rd_buffer_push;
    wire                                    axi_rd_buffer_full    ;
    wire                                    inbuf_full;
    wire [TX_SIZE_WIDTH           - 1 : 0 ] rx_size;

    // write
    wire [ AXI_OUT_DATA_W         - 1 : 0 ] outbuf_data_out;
    reg                                     wr_req;
    wire                                    wr_ready;
    reg  [ ADDR_W                 - 1 : 0 ] wr_addr;
    reg  [ TX_SIZE_WIDTH          - 1 : 0 ] wr_req_size;
    wire                                    wr_done;
    wire [ 1                      - 1 : 0 ] write_valid;
    wire [ 1                      - 1 : 0 ] outbuf_empty;
    wire [ 1                      - 1 : 0 ] outbuf_pop;
    wire                                    wr_ready_axi;
    wire [ TX_SIZE_WIDTH          - 1 : 0 ] tx_size;

    //AXI
    wire [ PU_ID_W                - 1 : 0 ] wr_pu_id;
    wire [ PU_ID_W                - 1 : 0 ] pu_id;
    wire                                    M_AXI_AWUSER;
    wire                                    M_AXI_WUSER ;
    wire                                    M_AXI_ARUSER;
    wire [ RUSER_W                - 1 : 0 ] M_AXI_RUSER;
    wire [ BUSER_W                - 1 : 0 ] M_AXI_BUSER;

    // assign M_AXI_AWUSER = 0;
    // assign M_AXI_WUSER  = 0;
    // assign M_AXI_ARUSER = 0;
    assign wr_pu_id     = 0;
    // ====================================================================================================================



    // ====================================================================================================================
    // AXI TO SPI fifo-unpacker-fifo
    // ====================================================================================================================
    wire                                          m_packed_read_req     ;
    wire                                          axi_rd_buffer_empty   ;
    wire                                          axi_rd_buffer_pop     ;
    wire                                          axi_rd_buffer_push_d  ;
    wire  [ AXI_DATA_W                  - 1 : 0 ] axi_rd_buffer_data_out;

    fifo#(
        .DATA_WIDTH               ( AXI_DATA_W               ),
        .ADDR_WIDTH               ( AXI_RD_BUFFER_W          )
      ) axi_rd_buffer (
        .clk                      ( clk                      ),  //input
        .reset                    ( reset                    ),  //input
        .push                     ( axi_rd_buffer_push       ),  //input RVALID
        .full                     ( axi_rd_buffer_full       ),  //output
        .data_in                  ( axi_rd_buffer_data_in    ),  //input M_AXI_RDATA
        .pop                      ( axi_rd_buffer_pop        ),  //input maybe full fifo_full
        .empty                    ( axi_rd_buffer_empty      ),  //output
        .data_out                 ( axi_rd_buffer_data_out   ),  //ordutput
        .fifo_count               (                          )   //output
      );

    assign axi_rd_buffer_pop = !axi_rd_buffer_empty && m_packed_read_req;
    wire                                          m_unpacked_write_ready;
    wire                                          m_unpacked_write_req  ;
    wire  [ DATA_WIDTH                  - 1 : 0 ] m_unpacked_write_data ;
    wire                                          m_packed_read_ready   ;

    // 64 bit width to 32 bitwidth
    data_unpacker #(
        .IN_WIDTH              (AXI_DATA_W  ),
        .OUT_WIDTH             (DATA_WIDTH  )
      )data_unpacker(
        .clk                   ( clk                    ),//input
        .reset                 ( reset                  ),//input
        .m_packed_read_req     ( m_packed_read_req      ),//output  push
        .m_packed_read_data    ( axi_rd_buffer_data_out ),//input
        .m_packed_read_ready   ( m_packed_read_ready    ),//input  enable
        .m_unpacked_write_ready( m_unpacked_write_ready ),//input  not used
        .m_unpacked_write_req  ( m_unpacked_write_req   ),//output
        .m_unpacked_write_data ( m_unpacked_write_data  )//output
      );
    assign m_packed_read_ready = !axi_rd_buffer_empty;

    wire                                          spi_fifo_full;
    wire                                          spi_fifo_empty;
    wire [ DATA_WIDTH                   - 1 : 0 ] spi_fifo_out;
    wire                                          spi_fifo_pop;
    wire                                          O_tx_done;

    fifo#(
        .DATA_WIDTH               ( DATA_WIDTH              ),
        .ADDR_WIDTH               ( 8                       )
      ) fifo_spi_fpga_out (
        .clk                      ( clk                     ),  //input
        .reset                    ( reset                   ),  //input
        .push                     ( m_unpacked_write_req    ),  //input RVALID
        .full                     ( spi_fifo_full           ),  //output
        .data_in                  ( m_unpacked_write_data   ),  //input M_AXI_RDATA
        .pop                      ( spi_fifo_pop            ),  //input maybe full fifo_full
        .empty                    ( spi_fifo_empty          ),  //output
        .data_out                 ( spi_fifo_out            ),  //output
        .fifo_count               (                         )   //output
      );

    wire                                            near_full_d;
    wire                                            near_full_dd;

    assign spi_fifo_pop = !spi_fifo_empty && !near_full_d; //
    //=====================================================================================================================


    // ====================================================================================================================
    // state FSM
    // ====================================================================================================================
    reg [ DATA_WIDTH                      - 1 : 0 ] O_data_out;
    wire                                            spi_fifo_in_empty;
    wire                                            spi_fifo_push;
    reg [ TX_SIZE_WIDTH                   - 1 : 0 ] wr_count;
    wire[ 3                               - 1 : 0 ] state;
    wire[ 3                               - 1 : 0 ] state_d,state_dd;
    wire[ 3                               - 1 : 0 ] state_ddd;
    reg [ 3                               - 1 : 0 ] next_state;




    reg config_ready;
      always @(*)
      begin
        next_state = state;
        case (state)
          IDLE    : if ( config_req )
                      next_state = CONFIG;

          CONFIG  : next_state = WAIT;

          WAIT    : next_state = WR_WAIT;

          RD_DATA : if ( config_ready && rx_size == 0 && spi_fifo_empty )
                      next_state = IDLE;

          WR_WAIT : if(state_d == WR_WAIT) //
                      next_state = WR_DATA;

          WR_DATA : if( wr_count == ( (wr_req_size << 1) - 3) ) //config_ready && tx_size == 0 &&
                      next_state = IDLE;
        endcase
      end
    always @(posedge clk or negedge reset) begin : proc_wr_count
      if(reset) begin
        wr_count <= 0;
      end else if( wr_count == wr_req_size << 1) begin
        wr_count <= 0;
      end else if( spi_fifo_push) begin
        wr_count <= wr_count + 1;
      end
    end
    // ====================================================================================================================


    // ====================================================================================================================
    // SPI interface
    // ====================================================================================================================
     reg O_spi_cs_n_;
     always @(negedge clk or negedge reset) begin : proc_O_spi_cs_rx
      if(reset) begin
        O_spi_cs_n_ <= 1;
      end else if( state == RD_DATA ) begin
          if( !spi_fifo_empty && !near_full_d ) //
            O_spi_cs_n_ <= 0;
          else
            O_spi_cs_n_ <= 1;
      end else if ( state == WR_DATA ) begin //
            O_spi_cs_n_ <= 0;
      end else
            O_spi_cs_n_ <= 1;
    end

    reg O_spi_cs_n_d;
    reg O_spi_cs_n_dd;
     always @(negedge clk or negedge reset) begin : proc_O_spi_cs
      O_spi_cs_n_d <= O_spi_cs_n_;
      O_spi_cs_n_dd <= O_spi_cs_n_d;
    end

    // assign O_spi_cs_n[g*1+:1] = ( state_d == RD_DATA )? O_spi_cs_n_d : ( state == WR_DATA || state == CONFIG )? O_spi_cs_n_ : 1'b1;
    assign O_spi_cs_n[g*1+:1] = ( state_d == RD_DATA )? O_spi_cs_n_d : ( state == WR_DATA || state_d == WR_DATA)? O_spi_cs_n_ : 1'b1;

    assign O_spi_sck[g*1+:1] = clk;

    reg  [ DATA_WIDTH  - 1 : 0 ]                O_spi_mosi;
    always @(negedge clk or negedge reset) begin : proc_O_spi_mosi
      O_spi_mosi <= spi_fifo_out;
    end
 //   assign IO_spi_data[g*DATA_WIDTH+:DATA_WIDTH] = ( state_d == RD_DATA )? O_spi_mosi : 32'dz;

    always @(posedge clk or negedge reset) begin : proc_O_data_out  //posedge clk sample
      if(reset) begin
        O_data_out <= 0;
      end else if( state == CONFIG || !O_spi_cs_n_d ) begin //
        O_data_out <= IO_spi_data[g*DATA_WIDTH+:DATA_WIDTH];
      end
    end
    // ====================================================================================================================


    // ====================================================================================================================
    // SPI TO AXI fifo-packer-fifo
    // ====================================================================================================================
    wire                            spi_fifo_in_full;
    wire                            spi_fifio_in_pop;

    wire [ DATA_WIDTH     - 1 : 0 ] spi_fifo_in_out;
    assign spi_fifo_push = state_dd == WR_DATA ? !O_spi_cs_n_dd : 1'b0; // !O_spi_cs_n_d -> spi_fifo_push
    // assign spi_fifo_push = state_d == WR_DATA ? 1'b1 : 1'b0;
      fifo#(
        .DATA_WIDTH               ( DATA_WIDTH              ),
        .ADDR_WIDTH               ( 8                       )
      ) fifo_spi_fpga_in (
        .clk                      ( clk                     ),  //input
        .reset                    ( reset                   ),  //input
        .push                     ( spi_fifo_push           ),  //input RVALID
        .full                     ( spi_fifo_in_full        ),  //output
        .data_in                  ( O_data_out              ),  //input M_AXI_RDATA
        .pop                      ( spi_fifio_in_pop        ),  //input maybe full fifo_full
        .empty                    ( spi_fifo_in_empty       ),  //output
        .data_out                 ( spi_fifo_in_out         ),  //output
        .fifo_count               (                         )   //output
      );

      wire                                        s_write_req;
      wire                                        s_write_ready;
      wire [ DATA_WIDTH      - 1 : 0 ]            s_write_data;

      wire                                         m_write_req;
      wire                                         axi_wr_buffer_full;
      wire [ AXI_DATA_W        - 1 : 0 ]           m_write_data;

      assign spi_fifio_in_pop = !spi_fifo_in_empty && s_write_ready;
    register #(
      .NUM_STAGES ( 1), //s_write_data and s_write_req is simultaneous
      .DATA_WIDTH ( 1 )
      )s_write_req_delay(
      .CLK   ( clk                ),
      .RESET ( reset              ),
      .DIN   ( spi_fifio_in_pop   ),
      .DOUT  ( s_write_req        )
      );
      assign s_write_data = spi_fifo_in_out;
    // 32 bit width to 64 bitwidth
    data_packer #(
        .IN_WIDTH  ( DATA_WIDTH  ),
        .OUT_WIDTH ( AXI_DATA_W   )
        )data_packer(
        .clk            ( clk           ),//input
        .reset          ( reset         ),//input
        .s_write_req    ( s_write_req   ),//input push
        .s_write_ready  ( s_write_ready ),//output
        .s_write_data   ( s_write_data  ),//input
        .m_write_req    ( m_write_req   ),//output pop
        .m_write_ready  ( ~axi_wr_buffer_full),//input  fifo not full
        .m_write_data   ( m_write_data  )//output
        );
    wire outbuf_push;
    assign outbuf_push = m_write_req;

    fifo_fwft #( //first write out first data
        .DATA_WIDTH               ( AXI_DATA_W               ),
        .ADDR_WIDTH               ( 8                        ) //
      ) axi_wr_buffer (
        .clk                      ( clk                      ),  //input
        .reset                    ( reset                    ),  //input
        .push                     ( outbuf_push              ),  //input RVALID
        .full                     ( axi_wr_buffer_full       ),  //output
        .data_in                  ( m_write_data             ),  //input M_AXI_RDATA
        .pop                      ( outbuf_pop               ),  //input
        .empty                    ( outbuf_empty             ),  //output
        .data_out                 ( outbuf_data_out          ),  //output
        .fifo_count               (                          )   //output
      );
    assign write_valid  = outbuf_push;
    assign rd_ready     = axi_rd_ready ;
    assign wr_ready     = wr_ready_axi ;
    assign inbuf_full   = axi_rd_buffer_full;


    // ====================================================================================================================
    // config_ready
    // ====================================================================================================================
    wire                                            config_req_d;

    wire                                            config_req_p;
    wire                                            config_req_n;
    wire                                            config_req_n_5d;

    assign config_req_p = !config_req_d && config_req;
    assign config_req_n = config_req_d && !config_req;
    always @(posedge clk or negedge reset) begin : proc_config_ready
      if(reset) begin
        config_ready <= 0;
      end else if( config_req_p) begin//
        config_ready <= 0;
      end else if( config_req_n_5d) begin //
        config_ready <= 1;
      end
    end
    // ====================================================================================================================


    // ====================================================================================================================
    // AXI config
    // ====================================================================================================================
    reg                                 rd_req_config;
    reg                                 wr_req_config;
    reg [ ADDR_W               -1 : 0 ] wr_addr_config;
    reg [ TX_SIZE_WIDTH        -1 : 0 ] wr_req_size_config;

reg [TX_SIZE_WIDTH   - 1 :0] count_rd0;
reg [TX_SIZE_WIDTH   - 1 :0] count_rd1;
reg [TX_SIZE_WIDTH   - 1 :0] count_rd2;
reg [TX_SIZE_WIDTH   - 1 :0] count_rd3;
reg [TX_SIZE_WIDTH   - 1 :0] count_rd4;
reg [TX_SIZE_WIDTH   - 1 :0] count_rd5;
reg [TX_SIZE_WIDTH   - 1 :0] count_rd6;
reg [TX_SIZE_WIDTH   - 1 :0] count_rd7;
reg [TX_SIZE_WIDTH   - 1 :0] count_rd8;

    always @(posedge clk or negedge reset) begin : proc_config_bus
      if(reset) begin
        rd_req_config       <= 0;
        rd_addr_config      <= 0;
        rd_req_size_config  <= 0;
        wr_req_config       <= 0;
        wr_addr_config      <= 0;
        wr_req_size_config  <= 0;
        count_rd0 <= 0;
        count_rd1 <= 0;
        count_rd2 <= 0;
        count_rd3 <= 0;
        count_rd4 <= 0;
        count_rd5 <= 0;
        count_rd6 <= 0;
        count_rd7 <= 0;
        count_rd8 <= 0;
      end else if( state == WAIT )begin // Cache config data
         case ( O_data_out[31:28])
          `IFCODE_FLGOFM:  begin wr_req_size_config = `WR_SIZE_FLGOFM*`PORT_DATAWIDTH/AXI_DATA_W;   wr_addr_config = OF_FLAG_BASE_ADDR     + (`WR_SIZE_FLGOFM*`PORT_DATAWIDTH/BYTE_WIDTH)*count_rd0 ; count_rd0 <= count_rd0 + 1; end

          `IFCODE_OFM:  begin wr_req_size_config = `WR_SIZE_OFM*`PORT_DATAWIDTH/AXI_DATA_W;  wr_addr_config = OF_BASE_ADDR + (`WR_SIZE_OFM*`PORT_DATAWIDTH/BYTE_WIDTH)*count_rd2 ; count_rd2 <= count_rd2 + 1; end

          default : begin wr_addr_config  <=  OF_DEFAULT_ADDR ;
          end
          endcase // {rw, type_cs }

         wr_req_config      <= 1;
         //wr_req_size_config <= 32;
      // end else if( rd_ready || wr_ready) begin
      end else if( wr_ready) begin
        rd_req_config       <= 0; //
        rd_addr_config      <= 0;
        rd_req_size_config  <= 0;
        wr_req_config       <= 0; // reset
        wr_addr_config      <= 0;
        // wr_req_size_config <= 0;
      end
    end

    always @(posedge clk or negedge reset) begin : proc_rd_req
      if(reset) begin
        rd_req      <= 0;
        rd_addr     <= 0;
        rd_req_size <= 0;
      end else if( rd_ready ) begin //
        rd_req      <= rd_req_config; //
        rd_addr     <= rd_addr_config;
        rd_req_size <= rd_req_size_config;
      end
    end

    always @(posedge clk or negedge reset) begin : proc_wr_req
      if(reset) begin
        wr_req      <= 0;
        wr_addr     <= 0;
        wr_req_size <= 0;
      end else if( wr_ready ) begin //
        wr_req      <= wr_req_config; //
        wr_addr     <= wr_addr_config;
        wr_req_size <= wr_req_size_config;
      end
    end

    // ====================================================================================================================



    // ====================================================================================================================
    // Instantiation
    // ====================================================================================================================

      axi_master
      axi_master
      (
        .clk                      ( clk                      ),
        .reset                    ( reset                    ),

        .M_AXI_AWID               ( M_AXI_AWID    [ g*TID_WIDTH   +: TID_WIDTH  ]           ),
        .M_AXI_AWADDR             ( M_AXI_AWADDR  [ g*ADDR_W      +: ADDR_W     ]           ),
        .M_AXI_AWLEN              ( M_AXI_AWLEN   [ g*4           +: 4          ]           ),
        .M_AXI_AWSIZE             ( M_AXI_AWSIZE  [ g*3           +: 3          ]           ),
        .M_AXI_AWBURST            ( M_AXI_AWBURST [ g*2           +: 2          ]           ),
        .M_AXI_AWLOCK             ( M_AXI_AWLOCK  [ g*2           +: 2          ]           ),
        .M_AXI_AWCACHE            ( M_AXI_AWCACHE [ g*4           +: 4          ]           ),
        .M_AXI_AWPROT             ( M_AXI_AWPROT  [ g*3           +: 3          ]           ),
        .M_AXI_AWQOS              ( M_AXI_AWQOS   [ g*4           +: 4          ]           ),
        .M_AXI_AWVALID            ( M_AXI_AWVALID [ g*1           +: 1          ]           ),
        .M_AXI_AWREADY            ( M_AXI_AWREADY [ g*1           +: 1          ]           ),
        .M_AXI_AWUSER             ( M_AXI_AWUSER                                            ),

        .M_AXI_WID                ( M_AXI_WID     [ g*TID_WIDTH   +: TID_WIDTH  ]           ),
        .M_AXI_WDATA              ( M_AXI_WDATA   [ g*AXI_DATA_W  +: AXI_DATA_W ]           ),
        .M_AXI_WSTRB              ( M_AXI_WSTRB   [ g*WSTRB_W     +: WSTRB_W    ]           ),
        .M_AXI_WLAST              ( M_AXI_WLAST   [ g*1           +: 1          ]           ),
        .M_AXI_WVALID             ( M_AXI_WVALID  [ g*1           +: 1          ]           ),
        .M_AXI_WREADY             ( M_AXI_WREADY  [ g*1           +: 1          ]           ),
        .M_AXI_WUSER              ( M_AXI_WUSER                                             ),

        .M_AXI_BID                ( M_AXI_BID     [ g*TID_WIDTH   +: TID_WIDTH  ]           ),
        .M_AXI_BRESP              ( M_AXI_BRESP   [ g*2           +: 2          ]           ),
        .M_AXI_BVALID             ( M_AXI_BVALID  [ g*1           +: 1          ]           ),
        .M_AXI_BREADY             ( M_AXI_BREADY  [ g*1           +: 1          ]           ),
        .M_AXI_BUSER              ( M_AXI_BUSER                                             ),

        .M_AXI_ARID               ( M_AXI_ARID    [ g*TID_WIDTH   +: TID_WIDTH  ]           ),
        .M_AXI_ARADDR             ( M_AXI_ARADDR  [ g*ADDR_W      +: ADDR_W     ]           ),
        .M_AXI_ARLEN              ( M_AXI_ARLEN   [ g*4           +: 4          ]           ),
        .M_AXI_ARSIZE             ( M_AXI_ARSIZE  [ g*3           +: 3          ]           ),
        .M_AXI_ARBURST            ( M_AXI_ARBURST [ g*2           +: 2          ]           ),
        .M_AXI_ARLOCK             ( M_AXI_ARLOCK  [ g*2           +: 2          ]           ),
        .M_AXI_ARCACHE            ( M_AXI_ARCACHE [ g*4           +: 4          ]           ),
        .M_AXI_ARPROT             ( M_AXI_ARPROT  [ g*3           +: 3          ]           ),
        .M_AXI_ARQOS              ( M_AXI_ARQOS   [ g*4           +: 4          ]           ),
        .M_AXI_ARVALID            ( M_AXI_ARVALID [ g*1           +: 1          ]           ),
        .M_AXI_ARREADY            ( M_AXI_ARREADY [ g*1           +: 1          ]           ),
        .M_AXI_ARUSER             ( M_AXI_ARUSER                                            ),

        .M_AXI_RID                ( M_AXI_RID     [ g*TID_WIDTH   +: TID_WIDTH  ]           ),
        .M_AXI_RDATA              ( M_AXI_RDATA   [ g*AXI_DATA_W  +: AXI_DATA_W ]           ),
        .M_AXI_RRESP              ( M_AXI_RRESP   [ g*2           +: 2          ]           ),
        .M_AXI_RLAST              ( M_AXI_RLAST   [ g*1           +: 1          ]           ),
        .M_AXI_RVALID             ( M_AXI_RVALID  [ g*1           +: 1          ]           ),
        .M_AXI_RREADY             ( M_AXI_RREADY  [ g*1           +: 1          ]           ),
        .M_AXI_RUSER              ( M_AXI_RUSER                                             ),
        // NPU Design
        // WRITE from BRAM to DDR
        .outbuf_empty             ( outbuf_empty             ),//input not used
        .outbuf_pop               ( outbuf_pop               ),//output
        .data_from_outbuf         ( outbuf_data_out          ),//in

        // READ from DDR to BRAM
        .data_to_inbuf            ( axi_rd_buffer_data_in    ),//output read data
        .inbuf_push               ( axi_rd_buffer_push       ),//output read valid
        .inbuf_full               ( inbuf_full               ),

        // Memory Controller Interface - Read
        .rd_req                   ( rd_req                   ),//in
        .rd_ready                 ( axi_rd_ready             ),//output addr fifo not full
        .rd_req_size              ( rd_req_size              ),//in
        .rd_addr                  ( rd_addr                  ),//in
        .rx_size                  ( rx_size                  ),//output

        // Memory Controller Interface - Write
        .wr_req                   ( wr_req                   ),
        .wr_pu_id                 ( wr_pu_id                 ),
        .wr_ready                 ( wr_ready_axi                 ), //output
        .wr_req_size              ( wr_req_size              ),
        .wr_addr                  ( wr_addr                  ),//input
        .pu_writes_remaining      ( tx_size                 ),
        .wr_done                  ( wr_done                  ),//output
        .write_valid              ( write_valid              ) //input ***
      );
    // ====================================================================================================================


    // ====================================================================================================================
    // DELAY
    // ====================================================================================================================
    // Two-stage FlipFlop
    register #(
      .NUM_STAGES ( 2 ), //
      .DATA_WIDTH ( 1 )
      )config_req_delay(
      .CLK   ( clk        ),
      .RESET ( reset      ),
      .DIN   ( config_req_[g*1+:1]),
      .DOUT  ( config_req )
      );

    register #(
      .NUM_STAGES ( 1 ), //determined by chip
      .DATA_WIDTH ( 1 )
      )act_fifo_near_full_d_delay(
      .CLK   ( clk          ),
      .RESET ( reset        ),
      .DIN   ( near_full[g*1+:1]    ),
      .DOUT  ( near_full_d  )
      );

    register #(
      .NUM_STAGES ( 2 ), //determined by chip
      .DATA_WIDTH ( 1 )
      )act_fifo_near_full_dd_delay(
      .CLK    ( clk           ),
      .RESET  ( reset         ),
      .DIN    ( near_full[g*1+:1]     ),
      .DOUT   ( near_full_dd  )
      );
    register #(
      .NUM_STAGES( 1),
      .DATA_WIDTH ( 3 )
      )state_delay(
      .CLK ( clk ),
      .RESET ( reset ),
      .DIN ( next_state),
      .DOUT ( state )
      );
    register #(
      .NUM_STAGES( 1),
      .DATA_WIDTH ( 3 )
      )state_d_delay(
      .CLK ( clk ),
      .RESET ( reset ),
      .DIN ( state),
      .DOUT ( state_d )
      );
      register #(
      .NUM_STAGES( 2),
      .DATA_WIDTH ( 3 )
      )state_dd_delay(
      .CLK ( clk ),
      .RESET ( reset ),
      .DIN ( state),
      .DOUT ( state_dd )
      );
    register #(
      .NUM_STAGES( 1),
      .DATA_WIDTH ( 1 )
      )config_req_d_delay(
      .CLK ( clk ),
      .RESET ( reset ),
      .DIN ( config_req),
      .DOUT ( config_req_d )
      );

    register #(
      .NUM_STAGES( 5),
      .DATA_WIDTH ( 1 )
      )config_req_n_5d_delay(
      .CLK ( clk ),
      .RESET ( reset ),
      .DIN ( config_req_n),
      .DOUT ( config_req_n_5d )
      );
// end
// endgenerate

endmodule
