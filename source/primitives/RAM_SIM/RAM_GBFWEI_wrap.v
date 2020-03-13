module RAM_GBFWEI_wrap #(
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

RAM_GBFWEI RAM_GBFWEI0(
    .A                   (  addr_w               ),
    .B                      ( addr_r   ),
    .DO                  (  data_out            ),
    .DI                  (  data_in             ),
    .CKA                (clk ),
    .CKB                  ( clk ),
    .DVSE                (  1'b0                ),
    .DVS                 (  4'b0                ),
    .WEB                 (  ~write_en           ),
    .CSAN               ( ~write_en ),
    .CSBN                 (~read_en)
     );
`endif

endmodule