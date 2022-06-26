module JAM(
  // Input signals
	clk,
	rst_n,
    in_valid,
    in_cost,
  // Output signals
	out_valid,
    out_job,
	out_cost
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid;
input [6:0] in_cost;
output logic out_valid;
output logic [3:0] out_job;
output logic [9:0] out_cost;
//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
// array
logic [7:0] array [63:0];
logic [7:0] array_next [63:0];
// zero
logic [63:0] zero;
logic [63:0] zero_e;
logic [63:0] zero_e_la;
logic free_zero;
// line
logic [7:0] row_line, col_line;
logic [7:0] row_line_next , col_line_next;
// circle count
logic [3:0] circle_cnt;
logic [3:0] circle_cnt_next;
// step 5
logic [63:0] circle_zero;
logic [63:0] circle_zero_next;
logic [63:0] b_zero, c_zero;
logic [7:0] row_check, col_check, row_check_final;
logic [7:0] row_check_next, col_check_next;
logic [7:0] row_check_out;
logic [3:0] check_cnt;
logic [3:0] check_cnt_next;
// job assign
logic [2:0] job [7:0];
logic [2:0] job_next [7:0];
// dfs ctrl
logic backward;
logic backward_pip;
// cost output
logic [9:0] total_cost;
// out
logic [3:0] out_job_next;
logic [9:0] out_cost_next;
logic out_valid_next;
// boost
logic row_1 [7:0], col_1[7:0];
logic [6:0] free_zero_check;

always_comb begin
	for(int i=0; i<8; i=i+1) begin
		casez({zero_e_la[8*i],zero_e_la[8*i+1],zero_e_la[8*i+2],zero_e_la[8*i+3],zero_e_la[8*i+4],zero_e_la[8*i+5],zero_e_la[8*i+6],zero_e_la[8*i+7]})
			'b10000000,
			'b01000000,
			'b00100000,
			'b00010000,
			'b00001000,
			'b00000100,
			'b00000010,
			'b00000001: row_1[i] = 1;
			default row_1[i] = 0;
		endcase
	end
	for(int i=0; i<8; i=i+1) begin
		casez({zero_e_la[i],zero_e_la[8+i],zero_e_la[16+i],zero_e_la[24+i],zero_e_la[32+i],zero_e_la[40+i],zero_e_la[48+i],zero_e_la[56+i]})
			'b10000000,
			'b01000000,
			'b00100000,
			'b00010000,
			'b00001000,
			'b00000100,
			'b00000010,
			'b00000001: col_1[i] = 1;
			default col_1[i] = 0;
		endcase
	end
end
//---------------------------------------------------------------------
//   FSM                        
//---------------------------------------------------------------------
logic [6:0] state;
logic [6:0] state_next;
parameter S_start = 0;
parameter S_row_redu = S_start + 8;
parameter S_col_redu = S_row_redu + 64;
parameter S_circle = 74; // end = 91
parameter S_redraw = 92; // end = 93
parameter S_morezero = 94; // end = 95
parameter S_left_zero = 96; // end = 103
parameter S_assign = 105;
parameter S_assign1 = S_assign+1;
parameter S_assign2 = S_assign+2;
parameter S_assign3 = S_assign+3;
parameter S_assign4 = S_assign+4;
parameter S_assign5 = S_assign+5;
parameter S_assign6 = S_assign+6;
parameter S_assign7 = S_assign+7;
parameter S_assign8 = S_assign+8;
parameter S_output = S_assign+9;
parameter S_end = S_output + 8; // 122

always_ff@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		state <= S_end;
	else
		state <= state_next;
end

always_comb begin
	casez(state)
		S_circle: state_next = !row_1[0]? !row_1[1]? !row_1[2] ? !row_1[3] ? !row_1[4] ? !row_1[5] ? !row_1[6] ? !row_1[7] ? !col_1[0] ? !col_1[1] ? !col_1[2] ? state+12 : state+11 : state+10 : state+9 : state+8 : state+7 : state+6 : state+5 : state+4 : state+3 : state+2 : state+1;
		S_circle+1: state_next = !row_1[1]? !row_1[2]? !row_1[3] ? !row_1[4] ? !row_1[5] ? !row_1[6] ? !row_1[7] ? !col_1[0] ? !col_1[1] ? !col_1[2] ? !col_1[3] ? state+12 : state+11 : state+10 : state+9 : state+8 : state+7 : state+6 : state+5 : state+4 : state+3 : state+2 : state+1; 
		S_circle+2: state_next = !row_1[2]? !row_1[3]? !row_1[4] ? !row_1[5] ? !row_1[6] ? !row_1[7] ? !col_1[0] ? !col_1[1] ? !col_1[2] ? !col_1[3] ? !col_1[4] ? state+12 : state+11 : state+10 : state+9 : state+8 : state+7 : state+6 : state+5 : state+4 : state+3 : state+2 : state+1; 
		S_circle+3: state_next = !row_1[3]? !row_1[4]? !row_1[5] ? !row_1[6] ? !row_1[7] ? !col_1[0] ? !col_1[1] ? !col_1[2] ? !col_1[3] ? !col_1[4] ? !col_1[5] ? state+12 : state+11 : state+10 : state+9 : state+8 : state+7 : state+6 : state+5 : state+4 : state+3 : state+2 : state+1; 
		S_circle+4: state_next = !row_1[4]? !row_1[5]? !row_1[6] ? !row_1[7] ? !col_1[0] ? !col_1[1] ? !col_1[2] ? !col_1[3] ? !col_1[4] ? !col_1[5] ? !col_1[6] ? state+12 : state+11 : state+10 : state+9 : state+8 : state+7 : state+6 : state+5 : state+4 : state+3 : state+2 : state+1; 
		S_circle+5: state_next = !row_1[5]? !row_1[6]? !row_1[7] ? !col_1[0] ? !col_1[1] ? !col_1[2] ? !col_1[3] ? !col_1[4] ? !col_1[5] ? !col_1[6] ? !col_1[7] ? state+12 : state+11 : state+10 : state+9 : state+8 : state+7 : state+6 : state+5 : state+4 : state+3 : state+2 : state+1; 
		S_circle+6: state_next = !row_1[6]? !row_1[7]? !col_1[0] ? !col_1[1] ? !col_1[2] ? !col_1[3] ? !col_1[4] ? !col_1[5] ? !col_1[6] ? !col_1[7] ? state+11 : state+10 : state+9 : state+8 : state+7 : state+6 : state+5 : state+4 : state+3 : state+2 : state+1;
		S_circle+7: state_next = !row_1[7]? !col_1[0]? !col_1[1] ? !col_1[2] ? !col_1[3] ? !col_1[4] ? !col_1[5] ? !col_1[6] ? !col_1[7] ? state+10 : state+9 : state+8 : state+7 : state+6 : state+5 : state+4 : state+3 : state+2 : state+1;
		S_circle+8: state_next = !col_1[0]? !col_1[1]? !col_1[2] ? !col_1[3] ? !col_1[4] ? !col_1[5] ? !col_1[6] ? !col_1[7] ? state+9 : state+8 : state+7 : state+6 : state+5 : state+4 : state+3 : state+2 : state+1;
		S_circle+9: state_next = !col_1[1]? !col_1[2]? !col_1[3] ? !col_1[4] ? !col_1[5] ? !col_1[6] ? !col_1[7] ? state+8 : state+7 : state+6 : state+5 : state+4 : state+3 : state+2 : state+1;
		S_circle+10: state_next = !col_1[2]? !col_1[3]? !col_1[4] ? !col_1[5] ? !col_1[6] ? !col_1[7] ? state+7 : state+6 : state+5 : state+4 : state+3 : state+2 : state+1;
		S_circle+11: state_next = !col_1[3]? !col_1[4]? !col_1[5] ? !col_1[6] ? !col_1[7] ? state+6 : state+5 : state+4 : state+3 : state+2 : state+1;
		S_circle+12: state_next = !col_1[4]? !col_1[5]? !col_1[6] ? !col_1[7] ? state+5 : state+4 : state+3 : state+2 : state+1;
		S_circle+13: state_next = !col_1[5]? !col_1[6]? !col_1[7] ? state+4 : state+3 : state+2 : state+1;
		S_circle+14: state_next = !col_1[6]? !col_1[7]? state+3 : state+2 : state+1;
		S_circle+15: state_next = !col_1[7]? state+2 : state+1;
		S_circle+17: begin
			if(circle_cnt == 8)
				state_next = S_assign;
			else if(free_zero)
				casez(free_zero_check)
					'b????_??1: state_next = S_left_zero;
					'b????_?10: state_next = S_left_zero+1;
					'b????_100: state_next = S_left_zero+2;
					'b???1_000: state_next = S_left_zero+3;
					'b??10_000: state_next = S_left_zero+4;
					'b?100_000: state_next = S_left_zero+5;
					'b1000_000: state_next = S_left_zero+6;
					'b0000_000: state_next = S_left_zero+7;
					default : state_next = S_left_zero;
				endcase
			else
				state_next = state + 1;
		end
		S_redraw+1: begin
			if(col_check == 8'b11111111)
				state_next = S_assign;
			else if((col_check == col_check_next) & (row_check == row_check_next))
				state_next = state + 1;
			else			
				state_next = state;
		end
		S_morezero+1: state_next = S_circle;
		S_left_zero: state_next = S_circle + 1;
		S_left_zero+1: state_next = S_circle + 1;
		S_left_zero+2: state_next = S_circle + 1;
		S_left_zero+3: state_next = S_circle + 1;
		S_left_zero+4: state_next = S_circle + 1;
		S_left_zero+5: state_next = S_circle + 1;
		S_left_zero+6: state_next = S_circle + 1;
		S_left_zero+7: state_next = S_circle + 1;
		S_assign1: state_next = state + 1;
		S_assign2: state_next = backward ? state - 1 : state + 1;
		S_assign3: state_next = backward ? state - 1 : state + 1;
		S_assign4: state_next = backward ? state - 1 : state + 1;
		S_assign5: state_next = backward ? state - 1 : state + 1;
		S_assign6: state_next = backward ? state - 1 : state + 1;
		S_assign7: state_next = backward ? state - 1 : state + 1;
		S_assign8: state_next = backward ? state - 1 : state + 1;
		S_end: state_next = in_valid ? S_start : S_end;
		default: state_next = state + 1;
	endcase
end
//---------------------------------------------------------------------
//   Circuit                        
//---------------------------------------------------------------------
// data in
//---------------------------------------------------------------------
logic [6:0] in_data;
assign in_data = in_valid ? in_cost : 0;

//---------------------------------------------------------------------
// data preservation
//---------------------------------------------------------------------
logic [6:0] original_data [63:0];
logic [6:0] original_data_next [63:0];

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		for(int i=0; i<64; i=i+1) original_data[i] <= '1;
	else
		for(int i=0; i<64; i=i+1) original_data[i] <= original_data_next[i];
end

always_comb begin
	for(int i=0; i<63; i=i+1) original_data_next[i] = in_valid ? original_data[i+1] : original_data[i];
	original_data_next[63] = in_valid ? in_data : original_data[63];
end
//---------------------------------------------------------------------
// row min
//---------------------------------------------------------------------
logic [6:0] in_row_redu [7:0];
logic [6:0] in_row_redu_pip;
logic [6:0] row_min;
logic [6:0] row_min_next;
logic [6:0] row_min_reg;
logic [6:0] row_min_reg_next;
logic [6:0] row_redu_out;

always_ff@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for (int i=0; i<8; i=i+1) in_row_redu[i] <= '1;
		in_row_redu_pip <= '1;
		row_min <= '1;
		row_min_reg <= '1;
	end
	else begin
		for (int i=0; i<7; i=i+1) in_row_redu[i] <= in_row_redu[i+1];
		in_row_redu[7] <= in_data;
		in_row_redu_pip <= in_row_redu[0];
		row_min <= row_min_next;
		row_min_reg <= row_min_reg_next;
	end
end

always_comb begin
	if(state[2:0] == '1 | state == S_end)
		row_min_next = in_data;
	else if (in_data < row_min)
		row_min_next = in_data;
	else
		row_min_next = row_min;
		
	if(state[2:0] == '1)
		row_min_reg_next = row_min;
	else
		row_min_reg_next = row_min_reg;
		
	row_redu_out = in_row_redu_pip - row_min_reg;
end

//---------------------------------------------------------------------
// col min & all min
//---------------------------------------------------------------------
logic [6:0] col_min_0, col_min_1, col_min_2, col_min_3, col_min_4, col_min_5, col_min_6, col_min_7;
logic [6:0] col_min_0_next, col_min_1_next, col_min_2_next, col_min_3_next, col_min_4_next, col_min_5_next, col_min_6_next, col_min_7_next;
logic [6:0] all_min;
logic [6:0] all_min_next;

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		col_min_0 <= '1;
		col_min_1 <= '1;
		col_min_2 <= '1;
		col_min_3 <= '1;
		col_min_4 <= '1;
		col_min_5 <= '1;
		col_min_6 <= '1;
		col_min_7 <= '1;
		all_min <= '1;
	end
	else begin
		col_min_0 <= col_min_0_next;
		col_min_1 <= col_min_1_next;
		col_min_2 <= col_min_2_next;
		col_min_3 <= col_min_3_next;
		col_min_4 <= col_min_4_next;
		col_min_5 <= col_min_5_next;
		col_min_6 <= col_min_6_next;
		col_min_7 <= col_min_7_next;
		all_min <= all_min_next;
	end
end

MIN min0(col_line[0],row_line,array[0],array[8],array[16],array[24],array[32],array[40],array[48],array[56],col_min_0_next);
MIN min1(col_line[1],row_line,array[1],array[9],array[17],array[25],array[33],array[41],array[49],array[57],col_min_1_next);
MIN min2(col_line[2],row_line,array[2],array[10],array[18],array[26],array[34],array[42],array[50],array[58],col_min_2_next);
MIN min3(col_line[3],row_line,array[3],array[11],array[19],array[27],array[35],array[43],array[51],array[59],col_min_3_next);
MIN min4(col_line[4],row_line,array[4],array[12],array[20],array[28],array[36],array[44],array[52],array[60],col_min_4_next);
MIN min5(col_line[5],row_line,array[5],array[13],array[21],array[29],array[37],array[45],array[53],array[61],col_min_5_next);
MIN min6(col_line[6],row_line,array[6],array[14],array[22],array[30],array[38],array[46],array[54],array[62],col_min_6_next);
MIN min7(col_line[7],row_line,array[7],array[15],array[23],array[31],array[39],array[47],array[55],array[63],col_min_7_next);
MIN2 min8(col_min_0,col_min_1,col_min_2,col_min_3,col_min_4,col_min_5,col_min_6,col_min_7,all_min_next);

//---------------------------------------------------------------------
// job mask
//---------------------------------------------------------------------
logic [7:0] job_mask_pre [7:0];
logic [7:0] job_mask [7:0];

always_comb begin
	for(int i=0; i<8; i=i+1) begin
		casez(job[i])
			0: job_mask_pre[i] = 'b11111111;
			1: job_mask_pre[i] = 'b01111111;
			2: job_mask_pre[i] = 'b00111111;
			3: job_mask_pre[i] = 'b00011111;
			4: job_mask_pre[i] = 'b00001111;
			5: job_mask_pre[i] = 'b00000111;
			6: job_mask_pre[i] = 'b00000011;
			7: job_mask_pre[i] = 'b00000001;
		endcase		
		job_mask[i] = job_mask_pre[i] | ~{8{backward_pip}};
	end
end

//---------------------------------------------------------------------
// array sequential
//---------------------------------------------------------------------
// Array
always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		for(int i=0; i<64; i=i+1) array[i] <= '1;
	else
		for(int i=0; i<64; i=i+1) array[i] <= array_next[i];
end
// Line
always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		row_line <= '1;
		col_line <= '1;
		circle_cnt <= '1;
		circle_zero <= '1;
	end
	else begin
		row_line <= row_line_next;
		col_line <= col_line_next;
		circle_cnt <= circle_cnt_next;
		circle_zero <= circle_zero_next;
	end
end
always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		row_check <= '1;
		col_check <= '1;
	end
	else begin
		row_check <= row_check_next;
		col_check <= col_check_next;
	end
end
// Job Assign
always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		for(int i=0; i<8; i=i+1) job[i] <= 0;
	else
		for(int i=0; i<8; i=i+1) job[i] <= job_next[i];
end
// DFS
always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		backward_pip <= 0;
	else
		backward_pip <= backward;
end
//---------------------------------------------------------------------
// array combinational
//---------------------------------------------------------------------
// Zero counting
always_comb begin
	for(int i=0; i<64; i=i+1) zero[i] = (array[i] == 0);
	for(int i=0; i<8; i=i+1) begin
		for(int j=0; j<8; j=j+1) begin
			zero_e[i*8+j] = zero[i*8+j] & !row_line[i] & !col_line[j];
		end
	end
	for(int i=0; i<8; i=i+1) begin
		for(int j=0; j<8; j=j+1) begin
			zero_e_la[i*8+j] = zero[i*8+j] & !row_line_next[i] & !col_line_next[j];
		end
	end
	for(int i=0; i<7; i=i+1) free_zero_check[i] = |{zero_e[8*i+0],zero_e[8*i+1],zero_e[8*i+2],zero_e[8*i+3],zero_e[8*i+4],zero_e[8*i+5],zero_e[8*i+6],zero_e[8*i+7]};
	free_zero = |zero_e;
end

// Array 
always_comb begin
	// array default
	for(int i=0; i<64; i=i+1) array_next[i] = array[i];
	//line default
	row_line_next = row_line;
	col_line_next = col_line;
	// circle
	circle_cnt_next = circle_cnt;
	circle_zero_next = circle_zero;
	// job default
	for(int i=0; i<8; i=i+1) job_next[i] = job[i];
	backward = 0;
	// total cost calculation
	total_cost = original_data[job[0]] + original_data[job[1]+8] + original_data[job[2]+16] + original_data[job[3]+24] + original_data[job[4]+32] + original_data[job[5]+40] + original_data[job[6]+48] + original_data[job[7]+56];
	// check default
	for(int i=0; i<8; i=i+1)
		for(int j=0; j<8; j=j+1) b_zero[8*i+j] = zero[8*i+j] & !circle_zero[8*i+j] & row_check[i];
	for(int i=0; i<8; i=i+1) col_check_next[i] = |{b_zero[i],b_zero[8+i],b_zero[16+i],b_zero[24+i],b_zero[32+i],b_zero[40+i],b_zero[48+i],b_zero[56+i]};
	for(int i=0; i<8; i=i+1)
		for(int j=0; j<8; j=j+1) c_zero[8*i+j] = circle_zero[8*i+j] & col_check[j];
	for(int i=0; i<8; i=i+1) row_check_final[i] = |{c_zero[i*8],c_zero[i*8+1],c_zero[i*8+2],c_zero[i*8+3],c_zero[i*8+4],c_zero[i*8+5],c_zero[i*8+6],c_zero[i*8+7]};
	row_check_next = row_check_final | row_check;
	// array calculation
	casez(state)
		S_start: begin
			row_line_next = '0;
			col_line_next = '0;
		end
		'b00??????,'b01000???: begin
			for(int i=0; i<63; i=i+1) array_next[i] = array_next[i+1];
			array_next[63] = row_redu_out;
		end
		73: begin
			for(int i=0; i<8; i=i+1) array_next[8*i] = array[8*i] - col_min_0;
			for(int i=0; i<8; i=i+1) array_next[8*i+1] = array[8*i+1] - col_min_1;
			for(int i=0; i<8; i=i+1) array_next[8*i+2] = array[8*i+2] - col_min_2;
			for(int i=0; i<8; i=i+1) array_next[8*i+3] = array[8*i+3] - col_min_3;
			for(int i=0; i<8; i=i+1) array_next[8*i+4] = array[8*i+4] - col_min_4;
			for(int i=0; i<8; i=i+1) array_next[8*i+5] = array[8*i+5] - col_min_5;
			for(int i=0; i<8; i=i+1) array_next[8*i+6] = array[8*i+6] - col_min_6;
			for(int i=0; i<8; i=i+1) array_next[8*i+7] = array[8*i+7] - col_min_7;
		end
		S_circle: begin
			row_line_next = '0;
			col_line_next = '0;
			circle_cnt_next = 0;
			circle_zero_next = '0;
		end
		S_circle+1: begin
			casez({zero_e[0],zero_e[1],zero_e[2],zero_e[3],zero_e[4],zero_e[5],zero_e[6],zero_e[7]})
				'b10000000: begin col_line_next[0] = 1; circle_cnt_next = circle_cnt + 1; end
				'b01000000: begin col_line_next[1] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00100000: begin col_line_next[2] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00010000: begin col_line_next[3] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00001000: begin col_line_next[4] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000100: begin col_line_next[5] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000010: begin col_line_next[6] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000001: begin col_line_next[7] = 1; circle_cnt_next = circle_cnt + 1; end
			endcase
			casez({zero_e[0],zero_e[1],zero_e[2],zero_e[3],zero_e[4],zero_e[5],zero_e[6],zero_e[7]})
				'b10000000: circle_zero_next[0] = 1;
				'b01000000: circle_zero_next[1] = 1;
				'b00100000: circle_zero_next[2] = 1;
				'b00010000: circle_zero_next[3] = 1;
				'b00001000: circle_zero_next[4] = 1;
				'b00000100: circle_zero_next[5] = 1;
				'b00000010: circle_zero_next[6] = 1;
				'b00000001: circle_zero_next[7] = 1;
			endcase
				
		end
		S_circle+2: begin
			casez({zero_e[8],zero_e[9],zero_e[10],zero_e[11],zero_e[12],zero_e[13],zero_e[14],zero_e[15]})
				'b10000000: begin col_line_next[0] = 1; circle_cnt_next = circle_cnt + 1; end
				'b01000000: begin col_line_next[1] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00100000: begin col_line_next[2] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00010000: begin col_line_next[3] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00001000: begin col_line_next[4] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000100: begin col_line_next[5] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000010: begin col_line_next[6] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000001: begin col_line_next[7] = 1; circle_cnt_next = circle_cnt + 1; end
			endcase
			casez({zero_e[8],zero_e[9],zero_e[10],zero_e[11],zero_e[12],zero_e[13],zero_e[14],zero_e[15]})
					'b10000000: circle_zero_next[8] = 1;
					'b01000000: circle_zero_next[9] = 1;
					'b00100000: circle_zero_next[10] = 1;
					'b00010000: circle_zero_next[11] = 1;
					'b00001000: circle_zero_next[12] = 1;
					'b00000100: circle_zero_next[13] = 1;
					'b00000010: circle_zero_next[14] = 1;
					'b00000001: circle_zero_next[15] = 1;
			endcase
		end
		S_circle+3: begin
			casez({zero_e[16],zero_e[17],zero_e[18],zero_e[19],zero_e[20],zero_e[21],zero_e[22],zero_e[23]})
				'b10000000: begin col_line_next[0] = 1; circle_cnt_next = circle_cnt + 1; end
				'b01000000: begin col_line_next[1] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00100000: begin col_line_next[2] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00010000: begin col_line_next[3] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00001000: begin col_line_next[4] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000100: begin col_line_next[5] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000010: begin col_line_next[6] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000001: begin col_line_next[7] = 1; circle_cnt_next = circle_cnt + 1; end
			endcase
			casez({zero_e[16],zero_e[17],zero_e[18],zero_e[19],zero_e[20],zero_e[21],zero_e[22],zero_e[23]})
				'b10000000: circle_zero_next[16] = 1;
				'b01000000: circle_zero_next[17] = 1;
				'b00100000: circle_zero_next[18] = 1;
				'b00010000: circle_zero_next[19] = 1;
				'b00001000: circle_zero_next[20] = 1;
				'b00000100: circle_zero_next[21] = 1;
				'b00000010: circle_zero_next[22] = 1;
				'b00000001: circle_zero_next[23] = 1;
			endcase
		end
		S_circle+4: begin
			casez({zero_e[24],zero_e[25],zero_e[26],zero_e[27],zero_e[28],zero_e[29],zero_e[30],zero_e[31]})
				'b10000000: begin col_line_next[0] = 1; circle_cnt_next = circle_cnt + 1; end
				'b01000000: begin col_line_next[1] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00100000: begin col_line_next[2] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00010000: begin col_line_next[3] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00001000: begin col_line_next[4] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000100: begin col_line_next[5] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000010: begin col_line_next[6] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000001: begin col_line_next[7] = 1; circle_cnt_next = circle_cnt + 1; end
			endcase
			casez({zero_e[24],zero_e[25],zero_e[26],zero_e[27],zero_e[28],zero_e[29],zero_e[30],zero_e[31]})
				'b10000000: circle_zero_next[24] = 1;
				'b01000000: circle_zero_next[25] = 1;
				'b00100000: circle_zero_next[26] = 1;
				'b00010000: circle_zero_next[27] = 1;
				'b00001000: circle_zero_next[28] = 1;
				'b00000100: circle_zero_next[29] = 1;
				'b00000010: circle_zero_next[30] = 1;
				'b00000001: circle_zero_next[31] = 1;
			endcase
		end
		S_circle+5: begin
			casez({zero_e[32],zero_e[33],zero_e[34],zero_e[35],zero_e[36],zero_e[37],zero_e[38],zero_e[39]})
				'b10000000: begin col_line_next[0] = 1; circle_cnt_next = circle_cnt + 1; end
				'b01000000: begin col_line_next[1] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00100000: begin col_line_next[2] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00010000: begin col_line_next[3] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00001000: begin col_line_next[4] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000100: begin col_line_next[5] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000010: begin col_line_next[6] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000001: begin col_line_next[7] = 1; circle_cnt_next = circle_cnt + 1; end
			endcase
			casez({zero_e[32],zero_e[33],zero_e[34],zero_e[35],zero_e[36],zero_e[37],zero_e[38],zero_e[39]})
				'b10000000: circle_zero_next[32] = 1;
				'b01000000: circle_zero_next[33] = 1;
				'b00100000: circle_zero_next[34] = 1;
				'b00010000: circle_zero_next[35] = 1;
				'b00001000: circle_zero_next[36] = 1;
				'b00000100: circle_zero_next[37] = 1;
				'b00000010: circle_zero_next[38] = 1;
				'b00000001: circle_zero_next[39] = 1;
			endcase
		end
		S_circle+6: begin
			casez({zero_e[40],zero_e[41],zero_e[42],zero_e[43],zero_e[44],zero_e[45],zero_e[46],zero_e[47]})
				'b10000000: begin col_line_next[0] = 1; circle_cnt_next = circle_cnt + 1; end
				'b01000000: begin col_line_next[1] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00100000: begin col_line_next[2] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00010000: begin col_line_next[3] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00001000: begin col_line_next[4] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000100: begin col_line_next[5] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000010: begin col_line_next[6] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000001: begin col_line_next[7] = 1; circle_cnt_next = circle_cnt + 1; end
			endcase
			casez({zero_e[40],zero_e[41],zero_e[42],zero_e[43],zero_e[44],zero_e[45],zero_e[46],zero_e[47]})
				'b10000000: circle_zero_next[40] = 1;
				'b01000000: circle_zero_next[41] = 1;
				'b00100000: circle_zero_next[42] = 1;
				'b00010000: circle_zero_next[43] = 1;
				'b00001000: circle_zero_next[44] = 1;
				'b00000100: circle_zero_next[45] = 1;
				'b00000010: circle_zero_next[46] = 1;
				'b00000001: circle_zero_next[47] = 1;
			endcase
		end
		S_circle+7: begin
			casez({zero_e[48],zero_e[49],zero_e[50],zero_e[51],zero_e[52],zero_e[53],zero_e[54],zero_e[55]})
				'b10000000: begin col_line_next[0] = 1; circle_cnt_next = circle_cnt + 1; end
				'b01000000: begin col_line_next[1] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00100000: begin col_line_next[2] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00010000: begin col_line_next[3] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00001000: begin col_line_next[4] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000100: begin col_line_next[5] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000010: begin col_line_next[6] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000001: begin col_line_next[7] = 1; circle_cnt_next = circle_cnt + 1; end
			endcase
			casez({zero_e[48],zero_e[49],zero_e[50],zero_e[51],zero_e[52],zero_e[53],zero_e[54],zero_e[55]})
				'b10000000: circle_zero_next[48] = 1;
				'b01000000: circle_zero_next[49] = 1;
				'b00100000: circle_zero_next[50] = 1;
				'b00010000: circle_zero_next[51] = 1;
				'b00001000: circle_zero_next[52] = 1;
				'b00000100: circle_zero_next[53] = 1;
				'b00000010: circle_zero_next[54] = 1;
				'b00000001: circle_zero_next[55] = 1;
				endcase
		end
		S_circle+8: begin
			casez({zero_e[56],zero_e[57],zero_e[58],zero_e[59],zero_e[60],zero_e[61],zero_e[62],zero_e[63]})
				'b10000000: begin col_line_next[0] = 1; circle_cnt_next = circle_cnt + 1; end
				'b01000000: begin col_line_next[1] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00100000: begin col_line_next[2] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00010000: begin col_line_next[3] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00001000: begin col_line_next[4] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000100: begin col_line_next[5] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000010: begin col_line_next[6] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000001: begin col_line_next[7] = 1; circle_cnt_next = circle_cnt + 1; end
			endcase
			casez({zero_e[56],zero_e[57],zero_e[58],zero_e[59],zero_e[60],zero_e[61],zero_e[62],zero_e[63]})
				'b10000000: circle_zero_next[56] = 1;
				'b01000000: circle_zero_next[57] = 1;
				'b00100000: circle_zero_next[58] = 1;
				'b00010000: circle_zero_next[59] = 1;
				'b00001000: circle_zero_next[60] = 1;
				'b00000100: circle_zero_next[61] = 1;
				'b00000010: circle_zero_next[62] = 1;
				'b00000001: circle_zero_next[63] = 1;
			endcase
		end
		S_circle+9: begin
			casez({zero_e[0],zero_e[8],zero_e[16],zero_e[24],zero_e[32],zero_e[40],zero_e[48],zero_e[56]})
				'b10000000: begin row_line_next[0] = 1; circle_cnt_next = circle_cnt + 1; end
				'b01000000: begin row_line_next[1] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00100000: begin row_line_next[2] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00010000: begin row_line_next[3] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00001000: begin row_line_next[4] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000100: begin row_line_next[5] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000010: begin row_line_next[6] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000001: begin row_line_next[7] = 1; circle_cnt_next = circle_cnt + 1; end
			endcase
			casez({zero_e[0],zero_e[8],zero_e[16],zero_e[24],zero_e[32],zero_e[40],zero_e[48],zero_e[56]})
				'b10000000: circle_zero_next[0] = 1;
				'b01000000: circle_zero_next[8] = 1;
				'b00100000: circle_zero_next[16] = 1;
				'b00010000: circle_zero_next[24] = 1;
				'b00001000: circle_zero_next[32] = 1;
				'b00000100: circle_zero_next[40] = 1;
				'b00000010: circle_zero_next[48] = 1;
				'b00000001: circle_zero_next[56] = 1;
			endcase
		end
		S_circle+10: begin
			casez({zero_e[1],zero_e[9],zero_e[17],zero_e[25],zero_e[33],zero_e[41],zero_e[49],zero_e[57]})
				'b10000000: begin row_line_next[0] = 1; circle_cnt_next = circle_cnt + 1; end
				'b01000000: begin row_line_next[1] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00100000: begin row_line_next[2] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00010000: begin row_line_next[3] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00001000: begin row_line_next[4] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000100: begin row_line_next[5] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000010: begin row_line_next[6] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000001: begin row_line_next[7] = 1; circle_cnt_next = circle_cnt + 1; end
			endcase
			casez({zero_e[1],zero_e[9],zero_e[17],zero_e[25],zero_e[33],zero_e[41],zero_e[49],zero_e[57]})
				'b10000000: circle_zero_next[1] = 1;
				'b01000000: circle_zero_next[9] = 1;
				'b00100000: circle_zero_next[17] = 1;
				'b00010000: circle_zero_next[25] = 1;
				'b00001000: circle_zero_next[33] = 1;
				'b00000100: circle_zero_next[41] = 1;
				'b00000010: circle_zero_next[49] = 1;
				'b00000001: circle_zero_next[57] = 1;
			endcase
		end
		S_circle+11: begin
			casez({zero_e[2],zero_e[10],zero_e[18],zero_e[26],zero_e[34],zero_e[42],zero_e[50],zero_e[58]})
				'b10000000: begin row_line_next[0] = 1; circle_cnt_next = circle_cnt + 1; end
				'b01000000: begin row_line_next[1] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00100000: begin row_line_next[2] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00010000: begin row_line_next[3] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00001000: begin row_line_next[4] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000100: begin row_line_next[5] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000010: begin row_line_next[6] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000001: begin row_line_next[7] = 1; circle_cnt_next = circle_cnt + 1; end
			endcase
			casez({zero_e[2],zero_e[10],zero_e[18],zero_e[26],zero_e[34],zero_e[42],zero_e[50],zero_e[58]})
				'b10000000: circle_zero_next[2] = 1;
				'b01000000: circle_zero_next[10] = 1;
				'b00100000: circle_zero_next[18] = 1;
				'b00010000: circle_zero_next[26] = 1;
				'b00001000: circle_zero_next[34] = 1;
				'b00000100: circle_zero_next[42] = 1;
				'b00000010: circle_zero_next[50] = 1;
				'b00000001: circle_zero_next[58] = 1;
			endcase
		end
		S_circle+12: begin
			casez({zero_e[3],zero_e[11],zero_e[19],zero_e[27],zero_e[35],zero_e[43],zero_e[51],zero_e[59]})
				'b10000000: begin row_line_next[0] = 1; circle_cnt_next = circle_cnt + 1; end
				'b01000000: begin row_line_next[1] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00100000: begin row_line_next[2] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00010000: begin row_line_next[3] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00001000: begin row_line_next[4] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000100: begin row_line_next[5] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000010: begin row_line_next[6] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000001: begin row_line_next[7] = 1; circle_cnt_next = circle_cnt + 1; end
			endcase
			casez({zero_e[3],zero_e[11],zero_e[19],zero_e[27],zero_e[35],zero_e[43],zero_e[51],zero_e[59]})
				'b10000000: circle_zero_next[3] = 1;
				'b01000000: circle_zero_next[11] = 1;
				'b00100000: circle_zero_next[19] = 1;
				'b00010000: circle_zero_next[27] = 1;
				'b00001000: circle_zero_next[35] = 1;
				'b00000100: circle_zero_next[43] = 1;
				'b00000010: circle_zero_next[51] = 1;
				'b00000001: circle_zero_next[59] = 1;
			endcase
		end
		S_circle+13: begin
			casez({zero_e[4],zero_e[12],zero_e[20],zero_e[28],zero_e[36],zero_e[44],zero_e[52],zero_e[60]})
				'b10000000: begin row_line_next[0] = 1; circle_cnt_next = circle_cnt + 1; end
				'b01000000: begin row_line_next[1] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00100000: begin row_line_next[2] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00010000: begin row_line_next[3] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00001000: begin row_line_next[4] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000100: begin row_line_next[5] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000010: begin row_line_next[6] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000001: begin row_line_next[7] = 1; circle_cnt_next = circle_cnt + 1; end
			endcase
			casez({zero_e[4],zero_e[12],zero_e[20],zero_e[28],zero_e[36],zero_e[44],zero_e[52],zero_e[60]})
				'b10000000: circle_zero_next[4] = 1;
				'b01000000: circle_zero_next[12] = 1;
				'b00100000: circle_zero_next[20] = 1;
				'b00010000: circle_zero_next[28] = 1;
				'b00001000: circle_zero_next[36] = 1;
				'b00000100: circle_zero_next[44] = 1;
				'b00000010: circle_zero_next[52] = 1;
				'b00000001: circle_zero_next[60] = 1;
			endcase
		end
		S_circle+14: begin
			casez({zero_e[5],zero_e[13],zero_e[21],zero_e[29],zero_e[37],zero_e[45],zero_e[53],zero_e[61]})
				'b10000000: begin row_line_next[0] = 1; circle_cnt_next = circle_cnt + 1; end
				'b01000000: begin row_line_next[1] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00100000: begin row_line_next[2] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00010000: begin row_line_next[3] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00001000: begin row_line_next[4] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000100: begin row_line_next[5] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000010: begin row_line_next[6] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000001: begin row_line_next[7] = 1; circle_cnt_next = circle_cnt + 1; end
			endcase
			casez({zero_e[5],zero_e[13],zero_e[21],zero_e[29],zero_e[37],zero_e[45],zero_e[53],zero_e[61]})
				'b10000000: circle_zero_next[5] = 1;
				'b01000000: circle_zero_next[13] = 1;
				'b00100000: circle_zero_next[21] = 1;
				'b00010000: circle_zero_next[29] = 1;
				'b00001000: circle_zero_next[37] = 1;
				'b00000100: circle_zero_next[45] = 1;
				'b00000010: circle_zero_next[53] = 1;
				'b00000001: circle_zero_next[61] = 1;
			endcase
		end
		S_circle+15: begin
			casez({zero_e[6],zero_e[14],zero_e[22],zero_e[30],zero_e[38],zero_e[46],zero_e[54],zero_e[62]})
				'b10000000: begin row_line_next[0] = 1; circle_cnt_next = circle_cnt + 1; end
				'b01000000: begin row_line_next[1] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00100000: begin row_line_next[2] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00010000: begin row_line_next[3] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00001000: begin row_line_next[4] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000100: begin row_line_next[5] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000010: begin row_line_next[6] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000001: begin row_line_next[7] = 1; circle_cnt_next = circle_cnt + 1; end
			endcase
			casez({zero_e[6],zero_e[14],zero_e[22],zero_e[30],zero_e[38],zero_e[46],zero_e[54],zero_e[62]})
				'b10000000: circle_zero_next[6] = 1;
				'b01000000: circle_zero_next[14] = 1;
				'b00100000: circle_zero_next[22] = 1;
				'b00010000: circle_zero_next[30] = 1;
				'b00001000: circle_zero_next[38] = 1;
				'b00000100: circle_zero_next[46] = 1;
				'b00000010: circle_zero_next[54] = 1;
				'b00000001: circle_zero_next[62] = 1;
			endcase
		end
		S_circle+16: begin
			casez({zero_e[7],zero_e[15],zero_e[23],zero_e[31],zero_e[39],zero_e[47],zero_e[55],zero_e[63]})
				'b10000000: begin row_line_next[0] = 1; circle_cnt_next = circle_cnt + 1; end
				'b01000000: begin row_line_next[1] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00100000: begin row_line_next[2] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00010000: begin row_line_next[3] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00001000: begin row_line_next[4] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000100: begin row_line_next[5] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000010: begin row_line_next[6] = 1; circle_cnt_next = circle_cnt + 1; end
				'b00000001: begin row_line_next[7] = 1; circle_cnt_next = circle_cnt + 1; end
			endcase
			casez({zero_e[7],zero_e[15],zero_e[23],zero_e[31],zero_e[39],zero_e[47],zero_e[55],zero_e[63]})
				'b10000000: circle_zero_next[7] = 1;
				'b01000000: circle_zero_next[15] = 1;
				'b00100000: circle_zero_next[23] = 1;
				'b00010000: circle_zero_next[31] = 1;
				'b00001000: circle_zero_next[39] = 1;
				'b00000100: circle_zero_next[47] = 1;
				'b00000010: circle_zero_next[55] = 1;
				'b00000001: circle_zero_next[63] = 1;
			endcase
		end
		S_redraw: begin // 92
			for(int i=0; i<8; i=i+1) row_check_next[i] = ~|{circle_zero[i*8],circle_zero[i*8+1],circle_zero[i*8+2],circle_zero[i*8+3],circle_zero[i*8+4],circle_zero[i*8+5],circle_zero[i*8+6],circle_zero[i*8+7]};
			col_check_next = '0;
		end
		S_redraw+1: begin // 93
			// checking
			row_line_next = ~row_check_next;
			col_line_next = col_check_next;
		end
		S_morezero+1: begin
			for(int j=0; j<8; j=j+1)
				for(int i=0; i<8; i=i+1)
					array_next[j*8+i] = array[j*8+i] - (all_min & {6{!row_line[j]}})+ (all_min & {6{col_line[i]}});
		end
		S_left_zero: begin
			casez({zero_e[0],zero_e[1],zero_e[2],zero_e[3],zero_e[4],zero_e[5],zero_e[6],zero_e[7]})
				'b1???????: begin col_line_next[0] = 1; row_line_next[0] = 1; circle_cnt_next = circle_cnt + 1;end
				'b01??????: begin col_line_next[1] = 1; row_line_next[0] = 1; circle_cnt_next = circle_cnt + 1;end
				'b001?????: begin col_line_next[2] = 1; row_line_next[0] = 1; circle_cnt_next = circle_cnt + 1;end
				'b0001????: begin col_line_next[3] = 1; row_line_next[0] = 1; circle_cnt_next = circle_cnt + 1;end
				'b00001???: begin col_line_next[4] = 1; row_line_next[0] = 1; circle_cnt_next = circle_cnt + 1;end
				'b000001??: begin col_line_next[5] = 1; row_line_next[0] = 1; circle_cnt_next = circle_cnt + 1;end
				'b0000001?: begin col_line_next[6] = 1; row_line_next[0] = 1; circle_cnt_next = circle_cnt + 1;end
				'b00000001: begin col_line_next[7] = 1; row_line_next[0] = 1; circle_cnt_next = circle_cnt + 1;end
			endcase
			casez({zero_e[0],zero_e[1],zero_e[2],zero_e[3],zero_e[4],zero_e[5],zero_e[6],zero_e[7]})
				'b1???????: circle_zero_next[0] = 1;
				'b01??????: circle_zero_next[1] = 1;
				'b001?????: circle_zero_next[2] = 1;
				'b0001????: circle_zero_next[3] = 1;
				'b00001???: circle_zero_next[4] = 1;
				'b000001??: circle_zero_next[5] = 1;
				'b0000001?: circle_zero_next[6] = 1;
				'b00000001: circle_zero_next[7] = 1;
			endcase
		end
		S_left_zero+1: begin
			casez({zero_e[8],zero_e[9],zero_e[10],zero_e[11],zero_e[12],zero_e[13],zero_e[14],zero_e[15]})
				'b1???????: begin col_line_next[0] = 1; row_line_next[1] = 1; circle_cnt_next = circle_cnt + 1;end
				'b01??????: begin col_line_next[1] = 1; row_line_next[1] = 1; circle_cnt_next = circle_cnt + 1;end
				'b001?????: begin col_line_next[2] = 1; row_line_next[1] = 1; circle_cnt_next = circle_cnt + 1;end
				'b0001????: begin col_line_next[3] = 1; row_line_next[1] = 1; circle_cnt_next = circle_cnt + 1;end
				'b00001???: begin col_line_next[4] = 1; row_line_next[1] = 1; circle_cnt_next = circle_cnt + 1;end
				'b000001??: begin col_line_next[5] = 1; row_line_next[1] = 1; circle_cnt_next = circle_cnt + 1;end
				'b0000001?: begin col_line_next[6] = 1; row_line_next[1] = 1; circle_cnt_next = circle_cnt + 1;end
				'b00000001: begin col_line_next[7] = 1; row_line_next[1] = 1; circle_cnt_next = circle_cnt + 1;end
			endcase
			casez({zero_e[8],zero_e[9],zero_e[10],zero_e[11],zero_e[12],zero_e[13],zero_e[14],zero_e[15]})
				'b1???????: circle_zero_next[8] = 1;
				'b01??????: circle_zero_next[9] = 1;
				'b001?????: circle_zero_next[10] = 1;
				'b0001????: circle_zero_next[11] = 1;
				'b00001???: circle_zero_next[12] = 1;
				'b000001??: circle_zero_next[13] = 1;
				'b0000001?: circle_zero_next[14] = 1;
				'b00000001: circle_zero_next[15] = 1;
			endcase
		end
		S_left_zero+2: begin
			casez({zero_e[16],zero_e[17],zero_e[18],zero_e[19],zero_e[20],zero_e[21],zero_e[22],zero_e[23]})
				'b1???????: begin col_line_next[0] = 1; row_line_next[2] = 1; circle_cnt_next = circle_cnt + 1;end
				'b01??????: begin col_line_next[1] = 1; row_line_next[2] = 1; circle_cnt_next = circle_cnt + 1;end
				'b001?????: begin col_line_next[2] = 1; row_line_next[2] = 1; circle_cnt_next = circle_cnt + 1;end
				'b0001????: begin col_line_next[3] = 1; row_line_next[2] = 1; circle_cnt_next = circle_cnt + 1;end
				'b00001???: begin col_line_next[4] = 1; row_line_next[2] = 1; circle_cnt_next = circle_cnt + 1;end
				'b000001??: begin col_line_next[5] = 1; row_line_next[2] = 1; circle_cnt_next = circle_cnt + 1;end
				'b0000001?: begin col_line_next[6] = 1; row_line_next[2] = 1; circle_cnt_next = circle_cnt + 1;end
				'b00000001: begin col_line_next[7] = 1; row_line_next[2] = 1; circle_cnt_next = circle_cnt + 1;end
			endcase
			casez({zero_e[16],zero_e[17],zero_e[18],zero_e[19],zero_e[20],zero_e[21],zero_e[22],zero_e[23]})
				'b1???????: circle_zero_next[16] = 1;
				'b01??????: circle_zero_next[17] = 1;
				'b001?????: circle_zero_next[18] = 1;
				'b0001????: circle_zero_next[19] = 1;
				'b00001???: circle_zero_next[20] = 1;
				'b000001??: circle_zero_next[21] = 1;
				'b0000001?: circle_zero_next[22] = 1;
				'b00000001: circle_zero_next[23] = 1;
			endcase
		end
		S_left_zero+3: begin
			casez({zero_e[24],zero_e[25],zero_e[26],zero_e[27],zero_e[28],zero_e[29],zero_e[30],zero_e[31]})
				'b1???????: begin col_line_next[0] = 1; row_line_next[3] = 1; circle_cnt_next = circle_cnt + 1;end
				'b01??????: begin col_line_next[1] = 1; row_line_next[3] = 1; circle_cnt_next = circle_cnt + 1;end
				'b001?????: begin col_line_next[2] = 1; row_line_next[3] = 1; circle_cnt_next = circle_cnt + 1;end
				'b0001????: begin col_line_next[3] = 1; row_line_next[3] = 1; circle_cnt_next = circle_cnt + 1;end
				'b00001???: begin col_line_next[4] = 1; row_line_next[3] = 1; circle_cnt_next = circle_cnt + 1;end
				'b000001??: begin col_line_next[5] = 1; row_line_next[3] = 1; circle_cnt_next = circle_cnt + 1;end
				'b0000001?: begin col_line_next[6] = 1; row_line_next[3] = 1; circle_cnt_next = circle_cnt + 1;end
				'b00000001: begin col_line_next[7] = 1; row_line_next[3] = 1; circle_cnt_next = circle_cnt + 1;end
			endcase
			casez({zero_e[24],zero_e[25],zero_e[26],zero_e[27],zero_e[28],zero_e[29],zero_e[30],zero_e[31]})
				'b1???????: circle_zero_next[24] = 1;
				'b01??????: circle_zero_next[25] = 1;
				'b001?????: circle_zero_next[26] = 1;
				'b0001????: circle_zero_next[27] = 1;
				'b00001???: circle_zero_next[28] = 1;
				'b000001??: circle_zero_next[29] = 1;
				'b0000001?: circle_zero_next[30] = 1;
				'b00000001: circle_zero_next[31] = 1;
			endcase
		end
		S_left_zero+4: begin
			casez({zero_e[32],zero_e[33],zero_e[34],zero_e[35],zero_e[36],zero_e[37],zero_e[38],zero_e[39]})
				'b1???????: begin col_line_next[0] = 1; row_line_next[4] = 1; circle_cnt_next = circle_cnt + 1;end
				'b01??????: begin col_line_next[1] = 1; row_line_next[4] = 1; circle_cnt_next = circle_cnt + 1;end
				'b001?????: begin col_line_next[2] = 1; row_line_next[4] = 1; circle_cnt_next = circle_cnt + 1;end
				'b0001????: begin col_line_next[3] = 1; row_line_next[4] = 1; circle_cnt_next = circle_cnt + 1;end
				'b00001???: begin col_line_next[4] = 1; row_line_next[4] = 1; circle_cnt_next = circle_cnt + 1;end
				'b000001??: begin col_line_next[5] = 1; row_line_next[4] = 1; circle_cnt_next = circle_cnt + 1;end
				'b0000001?: begin col_line_next[6] = 1; row_line_next[4] = 1; circle_cnt_next = circle_cnt + 1;end
				'b00000001: begin col_line_next[7] = 1; row_line_next[4] = 1; circle_cnt_next = circle_cnt + 1;end
			endcase
			casez({zero_e[32],zero_e[33],zero_e[34],zero_e[35],zero_e[36],zero_e[37],zero_e[38],zero_e[39]})
				'b1???????: circle_zero_next[32] = 1;
				'b01??????: circle_zero_next[33] = 1;
				'b001?????: circle_zero_next[34] = 1;
				'b0001????: circle_zero_next[35] = 1;
				'b00001???: circle_zero_next[36] = 1;
				'b000001??: circle_zero_next[37] = 1;
				'b0000001?: circle_zero_next[38] = 1;
				'b00000001: circle_zero_next[39] = 1;
			endcase
		end
		S_left_zero+5: begin
			casez({zero_e[40],zero_e[41],zero_e[42],zero_e[43],zero_e[44],zero_e[45],zero_e[46],zero_e[47]})
				'b1???????: begin col_line_next[0] = 1; row_line_next[5] = 1; circle_cnt_next = circle_cnt + 1;end
				'b01??????: begin col_line_next[1] = 1; row_line_next[5] = 1; circle_cnt_next = circle_cnt + 1;end
				'b001?????: begin col_line_next[2] = 1; row_line_next[5] = 1; circle_cnt_next = circle_cnt + 1;end
				'b0001????: begin col_line_next[3] = 1; row_line_next[5] = 1; circle_cnt_next = circle_cnt + 1;end
				'b00001???: begin col_line_next[4] = 1; row_line_next[5] = 1; circle_cnt_next = circle_cnt + 1;end
				'b000001??: begin col_line_next[5] = 1; row_line_next[5] = 1; circle_cnt_next = circle_cnt + 1;end
				'b0000001?: begin col_line_next[6] = 1; row_line_next[5] = 1; circle_cnt_next = circle_cnt + 1;end
				'b00000001: begin col_line_next[7] = 1; row_line_next[5] = 1; circle_cnt_next = circle_cnt + 1;end
			endcase
			casez({zero_e[40],zero_e[41],zero_e[42],zero_e[43],zero_e[44],zero_e[45],zero_e[46],zero_e[47]})
				'b1???????: circle_zero_next[40] = 1;
				'b01??????: circle_zero_next[41] = 1;
				'b001?????: circle_zero_next[42] = 1;
				'b0001????: circle_zero_next[43] = 1;
				'b00001???: circle_zero_next[44] = 1;
				'b000001??: circle_zero_next[45] = 1;
				'b0000001?: circle_zero_next[46] = 1;
				'b00000001: circle_zero_next[47] = 1;
			endcase
		end
		S_left_zero+6: begin
			casez({zero_e[48],zero_e[49],zero_e[50],zero_e[51],zero_e[52],zero_e[53],zero_e[54],zero_e[55]})
				'b1???????: begin col_line_next[0] = 1; row_line_next[6] = 1; circle_cnt_next = circle_cnt + 1;end
				'b01??????: begin col_line_next[1] = 1; row_line_next[6] = 1; circle_cnt_next = circle_cnt + 1;end
				'b001?????: begin col_line_next[2] = 1; row_line_next[6] = 1; circle_cnt_next = circle_cnt + 1;end
				'b0001????: begin col_line_next[3] = 1; row_line_next[6] = 1; circle_cnt_next = circle_cnt + 1;end
				'b00001???: begin col_line_next[4] = 1; row_line_next[6] = 1; circle_cnt_next = circle_cnt + 1;end
				'b000001??: begin col_line_next[5] = 1; row_line_next[6] = 1; circle_cnt_next = circle_cnt + 1;end
				'b0000001?: begin col_line_next[6] = 1; row_line_next[6] = 1; circle_cnt_next = circle_cnt + 1;end
				'b00000001: begin col_line_next[7] = 1; row_line_next[6] = 1; circle_cnt_next = circle_cnt + 1;end
			endcase
			casez({zero_e[48],zero_e[49],zero_e[50],zero_e[51],zero_e[52],zero_e[53],zero_e[54],zero_e[55]})
				'b1???????: circle_zero_next[48] = 1;
				'b01??????: circle_zero_next[49] = 1;
				'b001?????: circle_zero_next[50] = 1;
				'b0001????: circle_zero_next[51] = 1;
				'b00001???: circle_zero_next[52] = 1;
				'b000001??: circle_zero_next[53] = 1;
				'b0000001?: circle_zero_next[54] = 1;
				'b00000001: circle_zero_next[55] = 1;
			endcase
		end
		S_left_zero+7: begin
			casez({zero_e[56],zero_e[57],zero_e[58],zero_e[59],zero_e[60],zero_e[61],zero_e[62],zero_e[63]})
				'b1???????: begin col_line_next[0] = 1; row_line_next[7] = 1; circle_cnt_next = circle_cnt + 1;end
				'b01??????: begin col_line_next[1] = 1; row_line_next[7] = 1; circle_cnt_next = circle_cnt + 1;end
				'b001?????: begin col_line_next[2] = 1; row_line_next[7] = 1; circle_cnt_next = circle_cnt + 1;end
				'b0001????: begin col_line_next[3] = 1; row_line_next[7] = 1; circle_cnt_next = circle_cnt + 1;end
				'b00001???: begin col_line_next[4] = 1; row_line_next[7] = 1; circle_cnt_next = circle_cnt + 1;end
				'b000001??: begin col_line_next[5] = 1; row_line_next[7] = 1; circle_cnt_next = circle_cnt + 1;end
				'b0000001?: begin col_line_next[6] = 1; row_line_next[7] = 1; circle_cnt_next = circle_cnt + 1;end
				'b00000001: begin col_line_next[7] = 1; row_line_next[7] = 1; circle_cnt_next = circle_cnt + 1;end
			endcase
			casez({zero_e[56],zero_e[57],zero_e[58],zero_e[59],zero_e[60],zero_e[61],zero_e[62],zero_e[63]})
				'b1???????: circle_zero_next[56] = 1;
				'b01??????: circle_zero_next[57] = 1;
				'b0001????: circle_zero_next[58] = 1;
				'b0001????: circle_zero_next[59] = 1;
				'b00001???: circle_zero_next[60] = 1;
				'b000001??: circle_zero_next[61] = 1;
				'b0000001?: circle_zero_next[62] = 1;
				'b00000001: circle_zero_next[63] = 1;
			endcase
		end
		//=================================================================================
		// assign start DFS
		//=================================================================================
		S_assign: begin
			col_line_next = '0;
			row_line_next = '0;
			circle_cnt_next = 0;
			for(int i=0; i<8; i=i+1) job_next[i] = 0;
		end
		S_assign1: begin
			casez({zero_e[0],zero_e[1],zero_e[2],zero_e[3],zero_e[4],zero_e[5],zero_e[6],zero_e[7]} & job_mask[0])
				'b1???????: col_line_next[0] = 1;
				'b01??????: begin
					col_line_next[1] = 1;
					if(backward_pip)
						if(job[0] == 0)
							col_line_next[0] = 0;
				end
				'b001?????: begin
					col_line_next[2] = 1;
					if(backward_pip)
						for(int i=0; i<2; i=i+1)
							if(job[0] == i) 
								col_line_next[i] = 0;
				end
				'b0001????: begin
					col_line_next[3] = 1;
					if(backward_pip)
						for(int i=0; i<3; i=i+1)
							if(job[0] == i) 
								col_line_next[i] = 0;
				end
				'b00001???: begin
					col_line_next[4] = 1;
					if(backward_pip)
						for(int i=0; i<4; i=i+1)
							if(job[0] == i) 
								col_line_next[i] = 0;
				end
				'b000001??: begin
					col_line_next[5] = 1;
					if(backward_pip)
						for(int i=0; i<5; i=i+1)
							if(job[0] == i) 
								col_line_next[i] = 0;
				end
				'b0000001?: begin
					col_line_next[6] = 1;
					if(backward_pip)
						for(int i=0; i<6; i=i+1)
							if(job[0] == i) 
								col_line_next[i] = 0;
				end
				'b00000001: begin
					col_line_next[7] = 1;
					if(backward_pip)
						for(int i=0; i<7; i=i+1)
							if(job[0] == i) 
								col_line_next[i] = 0;
				end
				default:
					if(backward_pip)
						for(int i=0; i<8; i=i+1)
							if(job[0] == i)
								col_line_next[i] = 0;
			endcase
			casez({zero_e[0],zero_e[1],zero_e[2],zero_e[3],zero_e[4],zero_e[5],zero_e[6],zero_e[7]} & job_mask[0])
				'b1???????: job_next[0] = 0;
				'b01??????: job_next[0] = 1;
				'b001?????: job_next[0] = 2;
				'b0001????: job_next[0] = 3;
				'b00001???: job_next[0] = 4;
				'b000001??: job_next[0] = 5;
				'b0000001?: job_next[0] = 6;
				'b00000001: job_next[0] = 7;
				//default: backward = 1;
			endcase
		end
		S_assign2: begin
			casez({zero_e[8],zero_e[9],zero_e[10],zero_e[11],zero_e[12],zero_e[13],zero_e[14],zero_e[15]} & job_mask[1])
				'b1???????: col_line_next[0] = 1;
				'b01??????: begin
					col_line_next[1] = 1;
					if(backward_pip)
						if(job[1] == 0)
							col_line_next[0] = 0;
				end
				'b001?????: begin
					col_line_next[2] = 1;
					if(backward_pip)
						for(int i=0; i<2; i=i+1)
							if(job[1] == i) 
								col_line_next[i] = 0;
				end
				'b0001????: begin
					col_line_next[3] = 1;
					if(backward_pip)
						for(int i=0; i<3; i=i+1)
							if(job[1] == i) 
								col_line_next[i] = 0;
				end
				'b00001???: begin
					col_line_next[4] = 1;
					if(backward_pip)
						for(int i=0; i<4; i=i+1)
							if(job[1] == i) 
								col_line_next[i] = 0;
				end
				'b000001??: begin
					col_line_next[5] = 1;
					if(backward_pip)
						for(int i=0; i<5; i=i+1)
							if(job[1] == i) 
								col_line_next[i] = 0;
				end
				'b0000001?: begin
					col_line_next[6] = 1;
					if(backward_pip)
						for(int i=0; i<6; i=i+1)
							if(job[1] == i) 
								col_line_next[i] = 0;
				end
				'b00000001: begin
					col_line_next[7] = 1;
					if(backward_pip)
						for(int i=0; i<7; i=i+1)
							if(job[1] == i) 
								col_line_next[i] = 0;
				end
				default:
					if(backward_pip)
						for(int i=0; i<8; i=i+1)
							if(job[1] == i) 
								col_line_next[i] = 0;
			endcase
			casez({zero_e[8],zero_e[9],zero_e[10],zero_e[11],zero_e[12],zero_e[13],zero_e[14],zero_e[15]} & job_mask[1])
				'b1???????: job_next[1] = 0;
				'b01??????: job_next[1] = 1;
				'b001?????: job_next[1] = 2;
				'b0001????: job_next[1] = 3;
				'b00001???: job_next[1] = 4;
				'b000001??: job_next[1] = 5;
				'b0000001?: job_next[1] = 6;
				'b00000001: job_next[1] = 7;
				default: backward = 1;
			endcase
		end
		S_assign3: begin
			casez({zero_e[16],zero_e[17],zero_e[18],zero_e[19],zero_e[20],zero_e[21],zero_e[22],zero_e[23]} & job_mask[2])
				'b1???????: col_line_next[0] = 1;
				'b01??????: begin
					col_line_next[1] = 1;
					if(backward_pip)
						if(job[2] == 0)
							col_line_next[0] = 0;
				end
				'b001?????: begin
					col_line_next[2] = 1;
					if(backward_pip)
						for(int i=0; i<2; i=i+1)
							if(job[2] == i) 
								col_line_next[i] = 0;
				end
				'b0001????: begin
					col_line_next[3] = 1;
					if(backward_pip)
						for(int i=0; i<3; i=i+1)
							if(job[2] == i) 
								col_line_next[i] = 0;
				end
				'b00001???: begin
					col_line_next[4] = 1;
					if(backward_pip)
						for(int i=0; i<4; i=i+1)
							if(job[2] == i) 
								col_line_next[i] = 0;
				end
				'b000001??: begin
					col_line_next[5] = 1;
					if(backward_pip)
						for(int i=0; i<5; i=i+1)
							if(job[2] == i) 
								col_line_next[i] = 0;
				end
				'b0000001?: begin
					col_line_next[6] = 1;
					if(backward_pip)
						for(int i=0; i<6; i=i+1)
							if(job[2] == i) 
								col_line_next[i] = 0;
				end
				'b00000001: begin
					col_line_next[7] = 1;
					if(backward_pip)
						for(int i=0; i<7; i=i+1)
							if(job[2] == i) 
								col_line_next[i] = 0;
				end
				default:
					if(backward_pip)
						for(int i=0; i<8; i=i+1)
							if(job[2] == i) 
								col_line_next[i] = 0;
			endcase
			casez({zero_e[16],zero_e[17],zero_e[18],zero_e[19],zero_e[20],zero_e[21],zero_e[22],zero_e[23]} & job_mask[2])
				'b1???????: job_next[2] = 0;
				'b01??????: job_next[2] = 1;
				'b001?????: job_next[2] = 2;
				'b0001????: job_next[2] = 3;
				'b00001???: job_next[2] = 4;
				'b000001??: job_next[2] = 5;
				'b0000001?: job_next[2] = 6;
				'b00000001: job_next[2] = 7;
				default: backward = 1;
			endcase
		end
		S_assign4: begin
			casez({zero_e[24],zero_e[25],zero_e[26],zero_e[27],zero_e[28],zero_e[29],zero_e[30],zero_e[31]} & job_mask[3])
				'b1???????: col_line_next[0] = 1;
				'b01??????: begin
					col_line_next[1] = 1;
					if(backward_pip)
						if(job[3] == 0)
							col_line_next[0] = 0;
				end
				'b001?????: begin
					col_line_next[2] = 1;
					if(backward_pip)
						for(int i=0; i<2; i=i+1)
							if(job[3] == i) 
								col_line_next[i] = 0;
				end
				'b0001????: begin
					col_line_next[3] = 1;
					if(backward_pip)
						for(int i=0; i<3; i=i+1)
							if(job[3] == i) 
								col_line_next[i] = 0;
				end
				'b00001???: begin
					col_line_next[4] = 1;
					if(backward_pip)
						for(int i=0; i<4; i=i+1)
							if(job[3] == i) 
								col_line_next[i] = 0;
				end
				'b000001??: begin
					col_line_next[5] = 1;
					if(backward_pip)
						for(int i=0; i<5; i=i+1)
							if(job[3] == i) 
								col_line_next[i] = 0;
				end
				'b0000001?: begin
					col_line_next[6] = 1;
					if(backward_pip)
						for(int i=0; i<6; i=i+1)
							if(job[3] == i) 
								col_line_next[i] = 0;
				end
				'b00000001: begin
					col_line_next[7] = 1;
					if(backward_pip)
						for(int i=0; i<7; i=i+1)
							if(job[3] == i) 
								col_line_next[i] = 0;
				end
				default:
					if(backward_pip)
						for(int i=0; i<8; i=i+1)
							if(job[3] == i) 
								col_line_next[i] = 0;
			endcase
			casez({zero_e[24],zero_e[25],zero_e[26],zero_e[27],zero_e[28],zero_e[29],zero_e[30],zero_e[31]} & job_mask[3])
				'b1???????: job_next[3] = 0;
				'b01??????: job_next[3] = 1;
				'b001?????: job_next[3] = 2;
				'b0001????: job_next[3] = 3;
				'b00001???: job_next[3] = 4;
				'b000001??: job_next[3] = 5;
				'b0000001?: job_next[3] = 6;
				'b00000001: job_next[3] = 7;
				default: backward = 1;
			endcase
		end
		S_assign5: begin
			casez({zero_e[32],zero_e[33],zero_e[34],zero_e[35],zero_e[36],zero_e[37],zero_e[38],zero_e[39]} & job_mask[4])
				'b1???????: col_line_next[0] = 1;
				'b01??????: begin
					col_line_next[1] = 1;
					if(backward_pip)
						if(job[4] == 0)
							col_line_next[0] = 0;
				end
				'b001?????: begin
					col_line_next[2] = 1;
					if(backward_pip)
						for(int i=0; i<2; i=i+1)
							if(job[4] == i) 
								col_line_next[i] = 0;
				end
				'b0001????: begin
					col_line_next[3] = 1;
					if(backward_pip)
						for(int i=0; i<3; i=i+1)
							if(job[4] == i) 
								col_line_next[i] = 0;
				end
				'b00001???: begin
					col_line_next[4] = 1;
					if(backward_pip)
						for(int i=0; i<4; i=i+1)
							if(job[4] == i) 
								col_line_next[i] = 0;
				end
				'b000001??: begin
					col_line_next[5] = 1;
					if(backward_pip)
						for(int i=0; i<5; i=i+1)
							if(job[4] == i) 
								col_line_next[i] = 0;
				end
				'b0000001?: begin
					col_line_next[6] = 1;
					if(backward_pip)
						for(int i=0; i<6; i=i+1)
							if(job[4] == i) 
								col_line_next[i] = 0;
				end
				'b00000001: begin
					col_line_next[7] = 1;
					if(backward_pip)
						for(int i=0; i<7; i=i+1)
							if(job[4] == i) 
								col_line_next[i] = 0;
				end
				default:
					if(backward_pip)
						for(int i=0; i<8; i=i+1)
							if(job[4] == i) 
								col_line_next[i] = 0;
			endcase
			casez({zero_e[32],zero_e[33],zero_e[34],zero_e[35],zero_e[36],zero_e[37],zero_e[38],zero_e[39]} & job_mask[4])
				'b1???????: job_next[4] = 0;
				'b01??????: job_next[4] = 1;
				'b001?????: job_next[4] = 2;
				'b0001????: job_next[4] = 3;
				'b00001???: job_next[4] = 4;
				'b000001??: job_next[4] = 5;
				'b0000001?: job_next[4] = 6;
				'b00000001: job_next[4] = 7;
				default: backward = 1;
			endcase
		end
		S_assign6: begin
			casez({zero_e[40],zero_e[41],zero_e[42],zero_e[43],zero_e[44],zero_e[45],zero_e[46],zero_e[47]} & job_mask[5])
				'b1???????: col_line_next[0] = 1;
				'b01??????: begin
					col_line_next[1] = 1;
					if(backward_pip)
						if(job[5] == 0)
							col_line_next[0] = 0;
				end
				'b001?????: begin
					col_line_next[2] = 1;
					if(backward_pip)
						for(int i=0; i<2; i=i+1)
							if(job[5] == i) 
								col_line_next[i] = 0;
				end
				'b0001????: begin
					col_line_next[3] = 1;
					if(backward_pip)
						for(int i=0; i<3; i=i+1)
							if(job[5] == i) 
								col_line_next[i] = 0;
				end
				'b00001???: begin
					col_line_next[4] = 1;
					if(backward_pip)
						for(int i=0; i<4; i=i+1)
							if(job[5] == i) 
								col_line_next[i] = 0;
				end
				'b000001??: begin
					col_line_next[5] = 1;
					if(backward_pip)
						for(int i=0; i<5; i=i+1)
							if(job[5] == i) 
								col_line_next[i] = 0;
				end
				'b0000001?: begin
					col_line_next[6] = 1;
					if(backward_pip)
						for(int i=0; i<6; i=i+1)
							if(job[5] == i) 
								col_line_next[i] = 0;
				end
				'b00000001: begin
					col_line_next[7] = 1;
					if(backward_pip)
						for(int i=0; i<7; i=i+1)
							if(job[5] == i) 
								col_line_next[i] = 0;
				end
				default:
					if(backward_pip)
						for(int i=0; i<8; i=i+1)
							if(job[5] == i) 
								col_line_next[i] = 0;
			endcase
			casez({zero_e[40],zero_e[41],zero_e[42],zero_e[43],zero_e[44],zero_e[45],zero_e[46],zero_e[47]} & job_mask[5])
				'b1???????: job_next[5] = 0;
				'b01??????: job_next[5] = 1;
				'b001?????: job_next[5] = 2;
				'b0001????: job_next[5] = 3;
				'b00001???: job_next[5] = 4;
				'b000001??: job_next[5] = 5;
				'b0000001?: job_next[5] = 6;
				'b00000001: job_next[5] = 7;
				default: backward = 1;
			endcase
		end
		S_assign7: begin
			casez({zero_e[48],zero_e[49],zero_e[50],zero_e[51],zero_e[52],zero_e[53],zero_e[54],zero_e[55]} & job_mask[6])
				'b1???????: col_line_next[0] = 1;
				'b01??????: begin
					col_line_next[1] = 1;
					if(backward_pip)
						if(job[6] == 0)
							col_line_next[0] = 0;
				end
				'b001?????: begin
					col_line_next[2] = 1;
					if(backward_pip)
						for(int i=0; i<2; i=i+1)
							if(job[6] == i) 
								col_line_next[i] = 0;
				end
				'b0001????: begin
					col_line_next[3] = 1;
					if(backward_pip)
						for(int i=0; i<3; i=i+1)
							if(job[6] == i) 
								col_line_next[i] = 0;
				end
				'b00001???: begin
					col_line_next[4] = 1;
					if(backward_pip)
						for(int i=0; i<4; i=i+1)
							if(job[6] == i) 
								col_line_next[i] = 0;
				end
				'b000001??: begin
					col_line_next[5] = 1;
					if(backward_pip)
						for(int i=0; i<5; i=i+1)
							if(job[6] == i) 
								col_line_next[i] = 0;
				end
				'b0000001?: begin
					col_line_next[6] = 1;
					if(backward_pip)
						for(int i=0; i<6; i=i+1)
							if(job[6] == i) 
								col_line_next[i] = 0;
				end
				'b00000001: begin
					col_line_next[7] = 1;
					if(backward_pip)
						for(int i=0; i<7; i=i+1)
							if(job[6] == i) 
								col_line_next[i] = 0;
				end
				default:
					if(backward_pip)
						for(int i=0; i<8; i=i+1)
							if(job[6] == i) 
								col_line_next[i] = 0;
			endcase
			casez({zero_e[48],zero_e[49],zero_e[50],zero_e[51],zero_e[52],zero_e[53],zero_e[54],zero_e[55]} & job_mask[6])
				'b1???????: job_next[6] = 0;
				'b01??????: job_next[6] = 1;
				'b001?????: job_next[6] = 2;
				'b0001????: job_next[6] = 3;
				'b00001???: job_next[6] = 4;
				'b000001??: job_next[6] = 5;
				'b0000001?: job_next[6] = 6;
				'b00000001: job_next[6] = 7;
				default: backward = 1;
			endcase
		end
		S_assign8: begin
			casez({zero_e[56],zero_e[57],zero_e[58],zero_e[59],zero_e[60],zero_e[61],zero_e[62],zero_e[63]} & job_mask[7])
				'b1???????: col_line_next[0] = 1;
				'b01??????: begin
					col_line_next[1] = 1;
					if(backward_pip)
						if(job[7] == 0)
							col_line_next[0] = 0;
				end
				'b001?????: begin
					col_line_next[2] = 1;
					if(backward_pip)
						for(int i=0; i<2; i=i+1)
							if(job[7] == i) 
								col_line_next[i] = 0;
				end
				'b0001????: begin
					col_line_next[3] = 1;
					if(backward_pip)
						for(int i=0; i<3; i=i+1)
							if(job[7] == i) 
								col_line_next[i] = 0;
				end
				'b00001???: begin
					col_line_next[4] = 1;
					if(backward_pip)
						for(int i=0; i<4; i=i+1)
							if(job[7] == i) 
								col_line_next[i] = 0;
				end
				'b000001??: begin
					col_line_next[5] = 1;
					if(backward_pip)
						for(int i=0; i<5; i=i+1)
							if(job[7] == i) 
								col_line_next[i] = 0;
				end
				'b0000001?: begin
					col_line_next[6] = 1;
					if(backward_pip)
						for(int i=0; i<6; i=i+1)
							if(job[7] == i) 
								col_line_next[i] = 0;
				end
				'b00000001: begin
					col_line_next[7] = 1;
					if(backward_pip)
						for(int i=0; i<7; i=i+1)
							if(job[7] == i) 
								col_line_next[i] = 0;
				end
				default:
					if(backward_pip)
						for(int i=0; i<8; i=i+1)
							if(job[7] == i) 
								col_line_next[i] = 0;
			endcase
			casez({zero_e[56],zero_e[57],zero_e[58],zero_e[59],zero_e[60],zero_e[61],zero_e[62],zero_e[63]} & job_mask[7])
				'b1???????: job_next[7] = 0;
				'b01??????: job_next[7] = 1;
				'b001?????: job_next[7] = 2;
				'b0001????: job_next[7] = 3;
				'b00001???: job_next[7] = 4;
				'b000001??: job_next[7] = 5;
				'b0000001?: job_next[7] = 6;
				'b00000001: job_next[7] = 7;
				default: backward = 1;
			endcase
		end
	endcase
end

//---------------------------------------------------------------------
// Output
//---------------------------------------------------------------------

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		out_job <= 0;
		out_cost <= 0;
		out_valid <= 0;
	end
	else begin
		out_job <= out_job_next;
		out_cost <= out_cost_next;
		out_valid <= out_valid_next;
	end
end

always_comb begin
	casez(state)
		S_output: begin
			out_cost_next = total_cost;
			out_job_next = job[0] + 1;
			out_valid_next = 1;
		end
		S_output+1: begin
			out_cost_next = total_cost;
			out_job_next = job[1] + 1;
			out_valid_next = 1;
		end
		S_output+2: begin
			out_cost_next = total_cost;
			out_job_next = job[2] + 1;
			out_valid_next = 1;
		end
		S_output+3: begin
			out_cost_next = total_cost;
			out_job_next = job[3] + 1;
			out_valid_next = 1;
		end
		S_output+4: begin
			out_cost_next = total_cost;
			out_job_next = job[4] + 1;
			out_valid_next = 1;
		end
		S_output+5: begin
			out_cost_next = total_cost;
			out_job_next = job[5] + 1;
			out_valid_next = 1;
		end
		S_output+6: begin
			out_cost_next = total_cost;
			out_job_next = job[6] + 1;
			out_valid_next = 1;
		end
		S_output+7: begin
			out_cost_next = total_cost;
			out_job_next = job[7] + 1;
			out_valid_next = 1;
		end
		default: begin
			out_job_next = 0;
			out_cost_next = 0;
			out_valid_next = 0;
		end
	endcase
end

endmodule


//---------------------------------------------------------------------
// Modules
//---------------------------------------------------------------------

module MIN(col, row, num1, num2, num3, num4, num5, num6, num7, num8, min);
input col;
input[7:0] row;
input[7:0] num1;
input[7:0] num2;
input[7:0] num3;
input[7:0] num4;
input[7:0] num5;
input[7:0] num6;
input[7:0] num7;
input[7:0] num8;
output logic[6:0] min;

logic [7:0] num [7:0];
logic [7:0] num_check [7:0];
logic [7:0] cmp1 [3:0];
logic [7:0] cmp2 [1:0];
logic [7:0] min_pre;

always_comb begin
	num[0] = num1;
	num[1] = num2;
	num[2] = num3;
	num[3] = num4;
	num[4] = num5;
	num[5] = num6;
	num[6] = num7;
	num[7] = num8;
	for(int i=0; i<8; i=i+1) num_check[i] = row[i] ? '1 : num[i];
	for(int i=0; i<4; i=i+1) cmp1[i] = num_check[2*i] < num_check[2*i+1] ? num_check[2*i] : num_check[2*i+1];
	for(int i=0; i<2; i=i+1) cmp2[i] = cmp1[2*i] < cmp1[2*i+1] ? cmp1[2*i] : cmp1[2*i+1];
	min_pre = cmp2[0] < cmp2[1] ? cmp2[0] : cmp2[1];
	min = col? '1 : min_pre;
end

endmodule

module MIN2(num1, num2, num3, num4, num5, num6, num7, num8, min);
input[6:0] num1;
input[6:0] num2;
input[6:0] num3;
input[6:0] num4;
input[6:0] num5;
input[6:0] num6;
input[6:0] num7;
input[6:0] num8;
output logic[6:0] min;

logic [6:0] num [7:0];
logic [6:0] cmp1 [3:0];
logic [6:0] cmp2 [1:0];

always_comb begin
	num[0] = num1;
	num[1] = num2;
	num[2] = num3;
	num[3] = num4;
	num[4] = num5;
	num[5] = num6;
	num[6] = num7;
	num[7] = num8;
	for(int i=0; i<4; i=i+1) cmp1[i] = num[2*i] < num[2*i+1] ? num[2*i] : num[2*i+1];
	for(int i=0; i<2; i=i+1) cmp2[i] = cmp1[2*i] < cmp1[2*i+1] ? cmp1[2*i] : cmp1[2*i+1];
	min = cmp2[0] < cmp2[1] ? cmp2[0] : cmp2[1];
end

endmodule