`timescale 1ps/1ps

module sorting_tb();
    reg [4:0] val [5:0];
    wire [4:0] sort_out [5:0];

    sorting st1(val, sort_out);

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, sort_out[0]);
        $dumpvars(0, sort_out[1]);
        $dumpvars(0, sort_out[2]);
        $dumpvars(0, sort_out[3]);
        $dumpvars(0, sort_out[4]);
        $dumpvars(0, sort_out[5]);
    end

    initial begin
        val[0] = 1;
        val[1] = 2;
        val[2] = 3;
        val[3] = 4;
        val[4] = 5;
        val[5] = 6;
        #10
        val[0] = 1;
        val[1] = 3;
        val[2] = 5;
        val[3] = 6;
        val[4] = 2;
        val[5] = 4;
        #10
        val[0] = 2;
        val[1] = 4;
        val[2] = 6;
        val[3] = 5;
        val[4] = 1;
        val[5] = 3;
        #10
        val[0] = 6;
        val[1] = 5;
        val[2] = 4;
        val[3] = 3;
        val[4] = 2;
        val[5] = 1;
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