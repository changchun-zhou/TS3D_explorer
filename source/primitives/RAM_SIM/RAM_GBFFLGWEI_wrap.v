module RAM_GBFFLGWEI_wrap #(
    parameter SRAM_DEPTH_BIT = 6,
    parameter SRAM_DEPTH = 2 ** SRAM_DEPTH_BIT,
    parameter SRAM_WIDTH = 28,
    parameter INIT_IF = "no",
    parameter INIT_FILE = ""
)(
    input clk,
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
// 144 bit width x 2
//
RAM_GBFFLGWEI RAM_GBFFLGWEI0(
    .A                   (  Addr               ),
    .DO                  (  data_out[SRAM_WIDTH/2 -1 : 0]            ),
    .DI                  (  data_in[SRAM_WIDTH/2 -1 : 0]             ),
    .DVSE                (  1'b0                ),
    .DVS                 (  4'b0                ),
    .WEB                 (  ~write_en           ),
    .CK                  (  clk                 ),
    .CSB                 ((~write_en)&(~read_en))
     );
RAM_GBFFLGWEI RAM_GBFFLGWEI1(
    .A                   (  Addr               ),
    .DO                  (  data_out[SRAM_WIDTH -1 : SRAM_WIDTH/2]            ),
    .DI                  (  data_in[SRAM_WIDTH -1 : SRAM_WIDTH/2]              ),
    .DVSE                (  1'b0                ),
    .DVS                 (  4'b0                ),
    .WEB                 (  ~write_en           ),
    .CK                  (  clk                 ),
    .CSB                 ((~write_en)&(~read_en))
     );

`endif

endmodule
