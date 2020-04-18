// `define UNITE 1
`include "../source/include/dw_params_presim.vh"
module top_asyncFIFO_rd #(
    parameter SPI_WIDTH = 32,
    parameter ADDR_WIDTH_FIFO = 5,
    parameter RX_WIDTH = 20
    )(
    input                                   clk_chip      , //ASIC
    input                                   reset_n_chip  , //ASIC
    input                                   O_spi_sck     , //FPGA //PAD
    input [ SPI_WIDTH         - 1 : 0 ]     I_spi_data,
    output [ SPI_WIDTH         - 1 : 0 ]    O_spi_data,
    input                                   O_spi_cs_n    , //FPGA //PAD
    output reg                              config_req    , //FPGA //PAD
    output                                  full          ,

    output                                  config_ready  , //ASIC
    input                                   config_paulse , //ASIC pull up
    input [ 4              -1 : 0 ]         config_data   , //ASIC
    input [ `IFSCHEDULE_WIDTH             -1 : 0 ]     IF_schedule,
    output reg [ 4               - 1 : 0 ]O_config_data,
    input                                   rd_req        ,
    output                                  rd_valid      , //ASIC
    output[ 1*SPI_WIDTH    -1 : 0 ]         rd_data,         //ASIC,
    output                                  rd_done
    );
// wire full_level;
//wire                        reset_n_fifo  ;
wire                          rd_paulse ;
reg [ RX_WIDTH          - 1 : 0 ] rd_count      ;
//wire                        rd_done       ;
reg O_spi_cs_n_sync, O_spi_cs_n_2, O_spi_cs_n_1;
reg [ 3         - 1 : 0 ]   state         ;  //ASIC
reg [ `IFSCHEDULE_WIDTH        - 1  : 0]    O_IF_schedule;
localparam IDLE = 0, CONFIG = 1, WAIT = 2, RD_DATA = 3,  WR_DATA = 4, RESET_FIFO = 5;

assign config_ready = state           == IDLE ;

always @(posedge clk_chip or negedge reset_n_chip) begin
  if(!reset_n_chip) begin
    state <= IDLE;
  end else begin
    case (state)
      IDLE    : if ( config_paulse )
                  state <= CONFIG;

      CONFIG  : state <= WAIT;

      WAIT    : if( !O_spi_cs_n_sync ) //
                  state <= RD_DATA;

      RD_DATA : if ( rd_done )
                  state <= RESET_FIFO;

      RESET_FIFO: state <= IDLE;
    endcase
  end
end

always @(posedge clk_chip or negedge reset_n_chip) begin : proc_config_req
  if(!reset_n_chip) begin
    config_req <= 0;
  end else if( state == CONFIG )begin //paulse
    config_req <= 1;
  end else if( state == RD_DATA || state == WR_DATA )begin//
    config_req <= 0;
  end
end

always @(posedge clk_chip or negedge reset_n_chip) begin : proc_rd_count
  if(~reset_n_chip) begin
    rd_count <= 0;
  end else if( rd_done ) begin
    rd_count <= 0;
  end else if( rd_valid) begin
    rd_count <= rd_count + 1;
  end else
    rd_count <= rd_count;
end

reg [ RX_WIDTH          - 1 : 0 ] rd_size      ;
always @( posedge clk_chip or negedge reset_n_chip) begin : proc_rd_size
  if(!reset_n_chip) begin
    rd_size <= 43;
    O_IF_schedule <=0;
  end else if ( config_paulse) begin
    case(config_data)
      `IFCODE_CFG:  rd_size <= `RD_SIZE_CFG;
      `IFCODE_ACT:  rd_size <= `RD_SIZE_ACT;
      `IFCODE_FLGACT:  rd_size <= `RD_SIZE_FLGACT;
      `IFCODE_WEI:  rd_size <= `RD_SIZE_WEI;
      `IFCODE_FLGWEI:  rd_size <= `RD_SIZE_FLGWEI;
      default:  rd_size   <= 2048;
    endcase
    O_config_data <= config_data;
    O_IF_schedule <= IF_schedule;
    end
end

assign rd_done = rd_count == rd_size;

always @(posedge clk_chip or negedge reset_n_chip) begin : proc_O_spi_cs_n_d_sync
  if(!reset_n_chip) begin
    {O_spi_cs_n_sync, O_spi_cs_n_2, O_spi_cs_n_1} <= 3'b111;
  end else begin //paulse
    {O_spi_cs_n_sync, O_spi_cs_n_2, O_spi_cs_n_1} <= {O_spi_cs_n_2, O_spi_cs_n_1, O_spi_cs_n};
  end
end

// ====================================================================================================================
// Async FIFO
// ====================================================================================================================
//assign reset_n_fifo = reset_n_chip && !(state == IDLE); // after config_data[31] exchanges clk

wire                            wr_clk;
wire                            wr_en ;
wire [ SPI_WIDTH      - 1 : 0 ] din   ;
wire                            rd_clk;
wire                            rd_en ;
wire [ SPI_WIDTH      - 1 : 0 ] dout  ;
wire                            empty ;
// wire                            full  ;
wire [ 28-`IFSCHEDULE_WIDTH -1 : 0] Zero = 0;
assign O_spi_data = {O_config_data,O_IF_schedule, Zero};

assign wr_clk = O_spi_sck  ;
assign wr_en  = !O_spi_cs_n;
assign din    = I_spi_data  ;
assign rd_clk = clk_chip   ;
assign rd_en  = !empty && rd_req     ;
assign rd_data= dout        ;

fifo_async_rd #(
  .data_width     ( SPI_WIDTH        ),
  .addr_width     ( ADDR_WIDTH_FIFO  )
  )fifo_async(
  .rst_n    ( reset_n_chip  ),
  .wr_clk   ( wr_clk        ),
  .wr_en    ( wr_en         ),
  .din      ( din           ),
  .rd_clk   ( rd_clk        ),
  .rd_en    ( rd_en         ),
  .valid    ( rd_paulse      ),
  .dout     ( dout          ),
  .empty    ( empty         ),
  .full     (           ),
  .full_level( full)

  );
assign rd_valid = rd_paulse && state[1];//state == 3 || 2
// ====================================================================================================================


endmodule
