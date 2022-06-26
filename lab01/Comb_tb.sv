`timescale 1ns/1ns

module Comb_tb ();
    reg [3:0] in_num0, in_num1, in_num2, in_num3;
	wire [4:0] out_num0, out_num1;

    Comb m1(in_num0, in_num1, in_num2, in_num3, out_num0, out_num1);

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, Comb_tb);
    end

    initial begin
        {in_num0, in_num1, in_num2, in_num3} = {4'd2,4'd4,4'd7,4'd3};
        #5
        {in_num0, in_num1, in_num2, in_num3} = {4'd2,4'd5,4'd11,4'd4};
        #5
        {in_num0, in_num1, in_num2, in_num3} = {4'd1,4'd8,4'd4,4'd12};
        #5
        {in_num0, in_num1, in_num2, in_num3} = {4'd7,4'd4,4'd4,4'd0};
        #5
        {in_num0, in_num1, in_num2, in_num3} = {4'd7,4'd10,4'd11,4'd15};
        #5
        {in_num0, in_num1, in_num2, in_num3} = {4'd9,4'd3,4'd5,4'd12};
        #5
        {in_num0, in_num1, in_num2, in_num3} = {4'd14,4'd9,4'd11,4'd6};
        #5
        {in_num0, in_num1, in_num2, in_num3} = {4'd7,4'd4,4'd3,4'd6};
        #5
        {in_num0, in_num1, in_num2, in_num3} = {4'd3,4'd9,4'd3,4'd11};
        #5
        {in_num0, in_num1, in_num2, in_num3} = {4'd10,4'd5,4'd11,4'd11};
        #5
        $finish;
    end
    
endmodule