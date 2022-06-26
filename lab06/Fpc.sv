
module Fpc(clk, rst_n, in_valid, mode, in_a, in_b, out_valid, out);
//input
input clk;
input rst_n;
input in_valid;
input mode;
input [15:0] in_a, in_b;
//output
output logic out_valid;
output logic [15:0] out;
//logic declare
logic [15:0] in_a_next, in_b_next;
logic [15:0] in_a_reg, in_b_reg;
logic [7:0] a_extend, b_extend;
logic [8:0] exp_sum;
logic [1:0] exp_diff;
logic [7:0] exp_larger;
logic [7:0] a_shifted, b_shifted;
logic [8:0] a_comp, b_comp;
logic [9:0] sum;
logic [9:0] sum_comp;
logic [16:0] prod;
logic [15:0] bfloat16_sum;
logic [15:0] bfloat16_prod;
logic [15:0] out_next;
logic [7:0] temp;
//FSM
parameter S_idle = 0;
parameter S_sum_1 = 1;
parameter S_sum_2 = 2;
parameter S_mul_1 = 3;
parameter S_mul_2 = 4;
logic [2:0] state;
logic [2:0] state_next;
always_ff @(posedge clk or negedge rst_n) begin : FSM
    if(!rst_n)
        state <= S_idle;
    else 
        state <= state_next;
end
always_comb begin : FSM_comb
    casez (state)
        S_idle: begin
            if(in_valid) begin
                if(mode == 0)
                    state_next = S_sum_1;
                else
                    state_next = S_mul_1;
            end
            else
                state_next = S_idle;
        end 
        S_mul_1: state_next = S_mul_2;
        S_sum_1: state_next = S_sum_2;
        S_mul_2, S_sum_2: state_next = S_idle; 
        default: state_next = S_idle;
    endcase
end

//design
assign in_a_next = in_valid? in_a : 0;
assign in_b_next = in_valid? in_b : 0;

always_ff @(posedge clk or negedge rst_n) begin : in_reg
    if(!rst_n) begin
        in_a_reg <= 0;
        in_b_reg <= 0;
    end
    else begin
        in_a_reg <= in_a_next;
        in_b_reg <= in_b_next;
    end
end

