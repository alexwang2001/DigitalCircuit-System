
module MIPS(
    //input 
    clk,
    rst_n,
    in_valid,
    instruction,
	output_reg,
    //output
    out_valid,
    out_1,
	out_2,
	out_3,
	out_4,
	instruction_fail
);
//--------------------------------------------------------------------------------------------
// input 
//--------------------------------------------------------------------------------------------
input clk;
input rst_n;
input in_valid;
input [31:0] instruction;
input [19:0] output_reg;
//--------------------------------------------------------------------------------------------
// output
//--------------------------------------------------------------------------------------------
output logic out_valid, instruction_fail;
output logic [31:0] out_1, out_2, out_3, out_4;
//--------------------------------------------------------------------------------------------
// logic declare
//--------------------------------------------------------------------------------------------
// param
parameter addr0 = 5'b10001;
parameter addr1 = 5'b10010;
parameter addr2 = 5'b01000;
parameter addr3 = 5'b10111;
parameter addr4 = 5'b11111;
parameter addr5 = 5'b10000;
// instruction
logic [31:0] instruction_reg_in;
logic [31:0] instruction_reg;
logic [5:0] opcode;
logic [4:0] source_addr;
logic [4:0] target_addr;
logic [4:0] destination_addr;
logic [4:0] shamt;
logic [5:0] funct;
logic [15:0] imm;
// instruction wrong detect
logic instruction_wrong;
logic funct_error;
logic instruction_wrong_buf2;
logic instruction_wrong_buf2_outval;
// register
logic [31:0] register [5:0];
// addr decode
logic [5:0] sel_rs;
logic [5:0] sel_rt;
logic [5:0] sel_rd;
logic [5:0] sel_in_bus;
// ALU
logic [31:0] ALU_out;
// shifter
logic [31:0] shifter_out;
// in bus
logic [31:0] in_bus;
logic [31:0] s_bus;
logic [31:0] t_bus;
// data out
logic out_ena;
logic [31:0] out_reg [3:0];
// out valid buf
logic out_valid_buf1;
logic out_valid_buf2;
// out reg buf
logic [19:0] output_reg_buf1;
logic [19:0] output_reg_buf2;

//--------------------------------------------------------------------------------------------
//design
//--------------------------------------------------------------------------------------------
// instruction
assign instruction_reg_in = in_valid? instruction : 0;

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        instruction_reg <= 0;
    else
        instruction_reg <= instruction_reg_in;
end
assign {opcode,source_addr,target_addr,destination_addr,shamt,funct} = instruction_reg;
assign imm = instruction_reg[15:0];

// instruction wrong detect
always_comb begin
    casez(funct)
        'b100000, 'b100100, 'b100101, 'b100111, 'b000000, 'b000010: funct_error = 0;
        default: funct_error = 1;
    endcase
end
assign instruction_wrong = |{opcode[5:4],opcode[2:0]} | (sel_rs == 0) | (sel_rt == 0) | (!opcode[3] & (sel_rd == 0)) | (!opcode[3] & funct_error);

assign instruction_wrong_buf2_outval = instruction_wrong_buf2 & out_valid_buf2;
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        instruction_wrong_buf2 <= 0;
        //instruction_fail <= 0;
    end
    else begin
        instruction_wrong_buf2 <= instruction_wrong;
        //instruction_fail <= instruction_wrong_buf2_outval;
    end
end
assign instruction_fail = instruction_wrong_buf2_outval;
// register
Register32 reg0(.clk(clk), .rst_n(rst_n), .in(in_bus), .ena(sel_in_bus[0]), .out(register[0]));
Register32 reg1(.clk(clk), .rst_n(rst_n), .in(in_bus), .ena(sel_in_bus[1]), .out(register[1]));
Register32 reg2(.clk(clk), .rst_n(rst_n), .in(in_bus), .ena(sel_in_bus[2]), .out(register[2]));
Register32 reg3(.clk(clk), .rst_n(rst_n), .in(in_bus), .ena(sel_in_bus[3]), .out(register[3]));
Register32 reg4(.clk(clk), .rst_n(rst_n), .in(in_bus), .ena(sel_in_bus[4]), .out(register[4]));
Register32 reg5(.clk(clk), .rst_n(rst_n), .in(in_bus), .ena(sel_in_bus[5]), .out(register[5]));

// addr decode
AddrDecoder addr_source(.addr(source_addr), .sel(sel_rs));
AddrDecoder addr_target(.addr(target_addr), .sel(sel_rt));
AddrDecoder addr_destination(.addr(destination_addr), .sel(sel_rd));
assign sel_in_bus = (opcode[3]? sel_rt : sel_rd) & {6{!instruction_wrong}};

// ALU
ALU alu(.source(s_bus),.target(t_bus),.sel(funct[2:0]),.out(ALU_out));

// shifter
Shifter shift(.in(t_bus), .rs(funct[1]), .shamt(shamt), .out(shifter_out));

