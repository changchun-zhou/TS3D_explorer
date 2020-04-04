module RAM_FRMPOOL_wrap #(
    parameter SRAM_DEPTH_BIT = 6,
    parameter SRAM_DEPTH = 2 ** SRAM_DEPTH_BIT,
    parameter SRAM_WIDTH = 28,
    parameter INIT_IF = "no",
    parameter INIT_FILE = ""
)(
    input clk,
    input rst_n,
    input [SRAM_DEPTH_BIT - 1 : 0]addr_r, addr_w,
    input read_en, write_en,
    input[SRAM_WIDTH  - 1 : 0]data_in,
    output  [SRAM_WIDTH  - 1 : 0]data_out
);


// ******************************************************************
// INSTANTIATIONS
// ******************************************************************
`ifdef SYNTH_MINI
reg [SRAM_WIDTH  - 1 : 0]mem[0 : SRAM_DEPTH - 1];
reg [SRAM_WIDTH  - 1 : 0]data_out_reg;
initial begin
  if (INIT_IF == "yes") begin
    $readmemh(INIT_FILE, mem, 0, SRAM_DEPTH-1);
  end
end

always @(posedge clk) begin
    if (read_en) begin
        data_out_reg <= mem[addr_r];
    end
end
assign data_out = data_out_reg;

always @(posedge clk) begin
    if (write_en) begin
        mem[addr_w] <= data_in;
    end
end

`else

wire                        [SRAM_DEPTH_BIT - 1 : 0] Addr;
assign Addr = write_en ? addr_w : addr_r;

// ******************* Delay for sim ********************************************
wire [ SRAM_DEPTH_BIT          -1 : 0] A;
wire [ SRAM_WIDTH              -1 : 0] DI;
wire [ 16                      -1 : 0] WEB;
wire                                   CSB;
// delay 1/2 clock period
`ifdef DELAY_SRAM
    assign #(`CLOCK_PERIOD_ASIC/2) A = Addr;
    assign #(`CLOCK_PERIOD_ASIC/2) DI = data_in[SRAM_WIDTH -1 : 0];
    assign #(`CLOCK_PERIOD_ASIC/2) WEB= ~write_en ? ~(16'd0) : 16'd0;
    assign #(`CLOCK_PERIOD_ASIC/2) CSB = (~write_en)&(~read_en);
`else
    assign  A = Addr;
    assign  DI = data_in[SRAM_WIDTH -1 : 0];
    assign  WEB= ~write_en ? ~(16'd0) : 16'd0;
    assign  CSB = (~write_en)&(~read_en);
`endif
wire [ SRAM_WIDTH              -1 : 0] DO;
wire                                   read_en_d;
reg  [ SRAM_WIDTH              -1 : 0] DO_d;
assign data_out = read_en_d? DO : DO_d;
Delay #(
    .NUM_STAGES(1),
    .DATA_WIDTH(1)
) Delay_read_en_d (
    .CLK     (clk),
    .RESET_N (rst_n),
    .DIN     (read_en),
    .DOUT    (read_en_d)
);
always @ ( posedge clk) begin
    if( read_en_d)
        DO_d <= DO;
end
// ******************************************************************************

SYLA55_49X8X16CM2 RAM_FRMPOOL0(
    .A                   (  A               ),
    .DO                  (  DO            ),
    .DI                  (  DI             ),
    .DVSE                (  1'b0                ),
    .DVS                 (  4'b0                ),
    .WEB                 (  WEB           ),
    .CK                  (  clk                 ),
    .CSB                 (CSB)
     );
`endif

endmodule