assign a_extend = {1'b1, in_a_reg[6:0]};
assign b_extend = {1'b1, in_b_reg[6:0]};

always_comb begin: shifting
    if(in_a_reg[14:7] > in_b_reg[14:7]) begin
        exp_diff = in_a_reg[14:7] - in_b_reg[14:7];
        exp_larger = in_a_reg[14:7];
        case (exp_diff)
            1: b_shifted = b_extend >> 1;
            2: b_shifted = b_extend >> 2;
            3: b_shifted = b_extend >> 3;
            default: b_shifted = b_extend;
        endcase
        a_shifted = a_extend;
    end    
    else begin
        exp_diff = in_b_reg[14:7] - in_a_reg[14:7];
        exp_larger = in_b_reg[14:7];
        case (exp_diff)
            0: a_shifted = a_extend;
            1: a_shifted = a_extend >> 1;
            2: a_shifted = a_extend >> 2;
            3: a_shifted = a_extend >> 3;
        endcase
        b_shifted = b_extend;
    end
end

always_comb begin : complement
    a_comp = in_a_reg[15]? ~a_shifted + 1 : a_shifted;
    b_comp = in_b_reg[15]? ~b_shifted + 1 : b_shifted;
end

assign sum = a_comp + b_comp;
always_comb begin
    if(in_a_reg[15] == 0 && in_b_reg[15] == 0) begin
        sum_comp = sum;
        bfloat16_sum[15] = 0;
    end 
    else if(in_a_reg[15] == 1 && in_b_reg[15] == 1) begin
        sum_comp = ~(sum-1);
        bfloat16_sum[15] = 1;
    end 
    else begin
        sum_comp = sum[8]? ~(sum[8:0]-1) : sum;
        bfloat16_sum[15] = sum[8];
    end
end
assign prod = a_extend * b_extend;

always_comb begin : bfloat16_encode
    //sum
    casez (sum_comp[8:0])
        9'b1????????: bfloat16_sum[14:7] = exp_larger + 1;
        9'b01???????: bfloat16_sum[14:7] = exp_larger;
        9'b001??????: bfloat16_sum[14:7] = exp_larger - 1;
        9'b0001?????: bfloat16_sum[14:7] = exp_larger - 2;
        9'b00001????: bfloat16_sum[14:7] = exp_larger - 3;
        9'b000001???: bfloat16_sum[14:7] = exp_larger - 4;
        9'b0000001??: bfloat16_sum[14:7] = exp_larger - 5;
        9'b00000001?: bfloat16_sum[14:7] = exp_larger - 6;
        9'b000000001: bfloat16_sum[14:7] = exp_larger - 7;
        9'b000000000: bfloat16_sum[14:7] = exp_larger - 8;
    endcase
    casez (sum_comp[8:0])
        9'b1????????: bfloat16_sum[6:0] = sum_comp[7:1];
        9'b01???????: bfloat16_sum[6:0] = sum_comp[6:0];
        9'b001??????: bfloat16_sum[6:0] = {sum_comp[5:0],1'd0};
        9'b0001?????: bfloat16_sum[6:0] = {sum_comp[4:0],2'd0};
        9'b00001????: bfloat16_sum[6:0] = {sum_comp[3:0],3'd0};
        9'b000001???: bfloat16_sum[6:0] = {sum_comp[2:0],4'd0};
        9'b0000001??: bfloat16_sum[6:0] = {sum_comp[1:0],5'd0};
        9'b00000001?: bfloat16_sum[6:0] = {sum_comp[0],6'd0};
        9'b000000001: bfloat16_sum[6:0] = 0;
        9'b000000000: bfloat16_sum[6:0] = 0;
    endcase
    //prod
    bfloat16_prod[15] = in_a_reg[15] ^ in_b_reg[15];
		
		exp_sum = in_a_reg[14:7] + in_b_reg[14:7] - 'd127;
    bfloat16_prod[14:7] = exp_sum + prod[15];
    
    casez (prod[15:0])
        16'b1???????????????: bfloat16_prod[6:0] = prod[14:8];
        16'b01??????????????: bfloat16_prod[6:0] = prod[13:7];
        16'b001?????????????: bfloat16_prod[6:0] = prod[12:6];
        16'b0001????????????: bfloat16_prod[6:0] = prod[11:5];
        16'b00001???????????: bfloat16_prod[6:0] = prod[10:4];
        16'b000001??????????: bfloat16_prod[6:0] = prod[9:3];
        16'b0000001?????????: bfloat16_prod[6:0] = prod[8:2];
        16'b00000001????????: bfloat16_prod[6:0] = prod[7:1];
        16'b000000001???????: bfloat16_prod[6:0] = prod[6:0];
        16'b0000000001??????: bfloat16_prod[6:0] = {prod[5:0],1'd0};
        16'b00000000001?????: bfloat16_prod[6:0] = {prod[4:0],2'd0};
        16'b000000000001????: bfloat16_prod[6:0] = {prod[3:0],3'd0};
        16'b0000000000001???: bfloat16_prod[6:0] = {prod[2:0],4'd0};
        16'b00000000000001??: bfloat16_prod[6:0] = {prod[1:0],5'd0};
        16'b000000000000001?: bfloat16_prod[6:0] = {prod[0],6'd0};
        default: bfloat16_prod[6:0] = 0;
    endcase
end

assign out_valid = (state == S_mul_2) | (state == S_sum_2);
always_ff @(posedge clk or negedge rst_n) begin : out_reg
    if(!rst_n)
        out <= 0;
    else
        out <= out_next;
end
always_comb begin : out_reg_comb
    if(state == S_mul_1)
        out_next = bfloat16_prod;
    else if(state == S_sum_1)
        out_next = bfloat16_sum;
    else 
        out_next = 0;
end

endmodule