module SRAM_SINGAL(
    clk, 
    read_en, write_en, 
    addr, 
    data_in, data_out
    );
parameter SRAM_DEPTH_BIT = 10;
parameter SRAM_DEPTH = 2 ** SRAM_DEPTH_BIT;
parameter SRAM_WIDTH = 64;

input clk;
input read_en, write_en;

input [SRAM_DEPTH_BIT - 1 : 0]addr;
input [SRAM_WIDTH - 1 : 0]data_in;

output [SRAM_WIDTH - 1 : 0]data_out;

reg [SRAM_WIDTH - 1 : 0]mem[0 : SRAM_DEPTH - 1];
reg [SRAM_WIDTH - 1 : 0]data_out;
always @(posedge clk) begin
    if (read_en) begin
        data_out <= mem[addr];
    end
end

always @(posedge clk) begin
    if (write_en) begin
        mem[addr] <= data_in;
    end
end

endmodule
