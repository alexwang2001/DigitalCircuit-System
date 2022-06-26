module Sequence(clk, rst_n, in_data, in_state_reset, out_cur_state, out);
// input & output
//----------------------------
input in_data, in_state_reset;
input clk, rst_n;
output logic [2:0] out_cur_state;
output logic out;

// FSM state (do not modify)
//----------------------------
parameter S_0 = 3'd0;
parameter S_1 = 3'd1;
parameter S_2 = 3'd2;
parameter S_3 = 3'd3;
parameter S_4 = 3'd4;
parameter S_5 = 3'd5;
parameter S_6 = 3'd6;
parameter S_7 = 3'd7;

// logic declaration
//----------------------------
logic [2:0] cur_sta, next_sta;
logic [2:0] goto;

// code
//----------------------------

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cur_sta <= S_0;
    else 
        cur_sta <= next_sta; 
end

always_comb begin
    case(cur_sta)
        S_0: goto = (in_data == 1)? S_1:S_2;
        S_1: goto = (in_data == 1)? S_1:S_4;
        S_2: goto = (in_data == 1)? S_4:S_3;
        S_3: goto = (in_data == 1)? S_5:S_6;
        S_4: goto = (in_data == 1)? S_4:S_5;
        S_5: goto = (in_data == 1)? S_5:S_7;
        S_6: goto = (in_data == 1)? S_7:S_6;
        S_7: goto = S_7;
    endcase
    next_sta = in_state_reset? S_0 : goto;
end

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        out_cur_state <= S_0;
    else
        out_cur_state <= next_sta;
end

assign out = (cur_sta == S_7);

endmodule