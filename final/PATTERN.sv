`timescale 1ns/1ps

module PATTERN(
  // Input signals
	clk,
	rst_n,
    in_valid,
    in_cost,
  // Output signals
	out_valid,
    out_job,
	out_cost
);
//================================================================
// wire & registers 
//================================================================
output logic clk, rst_n, in_valid;
output logic [6:0] in_cost;
input out_valid;
input [3:0] out_job;
input [9:0] out_cost;

logic [6:0] golden_in [63:0];
logic [3:0] golden_job [7:0];
logic [9:0] golden_cost;
//================================================================
// param
//================================================================
shortreal CYCLE = 5.0;
int inf, outf;
int patnum;
int delay_cnt;
int x;
int total_cycles = 0;

//================================================================
// clock
//================================================================
initial begin	
	clk = 0;
  	@(posedge rst_n)
  	forever begin
		#(CYCLE*0.5)
		clk = ~clk;
	end
end

//================================================================
// initial
//================================================================
initial begin
	// file
	inf = $fopen("input.txt","r");
	outf = $fopen("output.txt","r");
	// init
	in_valid = 0;
	in_cost = 'x;
	// start
	reset();
	repeat(3) @(posedge clk);
	//check_reset();
	for(int j=0; j<64; j=j+1) begin
		x = $fscanf(inf, "%d", golden_in[j]);
	end
	for(int j=0; j<8; j=j+1) begin
		x = $fscanf(outf, "%d", golden_job[j]);
	end
	x = $fscanf(outf, "%d", golden_cost);
	for(int j=0; j<64; j=j+1) begin
		@(negedge clk)
		in_valid = 1;
		in_cost = golden_in[j];
	end
	@(negedge clk);
	in_valid = 0;
	in_cost = 'x;
	@(negedge clk);
	repeat(200) @(posedge clk);
	$finish();
end

initial begin
  @(posedge clk);
  total_cycles = 0;
  forever @(posedge clk) total_cycles = total_cycles + 1;
end

//================================================================
// task
//================================================================

task reset();
  rst_n = 1;
  #1
  rst_n = 0;
  #(CYCLE*3-1)
  rst_n = 1;
endtask

endmodule