module Checkdigit(
    // Input signals
    in_num,
	in_valid,
	rst_n,
	clk,
    // Output signals
    out_valid,
    out
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [3:0] in_num;
input in_valid, rst_n, clk;
output logic out_valid;
output logic [3:0] out;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic power;
logic [3:0] comb;
logic [3:0] num_add;
logic [4:0] sum;
logic [3:0] sum_m10_next;
logic [3:0] sum_m10;
logic [3:0] cnt;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
// counter
ripple_counter_4bits ripple_counter(.*, .on(in_valid));
// out_valid
assign out_valid = (cnt == 'd15);

always_comb begin: comb1

    // mul 2 combinational
    comb[0] = in_num > 'd4;
    comb[1] = comb[0] ^ in_num[0];
    comb[2] = (~comb[0] & ~in_num[2] & in_num[1]) | (comb[0] & in_num[1] & in_num[0]) | (comb[0] & ~in_num[0] & ~in_num[1]);
    //comb[2] = comb[0] ? (in_num[1] ~^ in_num[0]) : (~in_num[2] & in_num[1]);
    //comb[2] = (~comb[0] & ~in_num[2] & in_num[1]) | (comb[0] & in_num[1] & in_num[0] | comb[0] & ~in_num[1] & ~in_num[0]);
    //comb[2] = (~comb[0] & in_num[1]) | (comb[0] & (in_num[0] ~^ in_num[1]));
    comb[3] = (~comb[0] & in_num[2]) | (in_num[0] & in_num[3]);
   
    // mul 2
    power = ~cnt[0] & in_valid; // better: share with ripple_counter_4bits
    //power = ~cnt[0];

    num_add = power? comb : in_num;

    // add reg & new 
    sum = sum_m10 + num_add;
    // mod 10
    /*
    if(out_valid) sum_m10_next = 'd0;
    else if(sum > 'd9) sum_m10_next = sum - 'd10;
    else sum_m10_next = sum;
    */
    sum_m10_next = ((sum < 'd10)? sum : sum - 'd10) & ~{4{out_valid}};
    //sum_m10_next = ((sum > 'd9)? sum-'d10 : sum) & ~{4{out_valid}};
end

// current sum % 10 register
always_ff@(posedge clk or negedge rst_n) begin: current_sum_modulo
    if(!rst_n)
        sum_m10 <= 'd0;
    else
        sum_m10 <= sum_m10_next;
end

always_comb begin: comb2
    /*
    if(!out_valid) out = 'd0;
    else if(sum_m10 == 'd0) out = 'd15;
    else out = 'd10 - sum_m10;
    */
    //out = {4{out_valid}} & ({4{(sum_m10 == 'd0)}} | ('d10 - sum_m10));
    out = {4{out_valid}} & (~{4{(|sum_m10)}} | ('d10 - sum_m10));
end

endmodule

//---------------------------------------------------------------------
//   4 bits ripple counter                     
//---------------------------------------------------------------------

module ripple_counter_4bits(clk, rst_n, on, cnt);
// input output
input clk, rst_n, on;
output logic [3:0] cnt;
// logic
logic [3:0] cnt_next;

//sequential
always_ff @(posedge clk) begin: counter_ff_0
    cnt[0] <= cnt_next[0];
end
    
always_ff @(negedge cnt[0] or negedge rst_n) begin: counter_ff_1
    if(!rst_n)
        cnt[1] <= 0;
    else
        cnt[1] <= cnt_next[1];
end
    
always_ff @(negedge cnt[1] or negedge rst_n) begin: counter_ff_2
    if(!rst_n)
        cnt[2] <= 0;
    else
        cnt[2] <= cnt_next[2];
end

always_ff @(negedge cnt[2] or negedge rst_n) begin: counter_ff_3
    if(!rst_n)
        cnt[3] <= 0;
    else
        cnt[3] <= cnt_next[3];
end

//combinational
always_comb begin
    cnt_next[0] = ~cnt[0] & on;
    cnt_next[1] = ~cnt[1] & on;
    cnt_next[2] = ~cnt[2];
    cnt_next[3] = ~cnt[3];
end

endmodule