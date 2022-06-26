
`timescale 1ns/1ps

module TESTBED();
logic clk, rst_n, image_valid, filter_valid;
logic [3:0] in_data;
logic [15:0] out_data;
logic out_valid;

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, TESTBED);
end


Conv I_design(.*);

PATTERN I_PATTERN(.*);

endmodule


