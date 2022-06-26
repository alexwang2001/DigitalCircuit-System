module Conv(
  // Input signals
  clk,
  rst_n,
  image_valid,
  filter_valid,
  in_data,
  // Output signals
  out_valid,
  out_data
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, image_valid, filter_valid;
input signed [3:0] in_data;
output logic signed [15:0] out_data;
output logic out_valid;
//---------------------------------------------------------------------
//   Your design                       
//---------------------------------------------------------------------
// filter weight
//---------------------------------------------------------------------
logic signed [3:0] filter_reg_next [9:0];
logic signed [3:0] filter_reg [9:0];

always_comb begin
	filter_reg_next[9] = filter_valid ? in_data : filter_reg[9];
	for(int i=0; i<9; i=i+1) filter_reg_next[i] = filter_valid ? filter_reg[i+1] : filter_reg[i];
end

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		for(int i=0; i<10; i=i+1) filter_reg[i] <= '1;
	else
		for(int i=0; i<10; i=i+1) filter_reg[i] <= filter_reg_next[i];
end

// control
//---------------------------------------------------------------------
// counter 128
//---------------------------------------------------------------------
logic [6:0] cnt;
logic [6:0] cnt_next;
parameter S_begin = 122;
parameter S_stop = 65;

always_comb begin
	if(filter_valid)
		cnt_next = S_begin;
	else if(cnt == S_stop)
		cnt_next = S_stop;
	else
		cnt_next = cnt + 1;
end

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cnt <= S_stop;
	else
		cnt <= cnt_next;
end

// main
//---------------------------------------------------------------------
// in data register
//---------------------------------------------------------------------
logic signed [3:0] in_data_reg_pre;
logic signed [3:0] in_data_reg;

assign in_data_reg_pre = image_valid ? in_data : '1;

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		in_data_reg <= '1;
	else
		in_data_reg <= in_data_reg_pre;
end

// conv x
//---------------------------------------------------------------------
logic signed [7:0] Ax_mul, Bx_mul, Cx_mul, Dx_mul, Ex_mul;
logic signed [7:0] Ax_mul_reg, Bx_mul_reg, Cx_mul_reg, Dx_mul_reg, Ex_mul_reg;
logic signed [7:0] Ax_reg_next;
logic signed [8:0] Bx_reg_next, Cx_reg_next;
logic signed [9:0] Dx_reg_next, Ex_reg_next;
logic signed [7:0] Ax_reg;
logic signed [8:0] Bx_reg, Cx_reg;
logic signed [9:0] Dx_reg, Ex_reg;
logic signed [9:0] convx_out;
// booth mul x
logic [5:0] booth0x [4:0], booth1x [4:0];
logic signed [5:0] booth0x_reg [4:0], booth1x_reg [4:0];

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(int i=0; i<5; i=i+1) booth0x_reg[i] <= '1;
		for(int i=0; i<5; i=i+1) booth1x_reg[i] <= '1;
	end
	else begin
		for(int i=0; i<5; i=i+1) booth0x_reg[i] <= booth0x[i];
		for(int i=0; i<5; i=i+1) booth1x_reg[i] <= booth1x[i];
	end
end

always_comb begin
	MUL4(in_data_reg,filter_reg[0],booth0x[0],booth1x[0]);
	MUL4(in_data_reg,filter_reg[1],booth0x[1],booth1x[1]);
	MUL4(in_data_reg,filter_reg[2],booth0x[2],booth1x[2]);
	MUL4(in_data_reg,filter_reg[3],booth0x[3],booth1x[3]);
	MUL4(in_data_reg,filter_reg[4],booth0x[4],booth1x[4]);
	Ax_mul = booth0x_reg[0] + (booth1x_reg[0] << 2);
	Bx_mul = booth0x_reg[1] + (booth1x_reg[1] << 2);
	Cx_mul = booth0x_reg[2] + (booth1x_reg[2] << 2);
	Dx_mul = booth0x_reg[3] + (booth1x_reg[3] << 2);
	Ex_mul = booth0x_reg[4] + (booth1x_reg[4] << 2);
	Ax_reg_next = Ax_mul_reg;
	Bx_reg_next = Bx_mul_reg + Ax_reg;
	Cx_reg_next = Cx_mul_reg + Bx_reg;
	Dx_reg_next = Dx_mul_reg + Cx_reg;
	Ex_reg_next = Ex_mul_reg + Dx_reg;
end

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		Ax_mul_reg <= '1;
		Bx_mul_reg <= '1;
		Cx_mul_reg <= '1;
		Dx_mul_reg <= '1;
		Ex_mul_reg <= '1;
		Ax_reg <= '1;
		Bx_reg <= '1;
		Cx_reg <= '1;
		Dx_reg <= '1;
		Ex_reg <= '1;
	end
	else begin
		Ax_mul_reg <= Ax_mul;
		Bx_mul_reg <= Bx_mul;
		Cx_mul_reg <= Cx_mul;
		Dx_mul_reg <= Dx_mul;
		Ex_mul_reg <= Ex_mul;
		Ax_reg <= Ax_reg_next;
		Bx_reg <= Bx_reg_next;
		Cx_reg <= Cx_reg_next;
		Dx_reg <= Dx_reg_next;
		Ex_reg <= Ex_reg_next;
	end
end

assign convx_out = Ex_reg;

// conv y
//---------------------------------------------------------------------
logic signed [12:0] Ay_mul, By_mul, Cy_mul, Dy_mul, Ey_mul;
logic signed [12:0] Ay_mul_reg, By_mul_reg, Cy_mul_reg, Dy_mul_reg, Ey_mul_reg;
logic signed [14:0] Ay_add, By_add, Cy_add, Dy_add, Ey_add;
logic signed [14:0] Ay_reg_next[3:0], By_reg_next[3:0], Cy_reg_next[3:0], Dy_reg_next[3:0];
logic signed [14:0] Ay_reg[3:0], By_reg[3:0], Cy_reg[3:0], Dy_reg[3:0];
logic signed [14:0] convy_out;
logic signed [14:0] reg_temp;
logic signed [14:0] reg_temp_next;
logic [10:0] booth0y [4:0];
logic [10:0] booth1y [4:0];
logic signed [10:0] booth0y_reg [4:0];
logic signed [10:0] booth1y_reg [4:0];

// booth mul y
always_comb begin
	MUL10(convx_out,filter_reg[5],booth0y[0],booth1y[0]);
	MUL10(convx_out,filter_reg[6],booth0y[1],booth1y[1]);
	MUL10(convx_out,filter_reg[7],booth0y[2],booth1y[2]);
	MUL10(convx_out,filter_reg[8],booth0y[3],booth1y[3]);
	MUL10(convx_out,filter_reg[9],booth0y[4],booth1y[4]);
	Ay_mul = booth0y_reg[0] + (booth1y_reg[0] << 2);
	By_mul = booth0y_reg[1] + (booth1y_reg[1] << 2);
	Cy_mul = booth0y_reg[2] + (booth1y_reg[2] << 2);
	Dy_mul = booth0y_reg[3] + (booth1y_reg[3] << 2);
	Ey_mul = booth0y_reg[4] + (booth1y_reg[4] << 2);
end

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(int i=0; i<5; i=i+1) booth0y_reg[i] <= '1;
		for(int i=0; i<5; i=i+1) booth1y_reg[i] <= '1;
	end
	else begin
		for(int i=0; i<5; i=i+1) booth0y_reg[i] <= booth0y[i];
		for(int i=0; i<5; i=i+1) booth1y_reg[i] <= booth1y[i];
	end
end

always_comb begin
	Ay_add = Ay_mul_reg;
	By_add = By_mul_reg + Ay_reg[0];
	Cy_add = Cy_mul_reg + By_reg[0];
	Dy_add = Dy_mul_reg + Cy_reg[0];
	Ey_add = Ey_mul_reg + Dy_reg[0];
	Ay_reg_next[3] = cnt[2] ? ((cnt >= 35)? convy_out : Ay_add) : Ay_reg[3];
	Ay_reg_next[2] = cnt[2] ? Ay_reg[3] : Ay_reg[2];
	Ay_reg_next[1] = cnt[2] ? Ay_reg[2] : Ay_reg[1];
	Ay_reg_next[0] = cnt[2] ? Ay_reg[1] : Ay_reg[0];
	By_reg_next[3] = cnt[2] ? By_add : By_reg[3];
	By_reg_next[2] = cnt[2] ? ((cnt >= 45)? reg_temp : By_reg[3]) : By_reg[2];
	By_reg_next[1] = cnt[2] ? By_reg[2] : By_reg[1];
	By_reg_next[0] = cnt[2] ? By_reg[1] : By_reg[0];
	Cy_reg_next[3] = cnt[2] ? Cy_add : Cy_reg[3];
	Cy_reg_next[2] = cnt[2] ? Cy_reg[3] : Cy_reg[2];
	Cy_reg_next[1] = cnt[2] ? Cy_reg[2] : Cy_reg[1];
	Cy_reg_next[0] = cnt[2] ? Cy_reg[1] : Cy_reg[0];
	Dy_reg_next[3] = cnt[2] ? Dy_add : Dy_reg[3];
	Dy_reg_next[2] = cnt[2] ? Dy_reg[3] : Dy_reg[2];
	Dy_reg_next[1] = cnt[2] ? Dy_reg[2] : Dy_reg[1];
	Dy_reg_next[0] = cnt[2] ? Dy_reg[1] : Dy_reg[0];
	reg_temp_next = cnt[2] ? Ay_reg[0] : reg_temp;
end

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		Ay_mul_reg <= '1;
		By_mul_reg <= '1;
		Cy_mul_reg <= '1;
		Dy_mul_reg <= '1;
		Ey_mul_reg <= '1;
		for(int i=0; i<4; i=i+1) Ay_reg[i] <= '1;
		for(int i=0; i<4; i=i+1) By_reg[i] <= '1;
		for(int i=0; i<4; i=i+1) Cy_reg[i] <= '1;
		for(int i=0; i<4; i=i+1) Dy_reg[i] <= '1;
		reg_temp <= '1;
	end
	else begin
		Ay_mul_reg <= Ay_mul;
		By_mul_reg <= By_mul;
		Cy_mul_reg <= Cy_mul;
		Dy_mul_reg <= Dy_mul;
		Ey_mul_reg <= Ey_mul;
		for(int i=0; i<4; i=i+1) Ay_reg[i] <= Ay_reg_next[i];
		for(int i=0; i<4; i=i+1) By_reg[i] <= By_reg_next[i];
		for(int i=0; i<4; i=i+1) Cy_reg[i] <= Cy_reg_next[i];
		for(int i=0; i<4; i=i+1) Dy_reg[i] <= Dy_reg_next[i];
		reg_temp <= reg_temp_next;
	end
end

assign convy_out = Ey_add;

// output
//---------------------------------------------------------------------
logic out_valid_next;
logic signed [14:0] out_data_next;
parameter S_out = 48;

always_comb begin
	out_valid_next = !cnt[6] & cnt[5] & cnt[4];
	casez(cnt)
		S_out: out_data_next = By_reg[0];
		S_out+1: out_data_next = By_reg[1];
		S_out+2: out_data_next = By_reg[2];
		S_out+3: out_data_next = reg_temp;
		S_out+4,S_out+5,S_out+6,S_out+7: out_data_next = Ay_reg[0];
		S_out+8: out_data_next = Ay_reg[0];
		S_out+9: out_data_next = Ay_reg[1];
		S_out+10: out_data_next = Ay_reg[2];
		S_out+11: out_data_next = Ay_reg[3];
		S_out+12,S_out+13,S_out+14,S_out+15: out_data_next = convy_out;
		default: out_data_next = 0;
	endcase
end

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		out_valid <= 0;
		out_data <= 0;
	end
	else begin
		out_valid <= out_valid_next;
		out_data <= out_data_next;
	end
end

// funcs
//---------------------------------------------------------------------------
task MUL10(input signed [9:0] a, input signed [3:0] b, output [10:0] booth0, output [10:0] booth1);
	casez(b[1:0])
		'b00: booth0 = 0;
		'b01: booth0 = a;
		'b10: booth0 = -(a <<< 1);
		'b11: booth0 = -a;
	endcase
	casez(b[3:1])
		'b000: booth1 = 0;
		'b001: booth1 = a;
		'b010: booth1 = a;
		'b011: booth1 = a <<< 1;
		'b100: booth1 = -(a <<< 1);
		'b101: booth1 = -a;
		'b110: booth1 = -a;
		'b111: booth1 = 0;
	endcase
endtask

task MUL4(input signed [3:0] a, input signed [3:0] b, output [5:0] booth0, output [5:0] booth1);
	casez(b[1:0])
		'b00: booth0 = 0;
		'b01: booth0 = a;
		'b10: booth0 = -(a <<< 1);
		'b11: booth0 = -a;
	endcase
	casez(b[3:1])
		'b000: booth1 = 0;
		'b001: booth1 = a;
		'b010: booth1 = a;
		'b011: booth1 = a <<< 1;
		'b100: booth1 = -(a <<< 1);
		'b101: booth1 = -a;
		'b110: booth1 = -a;
		'b111: booth1 = 0;
	endcase
endtask

endmodule
// 89533 @ 1.8ns 1321