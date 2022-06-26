`timescale 1ns/10ps
`define CYCLE_TIME 5.0

module PATTERN(
    //OUTPUT 
    clk,
    rst_n,
    in_valid,
    instruction,
	output_reg,
    //inPUT
    out_valid,
    out_1,
	out_2,
	out_3,
	out_4,
	instruction_fail
);
//================================================================
// wire & registers 
//================================================================
output logic clk;
output logic rst_n;
output logic in_valid;
output logic [31:0] instruction;
output logic [19:0] output_reg;

input out_valid, instruction_fail;
input [31:0] out_1, out_2, out_3, out_4;

// golden
logic [2:0] golden_coin_out_1;
logic golden_coin_out_5;   
logic golden_coin_out_10;   
logic [1:0] golden_coin_out_20;
logic [3:0] golden_coin_out_50;
logic [1:0] golden_item_0_led, golden_item_1_led, golden_item_2_led, golden_item_3_led, golden_item_4_led, golden_item_5_led, golden_item_6_led;
logic [2:0] golden_item_out;
int in_coinside,in_coinside_temp;
logic [4:0] items_price[5:0];
int golden_out_sell_num[5:0]; 

//================================================================
// parameters & integer
//================================================================
integer PATNUM;
integer i,k,cnt;
integer patcount;
integer lat;
integer CYCLE = `CYCLE_TIME; 

always	#(CYCLE/2.0) clk = ~clk;


int sel;
logic [31:0] ins, out1_golden, out2_golden, out3_golden, out4_golden;
logic golden_fail;

int total_latency; 

integer input_file,output_file,w1_file,w2_file;
integer count;
//integer check_count;
//================================================================
// initial
//================================================================
initial begin
	input_file=$fopen("input.txt","r");
    output_file=$fopen("output.txt","r");

	k = $fscanf(input_file,"%d\n",PATNUM);
    rst_n = 1'b1;
    in_valid = 0;

    total_latency = 0;
	cnt = 0;
	count = 0;
    force clk = 0;
	reset_task;
	for(patcount = 0 ; patcount < PATNUM+10 ; patcount = patcount + 1) begin
		@(negedge clk);
		if(patcount<PATNUM)begin
			in_valid = 1;
			k = $fscanf(input_file,"%b",instruction);
			k = $fscanf(input_file,"%b",output_reg);
		end
		else begin
			in_valid = 0;
			instruction = 0;
			output_reg = 0;
		end
		check_ans;
		
		total_latency=total_latency+1;
		if(cnt==10)begin
			fail;
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$display ("                                                     The execution latency are over 10   cycles                                             ");
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$finish;
		end
		if(in_valid===1&&out_valid!==1)
			cnt = cnt + 1;
		if(count == PATNUM);
			patcount = PATNUM+10;
	end
	@(negedge clk);
	if( (out_valid !==0) || ( out_1 !== 0 )|| ( out_2 !== 0 ) || ( out_3 !== 0 ) || ( out_4 !== 0 ) || ( instruction_fail !== 0 ))
      begin
		fail;
        $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                              Fail!  Valid and output should be zero                                               ");
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
	    $finish ;
	  end 
	repeat(2)@(negedge clk);
    YOU_PASS_task;
	$finish;
end
//================================================================
// task
//================================================================


task reset_task ; begin
  #( 0.5 ); rst_n = 0;

	#(20.0);

if( (out_valid !==0) || ( out_1 !== 0 )|| ( out_2 !== 0 ) || ( out_3 !== 0 ) || ( out_4 !== 0 ) || ( instruction_fail !== 0 ))
      begin
		fail;
        $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                              Fail!  Valid and output should be zero after rst                                              ");
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
	    $finish ;
	  end 
	
	#(10) rst_n = 1 ;
    #(3) release clk;
end endtask

task check_ans ; begin
	if(out_valid===1)begin
		k = $fscanf(output_file,"%b",golden_fail);
		k = $fscanf(output_file,"%d",out1_golden);
		k = $fscanf(output_file,"%d",out2_golden);
		k = $fscanf(output_file,"%d",out3_golden);
		k = $fscanf(output_file,"%d",out4_golden);
		if(instruction_fail !== golden_fail || out_1 !== out1_golden || out_2 !== out2_golden || out_3 !== out3_golden || out_4 !== out4_golden)begin
			fail;
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$display ("                                                     WRONG ANSWER FAIL!                                                              ");
			$display ("                                                          Pattern No. %3d                                                          ",count);
			$display ("                                          instruction_fail:%b       golden answer:%b", instruction_fail, golden_fail);
			$display ("                                          out_1:%d                  golden answer:%d", out_1, out1_golden);
			$display ("                                          out_2:%d                  golden answer:%d", out_2, out2_golden);
			$display ("                                          out_3:%d                  golden answer:%d", out_3, out3_golden);
			$display ("                                          out_4:%d                  golden answer:%d", out_4, out4_golden);
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$finish ;
		end
		count = count + 1;
	end
end endtask


 
task YOU_PASS_task;begin                   
$display ("----------------------------------------------------------------------------------------------------------------------");
$display ("                                                  Congratulations!                						             ");
$display ("                                           You have passed all patterns!          						             ");
$display ("                                                     Your total cycle:%d !                                                          ",total_latency);
$display ("                                                     Your total latency:%d NS!                                                          ",total_latency* CYCLE);
$display ("----------------------------------------------------------------------------------------------------------------------");

$finish;	
end endtask


task fail; begin
$display("fail");
end endtask


endmodule


