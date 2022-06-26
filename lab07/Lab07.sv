
module Lab07(
    //input
    clk,
    rst_n,
    in_number,
    mode,
	in_valid,
    //output
    out_valid,
    out_result
);
//input 
input clk;
input rst_n;
input signed [3:0] in_number;
input [1:0] mode;
input in_valid;
//output
output logic out_valid;
output logic [6:0] out_result;
// logic
logic signed [3:0] in_reg [3:0];
logic signed [3:0] in_reg_next [3:0];
logic signed [3:0] sort_lay1 [3:0];
logic signed [3:0] sort_lay2 [3:0];
logic signed [3:0] sorted [3:0];

logic signed [6:0] result_next;

// FSM
logic [6:0] state;
logic [6:0] state_next;

always_ff @(posedge clk or negedge rst_n) begin : FSM
    if(!rst_n)
        state <= 0;
    else
        state <= state_next;
end
always_comb begin : FSM_comb
    casez(state)
        0: state_next = in_valid? 1 : 0;
        104: state_next = 0;
        default: state_next = state+1;
    endcase    
end

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        for(int i=0; i<4; i+=1) in_reg[i] <= 0;
    else
        for(int i=0; i<4; i+=1) in_reg[i] <= in_reg_next[i];
end
always_comb begin
    in_reg_next[3] = in_valid? in_number : in_reg[3];
    in_reg_next[2] = in_valid? in_reg[3] : in_reg[2];
    in_reg_next[1] = in_valid? in_reg[2] : in_reg[1];
    in_reg_next[0] = in_valid? in_reg[1] : in_reg[0];
end

always_comb begin :sorting
    //lay1
    {sort_lay1[0],sort_lay1[1]} = in_reg[0] < in_reg[1]? {in_reg[0],in_reg[1]} : {in_reg[1],in_reg[0]};
    {sort_lay1[2],sort_lay1[3]} = in_reg[2] < in_reg[3]? {in_reg[2],in_reg[3]} : {in_reg[3],in_reg[2]};
    //lay2
    {sort_lay2[0],sort_lay2[2]} = sort_lay1[0] < sort_lay1[2]? {sort_lay1[0],sort_lay1[2]} : {sort_lay1[2],sort_lay1[0]};
    {sort_lay2[1],sort_lay2[3]} = sort_lay1[1] < sort_lay1[3]? {sort_lay1[1],sort_lay1[3]} : {sort_lay1[3],sort_lay1[1]};
    //sorted
    {sorted[1],sorted[2]} = sort_lay2[1] < sort_lay2[2]? {sort_lay2[1],sort_lay2[2]} : {sort_lay2[2],sort_lay2[1]};
    sorted[0] = sort_lay2[0];
    sorted[3] = sort_lay2[3];
    // arith
    case(mode)
        0: result_next = sorted[0] + sorted[1];
        1: result_next = sorted[1] - sorted[0];
        2: result_next = sorted[3] - sorted[2];
        3: result_next = sorted[0] - sorted[3];
    endcase
end

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        out_result <= 0;
    else if(state == 103)
        out_result <= result_next;
    else 
        out_result <= 0;
end

assign out_valid = (state == 104);

endmodule