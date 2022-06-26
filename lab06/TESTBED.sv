`timescale 1ns/1ps


module TESTBED();
    //input
    logic clk;
    logic rst_n;
    logic in_valid;
    logic mode;
    logic [15:0] in_a, in_b;
    //output
    logic out_valid;
    logic [15:0] out;
    // param
    parameter cycle = 20;

    Fpc U1(.*);

    initial begin
		$dumpfile("wave.vcd");
		$dumpvars(0,TESTBED);
    end

    initial begin
        in_a = 'x;
        in_b = 'x;
        in_valid = 0;
        mode  = 'x;
    end

    initial begin
        #40
        in_a = 'b1_01111011_1001100;
        in_b = 'b0_01111101_0100000;
        in_valid = 1;
        mode = 1;
        #20
        in_a = 'x;
        in_b = 'x;
        in_valid = 0;
        mode  = 'x;
        #100
        $finish;
    end

    initial begin
        clk = 0;
        forever begin
            #(cycle/2.0)
            clk = ~clk;
        end
    end
    
    task reset_70();
        rst_n = 1;
        #1
        rst_n = 0;
        #2
        rst_n = 1;
    endtask
    

endmodule