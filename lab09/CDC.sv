
module CDC (clk1, clk2, rst_n, in_a, in_b, in_valid, mode, out_valid, out);
// input
//--------------------------------------------------------------
input clk1, clk2, rst_n;
input [3:0] in_a, in_b;
input in_valid;
input mode;
// output    
//--------------------------------------------------------------
output logic [7:0] out;
output logic out_valid;
// logic
//--------------------------------------------------------------
logic P_next;
logic P;
logic Q_reg;
logic Q;
logic CDC_res;
logic [3:0] in_a_reg, in_b_reg;
logic [3:0] in_a_reg_next, in_b_reg_next;
logic mode_reg;
// FSM
//--------------------------------------------------------------
logic [1:0] state;
logic [1:0] state_next;
parameter S_idle = 0;
parameter S_compute = 1;
parameter S_out = 2;

always_comb begin
	casez(state)
		0: state_next = CDC_res? S_compute : S_idle;
		1: state_next = S_out;
		2: state_next = S_idle;
		default: state_next = 'x;
	endcase
end

always_ff @(posedge clk2 or negedge rst_n) begin
	if(!rst_n)
		state <= S_idle;
	else 
		state <= state_next;
end

// design
//--------------------------------------------------------------
// input reg
always_comb begin
	in_a_reg_next = in_valid ? in_a : 0;
	in_b_reg_next = in_valid ? in_b : 0;
end

always_ff @(posedge clk1 or negedge rst_n) begin
	if(!rst_n) begin
		in_a_reg <= 0;
		in_b_reg <= 0;
		mode_reg <= 0;
	end
	else begin 
		in_a_reg <= in_a_reg_next;
		in_b_reg <= in_b_reg_next;
		mode_reg <= mode;
	end
end

// synchronizer
assign P_next = in_valid ^ P;

always_ff @(posedge clk1 or negedge rst_n) begin
	if(!rst_n) begin
		P <= 0;
	end
	else begin 
		P <= P_next;
	end
end

synchronizer syn0(.clk(clk2), .rst_n(rst_n), .D(P), .Q(Q));

always_ff @(posedge clk2 or negedge rst_n) begin
	if(!rst_n) begin
		Q_reg <= 0;
	end
	else begin 
		Q_reg <= Q;
	end
end

assign CDC_res = Q ^ Q_reg;

// ALU
logic compute_ena;
logic [7:0] out_next;

assign compute_ena = (state == S_compute);

ALU alu0(.a(in_a_reg),.b(in_b_reg),.mode(mode_reg),.ena(compute_ena),.out(out_next));

always_ff @(posedge clk2 or negedge rst_n) begin
	if(!rst_n)
		out <= 0;
	else
		out <= out_next;
end

assign out_valid = (state == S_out);

endmodule

module ALU(a, b, mode, ena, out);
input [3:0] a, b;
input mode, ena;
output logic [7:0] out;
logic [7:0] out_pre;
always_comb begin
	casez(mode)
		0: out_pre = a + b;
		1: out_pre = a * b;
	endcase
	out = ena ? out_pre : 0;
end
endmodule