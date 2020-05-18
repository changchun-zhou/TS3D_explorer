`include "../source/include/dw_params_presim.vh"
module clk_rst_driver (
    output reg      clk,
    output reg      reset_n,
    output wire     reset
);

always #(`CLOCK_PERIOD_FPGA/2.0) clk = !clk;
assign reset = !reset_n;

initial begin
    clk = 0;
    reset_n = 1;
    @(negedge clk);
    @(negedge clk);
        reset_n = 0;
        @(negedge clk);
    @(negedge clk);
    reset_n = 1;
end

endmodule