// bus
always_comb begin
    casez(source_addr)
        addr0: s_bus = register[0];
        addr1: s_bus = register[1];
        addr2: s_bus = register[2];
        addr3: s_bus = register[3];
        addr4: s_bus = register[4];
        addr5: s_bus = register[5];
        default: s_bus = 'x;
    endcase
    casez(target_addr)
        addr0: t_bus = register[0];
        addr1: t_bus = register[1];
        addr2: t_bus = register[2];
        addr3: t_bus = register[3];
        addr4: t_bus = register[4];
        addr5: t_bus = register[5];
        default: t_bus = 'x;
    endcase
    if(opcode[3])
        in_bus = imm + s_bus;
    else if(funct[5]) 
        in_bus = ALU_out;
    else
        in_bus = shifter_out;
end

// out reg buf
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        output_reg_buf1 <= 0;
        output_reg_buf2 <= 0;
    end
    else begin
        output_reg_buf1 <= output_reg;
        output_reg_buf2 <= output_reg_buf1;
    end
end

// data out
assign out_ena = !instruction_wrong_buf2 & out_valid_buf2;
DataMux datamux0(.addr(output_reg_buf2[4:0]), .dat0(register[0]), .dat1(register[1]), .dat2(register[2]), .dat3(register[3]), .dat4(register[4]), .dat5(register[5]), .ena(out_ena), .out(out_reg[0]));
DataMux datamux1(.addr(output_reg_buf2[9:5]), .dat0(register[0]), .dat1(register[1]), .dat2(register[2]), .dat3(register[3]), .dat4(register[4]), .dat5(register[5]), .ena(out_ena), .out(out_reg[1]));
DataMux datamux2(.addr(output_reg_buf2[14:10]), .dat0(register[0]), .dat1(register[1]), .dat2(register[2]), .dat3(register[3]), .dat4(register[4]), .dat5(register[5]), .ena(out_ena), .out(out_reg[2]));
DataMux datamux3(.addr(output_reg_buf2[19:15]), .dat0(register[0]), .dat1(register[1]), .dat2(register[2]), .dat3(register[3]), .dat4(register[4]), .dat5(register[5]), .ena(out_ena), .out(out_reg[3]));
/*
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_1 <= 0;
        out_2 <= 0;
        out_3 <= 0;
        out_4 <= 0;
    end
    else begin
        out_1 <= out_reg[0];
        out_2 <= out_reg[1];
        out_3 <= out_reg[2];
        out_4 <= out_reg[3];
    end
end
*/
always_comb begin
    out_1 = out_reg[0];
    out_2 = out_reg[1];
    out_3 = out_reg[2];
    out_4 = out_reg[3];
end

// out valid
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid_buf1 <= 0;
        out_valid_buf2 <= 0;
        //out_valid <= 0;
    end
    else begin
        out_valid_buf1 <= in_valid;
        out_valid_buf2 <= out_valid_buf1;
        //out_valid <= out_valid_buf2;
    end
end
assign out_valid = out_valid_buf2;
endmodule

//--------------------------------------------------------------------------------------------
// modules
//--------------------------------------------------------------------------------------------

module ALU(source, target, sel, out);
input [31:0] source, target;
input [2:0] sel;
output logic [31:0] out;
always_comb begin
    casez(sel)
        3'b000: out = source + target;
        3'b100: out = source & target;
        3'b101: out = source | target;
        3'b111: out = ~(source | target);
        default: out = 'x;
    endcase
end
endmodule

module Shifter(in, rs, shamt, out);
input [31:0] in;
input rs;
input [4:0] shamt;
output logic [31:0] out;
always_comb begin
    if(rs)
        out = in>>shamt;
    else
        out = in<<shamt;
end
endmodule

module AddrDecoder(addr, sel);
input [4:0] addr;
output logic [5:0] sel;
parameter addr0 = 5'b10001;
parameter addr1 = 5'b10010;
parameter addr2 = 5'b01000;
parameter addr3 = 5'b10111;
parameter addr4 = 5'b11111;
parameter addr5 = 5'b10000;
always_comb begin
    casez(addr)
        addr0: sel = 6'b000001;
        addr1: sel = 6'b000010;
        addr2: sel = 6'b000100;
        addr3: sel = 6'b001000;
        addr4: sel = 6'b010000;
        addr5: sel = 6'b100000;
        default: sel = 6'b000000;
    endcase
end
endmodule

module DataMux(addr, dat0, dat1, dat2, dat3, dat4, dat5, ena, out);
input [4:0] addr;
input [31:0] dat0, dat1, dat2, dat3, dat4, dat5;
input ena;
output logic [31:0] out;
logic [31:0] data_selected;
parameter addr0 = 5'b10001;
parameter addr1 = 5'b10010;
parameter addr2 = 5'b01000;
parameter addr3 = 5'b10111;
parameter addr4 = 5'b11111;
parameter addr5 = 5'b10000;
always_comb begin
    casez(addr)
        addr0: data_selected = dat0;
        addr1: data_selected = dat1;
        addr2: data_selected = dat2;
        addr3: data_selected = dat3;
        addr4: data_selected = dat4;
        addr5: data_selected = dat5;
        default: data_selected = 0;
    endcase
    out = data_selected & {32{ena}};
end
endmodule

module Register32 (clk, rst_n, in, ena, out);
input clk, rst_n, ena;
input [31:0] in;
output logic [31:0] out;
logic [31:0] reg_in;
assign reg_in = ena? in : out;
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        out <= 0;
    else
        out <= reg_in;
end
endmodule
// 57407