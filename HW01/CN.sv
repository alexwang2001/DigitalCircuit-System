module CN(
    // Input signals
    opcode,
	in_n0,
	in_n1,
	in_n2,
	in_n3,
	in_n4,
	in_n5,
    // Output signals
    out_n
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [3:0] in_n0, in_n1, in_n2, in_n3, in_n4, in_n5;
input [4:0] opcode;
output logic [8:0] out_n;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
bit [4:0] sort_lay [5:0][4:0]; // sorting wire
bit [4:0] sorted [5:0]; // sorting result
logic [4:0] num [5:0];

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
register_file reg0(in_n0, sort_lay[0][0]);
register_file reg1(in_n1, sort_lay[1][0]);
register_file reg2(in_n2, sort_lay[2][0]);
register_file reg3(in_n3, sort_lay[3][0]);
register_file reg4(in_n4, sort_lay[4][0]);
register_file reg5(in_n5, sort_lay[5][0]);
// Sorting from large to small (sel: opcode[4]) + Reverse (sel: opcode[3])
//layer1
Sort3 sort3_1(sort_lay[0][0],sort_lay[1][0],sort_lay[2][0],sort_lay[0][1],sort_lay[1][1],sort_lay[2][1]);
Sort3 sort3_2(sort_lay[3][0],sort_lay[4][0],sort_lay[5][0],sort_lay[3][1],sort_lay[4][1],sort_lay[5][1]);
//layer2
Sort2 sort2_1(sort_lay[0][1],sort_lay[3][1],sort_lay[0][2],sort_lay[3][2]);
Sort2 sort2_2(sort_lay[1][1],sort_lay[4][1],sort_lay[1][2],sort_lay[4][2]);
Sort2 sort2_3(sort_lay[2][1],sort_lay[5][1],sort_lay[2][2],sort_lay[5][2]);
//layer3
Sort2 sort2_4(sort_lay[1][2],sort_lay[3][2],sort_lay[1][3],sort_lay[3][3]);
Sort2R sort2_5(sort_lay[2][2],sort_lay[4][2],sort_lay[2][3],sort_lay[4][3]);
//layer4
Sort2 sort2_6(sort_lay[2][3],sort_lay[3][3],sort_lay[2][4],sort_lay[3][4]);
assign {sort_lay[0][4],sort_lay[1][4],sort_lay[4][4],sort_lay[5][4]} = {sort_lay[0][2],sort_lay[1][3],sort_lay[4][3],sort_lay[5][2]};

genvar m;
generate
    // sort or not
    for(m=0; m<=5; m=m+1)
        assign sorted[m] = opcode[4]? sort_lay[m][4] : sort_lay[m][0];
    // reverse or not
    for(m=0; m<=5; m=m+1)
        assign num[m] = opcode[3]? sorted[5-m] : sorted[m];
endgenerate

// Calculation
always_comb begin
	case(opcode[2:0])
		3'b000: out_n = num[2] - num[1];
		3'b001: out_n = num[0] + num[3];
		3'b010: out_n = (({5{num[4][2]}} & num[3])<<1) + (({5{num[4][4]}} & num[3])<<3) + (({5{num[4][3]}} & num[3])<<2) + (({5{num[4][0]}} & num[3])>>1) + ({5{num[4][1]}} & num[3]);
		3'b011: out_n = (num[5]<<1) + num[1];
		3'b100: out_n = num[2] & num[1];
		3'b101: out_n = ~num[0];
		3'b110: out_n = num[4] ^ num[3];
		3'b111: out_n = num[1]<<1;
	endcase
end
endmodule

module Sort3(in0, in1, in2, out0, out1, out2);
    input [4:0] in0, in1, in2;
    output logic [4:0] out0, out1, out2;
    logic [4:0] lay[2:0][1:0];

    Sort2R sort2_1(in0, in1, lay[0][0], lay[1][0]);
    Sort2 sort2_2(lay[1][0], in2, lay[1][1], out2);
    Sort2 sort2_3(lay[0][1], lay[1][1], out0, out1);
    assign lay[0][1] = lay[0][0];
endmodule

module Sort2(in0, in1, out0, out1);
    input [4:0] in0, in1;
    output logic [4:0] out0, out1;
    assign {out0,out1} = in0 > in1? {in0,in1} : {in1,in0};
endmodule

module Sort2R(in0, in1, out0, out1);
    input [4:0] in0, in1;
    output logic [4:0] out0, out1;
    assign {out1,out0} = in1 > in0? {in0,in1} : {in1,in0};
endmodule

//AREA12723 //12723
//---------------------------------------------------------------------
//   Register design from TA (Do not modify, or demo fails)
//---------------------------------------------------------------------
module register_file(
    address,
    value
);
input [3:0] address;
output logic [4:0] value;

always_comb begin
    case(address)
    4'b0000:value = 5'd9;
    4'b0001:value = 5'd27;
    4'b0010:value = 5'd30;
    4'b0011:value = 5'd3;
    4'b0100:value = 5'd11;
    4'b0101:value = 5'd8;
    4'b0110:value = 5'd26;
    4'b0111:value = 5'd17;
    4'b1000:value = 5'd3;
    4'b1001:value = 5'd12;
    4'b1010:value = 5'd1;
    4'b1011:value = 5'd10;
    4'b1100:value = 5'd15;
    4'b1101:value = 5'd5;
    4'b1110:value = 5'd23;
    4'b1111:value = 5'd20;
    default: value = 0;
    endcase
end

endmodule
