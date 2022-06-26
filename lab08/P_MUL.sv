module P_MUL(clk, rst_n, in_1, in_2, in_3, in_valid, out_valid, out);
// input & output
//----------------------------
input [46:0] in_1, in_2;
input [47:0] in_3;
input in_valid;
input clk, rst_n;
output logic out_valid;
output logic [95:0] out;

// logic declaration
//----------------------------

// code
//----------------------------
//pip0
//-------------------------------------------------------------
logic [46:0] in_1_pip0, in_2_pip0;
logic [47:0] in_3_pip0;
logic in_valid_pip0;
logic [47:0] sum_pip0;

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		in_1_pip0 <= 0;
		in_2_pip0 <= 0;
		in_3_pip0 <= 0;
		in_valid_pip0 <= 0;
	end
	else begin
		in_1_pip0 <= in_1;
		in_2_pip0 <= in_2;
		in_3_pip0 <= in_3;
		in_valid_pip0 <= in_valid;
	end
end

always_comb begin
	sum_pip0 = in_1_pip0 + in_2_pip0;
end

//pip1
//-------------------------------------------------------------
logic [47:0] num1_pip1, num2_pip1;
logic in_valid_pip1;
logic [11:0] a1, a2, b1, b2, c1, c2, d1, d2;
logic [95:0] A, B, C, D, E, F, G;

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		num1_pip1 <= 0;
		num2_pip1 <= 0;
		in_valid_pip1 <= 0;
	end
	else begin
		num1_pip1 <= sum_pip0;
		num2_pip1 <= in_3_pip0;
		in_valid_pip1 <= in_valid_pip0;
	end
end

always_comb begin
	{a1,b1,c1,d1} = num1_pip1;
	{a2,b2,c2,d2} = num2_pip1;
	A = (a1*a2)<<72 | (b1*b2)<<48 | (c1*c2)<<24 | d1*d2;
	B = (a1*b2)<<48 | (b1*c2)<<24 | (c1*d2);
	C = (a2*b1)<<48 | (b2*c1)<<24 | (c2*d1);
	D = (a2*c1)<<24 | (b2*d1);
	E = (a1*c2)<<24 | (b1*d2);
	F = a2*d1;
	G = a1*d2;
end

//pip2
//-------------------------------------------------------------
logic in_valid_pip2;
logic [95:0] A_pip2, B_pip2, C_pip2, D_pip2, E_pip2, F_pip2, G_pip2;
logic [95:0] s0, s1, s2;

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		A_pip2 <= 0;
		B_pip2 <= 0;
		C_pip2 <= 0;
		D_pip2 <= 0;
		E_pip2 <= 0;
		F_pip2 <= 0;
		G_pip2 <= 0;
		in_valid_pip2 <= 0;
	end
	else begin
		A_pip2 <= A;
		B_pip2 <= B;
		C_pip2 <= C;
		D_pip2 <= D;
		E_pip2 <= E;
		F_pip2 <= F;
		G_pip2 <= G;
		in_valid_pip2 <= in_valid_pip1;
	end
end

always_comb begin
	s0 = A_pip2;
	s1 = B_pip2 + C_pip2;
	s2 = D_pip2 + E_pip2 + ((F_pip2 + G_pip2)<<12);
end

//pip3
//-------------------------------------------------------------
logic in_valid_pip3;
logic [95:0] s0_pip3, s1_pip3, s2_pip3;
logic [95:0] S;

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		s0_pip3 <= 0;
		s1_pip3 <= 0;
		s2_pip3 <= 0;
		in_valid_pip3 <= 0;
	end
	else begin
		s0_pip3 <= s0;
		s1_pip3 <= s1;
		s2_pip3 <= s2;
		in_valid_pip3 <= in_valid_pip2;
	end
end

always_comb begin
	S = s0_pip3 + (s1_pip3<<12) + (s2_pip3<<24);
end

//pip4
//-------------------------------------------------------------
logic [95:0] out_pre;
always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		out_pre <= 0;
		out_valid <= 0;
	end
	else begin
		out_pre <= S;
		out_valid <= in_valid_pip3;
	end
end

always_comb begin
	out = out_pre & {96{out_valid}};
end
endmodule