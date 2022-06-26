module Timer(
    // Input signals
    in,
	in_valid,
	rst_n,
	clk,
    // Output signals
    out_valid
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [4:0] in;
input in_valid,	rst_n,	clk;
output logic out_valid;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
wire [5:0] cnt;
logic [5:0] cnt_o;
wire [5:0] target;
logic [5:0] in_reg;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
assign cnt = in_valid ? {1'b0,target} : ((cnt_o==6'd0)? cnt_o : cnt_o - 6'd1);
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_o <= 6'd0;
    else
        cnt_o <= cnt;
end

assign target = in_valid ? in + 6'd1 : in_reg;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        in_reg <= 5'b00000;
    else
        in_reg <= target;
end
assign out_valid = (cnt_o[4:0] == 5'd1)? 1 : 0;

endmodule
