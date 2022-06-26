`timescale 1ns/1ps
//`include "PATTERN.sv"
//`include "MIPS.sv"

module TESTBED();
logic clk;
logic rst_n;
logic in_valid;
logic [3:0] in_number;
logic [1:0] mode;

logic out_valid;
logic [6:0] out_result;

initial begin
  //$fsdbDumpfile("MIPS.fsdb");
	//$fsdbDumpvars(0,"+mda");
end
initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, TESTBED);
end

Lab07 I_design(.*);
PATTERN I_PATTERN(.*);

endmodule

