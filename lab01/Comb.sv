module Comb(in_num0, in_num1, in_num2, in_num3, out_num0, out_num1);
	input wire [3:0] in_num0, in_num1, in_num2, in_num3;
	output wire [4:0] out_num0, out_num1;

    logic [3:0] w1, w2, w3, w4;
	logic [4:0] add1, add2;

	always @(*) begin
        w1 = ~(in_num0 ^ in_num1);
        w2 = in_num1 | in_num3;
        w3 = in_num0 & in_num2;
        w4 = in_num2 ^ in_num3;
        add1 = w1 + w2;
        add2 = w3 + w4;
    end

    assign {out_num0, out_num1} = add1 > add2 ? {add2,add1} : {add1,add2};

endmodule
