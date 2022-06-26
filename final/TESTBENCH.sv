`timescale 1ns/1ps

module TESTBED();

logic clk, rst_n, in_valid;
logic [6:0] in_cost;
logic out_valid;
logic [3:0] out_job;
logic [9:0] out_cost;

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, TESTBED);
	for(int i=0; i<64; i=i+1) $dumpvars(0, TESTBED.I_DESIGN.array[i]);
	for(int i=0; i<64; i=i+1) $dumpvars(0, TESTBED.I_DESIGN.zero[i]);
	for(int i=0; i<8; i=i+1) $dumpvars(0, TESTBED.I_DESIGN.row_zero_cnt[i]);
	for(int i=0; i<8; i=i+1) $dumpvars(0, TESTBED.I_DESIGN.col_zero_cnt[i]);
	for(int i=0; i<8; i=i+1) $dumpvars(0, TESTBED.I_DESIGN.job[i]);
end

JAM I_DESIGN
(
	.clk		(clk),
	.rst_n		(rst_n),
	.in_valid	(in_valid),
	.in_cost	(in_cost),
	.out_valid	(out_valid),
	.out_job	(out_job),
	.out_cost	(out_cost)
);

PATTERN I_PATTERN
(
	.clk		(clk),
	.rst_n		(rst_n),
	.in_valid	(in_valid),
	.in_cost	(in_cost),
	.out_valid	(out_valid),
	.out_job	(out_job),
	.out_cost	(out_cost)
);

endmodule