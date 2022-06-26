module Maxmin(clk, rst_n, in_num, in_valid, out_max, out_min, out_valid);
    input clk, rst_n, in_valid;
    input [7:0] in_num;
    output logic [7:0] out_max, out_min;
    output logic out_valid;

    logic [7:0] cmp_max, cmp_min;
    logic [3:0] cnt;
    logic [3:0] cnt_next;

    always_ff @(posedge clk or negedge rst_n) begin : Max_dff
        if(!rst_n)
            out_max <= 'd0;
        else
            out_max <= cmp_max;
    end

    always_ff @(posedge clk or negedge rst_n) begin : Min_dff
        if(!rst_n)
            out_min <= 'd255;
        else
            out_min <= cmp_min;
    end

    always_ff @(posedge clk or negedge rst_n) begin : Counter15
        if(!rst_n)
            cnt <= 'd15;
        else
            cnt <= cnt_next;
    end

    assign cmp_max = in_valid? (in_num > out_max? in_num:out_max) : 'd0; 
    assign cmp_min = in_valid? (in_num < out_min? in_num:out_min) : 'd255;
    assign cnt_next = in_valid? cnt - 'd1 : 'd15;
    assign out_valid = (cnt == 'd0);

endmodule