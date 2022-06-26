`timescale 1ns/1ps
//`include "Lab07.sv"

module PATTERN(
    //output
    clk,
    rst_n,
    in_number,
    mode,
	in_valid,
    //input
    out_valid,
    out_result
);
output logic clk;
output logic rst_n;
output logic in_valid;
output logic signed [3:0] in_number;
output logic [1:0] mode;

input out_valid;
input [6:0] out_result;

// golden
logic signed [6:0] golden_out_result;

// param
int patnum = 10;
int seed = 904;
int fail = 0;
logic signed [3:0] data [3:0];
logic signed [3:0] temp;

initial begin
	clk = 0;
	rst_n = 1;
	in_valid = 0;
	in_number = 'x;
	mode = 'x;
end

initial begin
	#15
	forever #5 clk = ~clk;
end

initial begin
    reset();
	repeat(3) @(negedge clk);
	$display("start");
	for(int i=0; i<patnum; i=i+1) begin
		data[0] = $random(seed)%8;
		data[1] = $random(seed)%8;
		data[2] = $random(seed)%8;
		data[3] = $random(seed)%8;
		@(negedge clk)
		mode = $urandom(seed)%4;
		in_valid = 1;
		in_number = data[0];
		@(negedge clk)
		in_number = data[1];
		@(negedge clk)
		in_number = data[2];
		@(negedge clk)
		in_number = data[3];
		for(int j=0; j<4; j=j+1)
			for(int k=j+1; k<4; k=k+1) begin
				if(data[j] > data[k]) begin
					temp = data[j];
					data[j] = data[k];
					data[k] = temp;
				end
			end
		case(mode)
			0:	golden_out_result = data[0] + data[1];
			1:	golden_out_result = data[1] - data[0];
			2:	golden_out_result = data[3] - data[2];
			3:	golden_out_result = data[0] - data[3];
		endcase
		@(negedge clk)
		in_valid = 0;
		for(int j=1; j<=101; j=j+1)begin
			@(negedge clk)
			if(j == 101) disp4();
			check_ans();
			if(out_valid === 1) j = 102;
		end
		@(negedge clk) 
		if(out_valid !== 0) disp2();
		$display("pass pattern %d", i);
	end
	pass();
	$finish;
end

always begin
	@(negedge clk)
	if(in_valid === 1 && out_valid === 1)
		disp3();
end

task reset();
$display("Reset");
#1 rst_n = 0;
#4
if((out_valid !== 0) || ( out_result !== 0 ))
	disp1();
#10 rst_n = 1;
$display("Reset end");
endtask

task check_ans();
	if(out_valid===1)begin
		if(out_result !== golden_out_result)
			disp5();
	end
endtask

task disp1();
	$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
	$display ("                                                             SPEC1!");
	$display ("                                                             Reset");
	$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
	#20 $finish;
endtask

task disp2();
	$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
	$display ("                                                             SPEC2!");
	$display ("                                                         Output should be 0");
	$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
	#20 $finish;
endtask

task disp3();
	$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
	$display ("                                                             SPEC3!");
	$display ("                                                                                                                                 ");
	$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
	#20 $finish;
endtask

task disp4();
	$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
	$display ("                                                             SPEC4!");
	$display ("                                                                                                                                            ");
	$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
	#20 $finish;
endtask

task disp5();
	$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
	$display ("                                                             SPEC5!");
	$display ("                                                             YOUR: %d", out_result);
	$display ("                                                             GOLDEN: %d", golden_out_result);
	$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
	#20 $finish;
endtask


task pass();
	$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
	$display ("                                                             PASS!");
	$display ("                                                                                                                                            ");
	$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
	#20 $finish;
endtask

endmodule


