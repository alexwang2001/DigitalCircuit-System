`timescale 1ns/1ps

module sorting_tb();
    reg [4:0] val [5:0];
    reg [4:0] opcode;
    wire [8:0]out_n;

    CN cn1(opcode, val[0], val[1], val[2], val[3], val[4], val[5], out_n);

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, sorting_tb);
    end

    initial begin
        opcode = 5'b10001;
        val[0] = 1;
        val[1] = 2;
        val[2] = 3;
        val[3] = 4;
        val[4] = 5;
        val[5] = 6;
        #10
        val[0] = 13;
        val[1] = 8;
        val[2] = 9;
        val[3] = 0;
        val[4] = 9;
        val[5] = 12;
        #10
        val[0] = 5'h9;
        val[1] = 5'h6;
        val[2] = 5'h10;
        val[3] = 5'h3;
        val[4] = 5'h14;
        val[5] = 5'h10;
        #10
        opcode = 5'b10110;
        val[0] = 5'h8;
        val[1] = 5'h15;
        val[2] = 5'h3;
        val[3] = 5'h14;
        val[4] = 5'h13;
        val[5] = 5'h5;
        #10
        $finish;
    end

endmodule