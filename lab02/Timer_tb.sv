`timescale 1ns/1ns

module Timer_tb ();
    reg clk, rst_n, in_valid;
    reg [4:0] in;
    wire out_valid;

    Timer T1(.*);

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, Timer_tb);
    end

    initial begin
        clk = 0;
        rst_n = 1;
        in_valid = 0;
        in = 5'd0;
    end

    initial begin
        #1
            rst_n = 0;
        #4
            rst_n = 1;
        // test 0
        #15
            in_valid = 1;
            in = 5'd10;
        #10
            in_valid = 0;
            in = 5'd0;
        #21
            rst_n = 0;
        #4
            rst_n = 1;
        #75
        // test 1
        #10
            in_valid = 1;
            in = 5'd6;
        #10
            in_valid = 0;
            in = 5'd0;
        #10
            in_valid = 1;
            in = 5'd3;
        #10 
            in_valid = 0;
            in = 5'd0;
        #50
        // test 2
            in_valid = 1;
            in = 5'd5;
        #10
            in_valid = 0;
            in = 5'd0;
        #400    
        // test 3
        #1
            rst_n = 0;
        #4
            rst_n = 1;
        #405
        $finish;
    end
    
    always begin
        #5
        clk = ~clk;
    end
endmodule