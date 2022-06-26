module inter(
  // Input signals
  clk,
  rst_n,
  in_valid_1,
  in_valid_2,
  in_valid_3,
  data_in_1,
  data_in_2,
  data_in_3,
  ready_slave1,
  ready_slave2,
  // Output signals
  valid_slave1,
  valid_slave2,
  addr_out,
  value_out,
  handshake_slave1,
  handshake_slave2
);
//FSM
parameter S_idle = 0;
parameter S_master1 = 1;
parameter S_master2 = 2;
parameter S_master3 = 3;
parameter S_handshake = 4;
//---------------------------------------------------------------------
//   PORT DECLARATION
//---------------------------------------------------------------------
input clk, rst_n, in_valid_1, in_valid_2, in_valid_3;
input [6:0] data_in_1, data_in_2, data_in_3; 
input ready_slave1, ready_slave2;
output logic valid_slave1, valid_slave2;
output logic [2:0] addr_out, value_out;
output logic handshake_slave1, handshake_slave2;
//---------------------------------------------------------------------
//   YOUR DESIGN
//---------------------------------------------------------------------
// logic declaration
//----------------------------
logic [6:0] data1_reg, data2_reg, data3_reg;
logic [6:0] data1_reg_next, data2_reg_next, data3_reg_next;
logic valid1_reg, valid2_reg, valid3_reg;
logic valid1_reg_next, valid2_reg_next, valid3_reg_next;
logic [2:0] Arbiter_FSM;
logic [2:0] Arbiter_FSM_next;
// muxes
logic [2:0] address_mux_out;
logic [2:0] data_mux_out;
logic ready_mux_out;
// handshake
logic handshake_slave1_ready, handshake_slave2_ready;
logic handshake_slave1_next, handshake_slave2_next;

// code
//----------------------------

// save input to register
// DFF part
always_ff @(posedge clk or negedge rst_n) begin: d1_reg
    if(!rst_n)
        data1_reg <= 0;
    else
        data1_reg <= data1_reg_next;
end 
always_ff @(posedge clk or negedge rst_n) begin: d2_reg
    if(!rst_n)
        data2_reg <= 0;
    else
        data2_reg <= data2_reg_next;
end 
always_ff @(posedge clk or negedge rst_n) begin: d3_reg
    if(!rst_n)
        data3_reg <= 0;
    else
        data3_reg <= data3_reg_next;
end 
always_ff @(posedge clk or negedge rst_n) begin: val1_reg
    if(!rst_n)
        valid1_reg <= 0;
    else
        valid1_reg <= valid1_reg_next;
end 
always_ff @(posedge clk or negedge rst_n) begin: val2_reg
    if(!rst_n)
        valid2_reg <= 0;
    else
        valid2_reg <= valid2_reg_next;
end 
always_ff @(posedge clk or negedge rst_n) begin: val3_reg
    if(!rst_n)
        valid3_reg <= 0;
    else
        valid3_reg <= valid3_reg_next;
end 
// Comb part
always_comb begin
    if(Arbiter_FSM == S_idle) begin
        data1_reg_next = data_in_1;
        data2_reg_next = data_in_2;
        data3_reg_next = data_in_3;
        valid1_reg_next = in_valid_1;
        valid2_reg_next = in_valid_2;
        valid3_reg_next = in_valid_3;
    end
    else if(Arbiter_FSM == S_master1) begin
        data1_reg_next = data1_reg;
        data2_reg_next = valid2_reg ? data2_reg : data_in_2;
        data3_reg_next = valid3_reg ? data3_reg : data_in_3;
        valid1_reg_next = ready_mux_out ? 0 : valid1_reg;
        valid2_reg_next = valid2_reg ? valid2_reg : in_valid_2;
        valid3_reg_next = valid3_reg ? valid3_reg : in_valid_3;
    end
    else if(Arbiter_FSM == S_master2) begin
        data1_reg_next = data_in_1;
        data2_reg_next = data2_reg;
        data3_reg_next = valid3_reg ? data3_reg : data_in_3;
        valid1_reg_next = in_valid_1;
        valid2_reg_next = ready_mux_out ? 0 : valid2_reg;
        valid3_reg_next = valid3_reg ? valid3_reg : in_valid_3;
    end
    else if(Arbiter_FSM == S_master3) begin
        data1_reg_next = data_in_1;
        data2_reg_next = data_in_2;
        data3_reg_next = data3_reg;
        valid1_reg_next = in_valid_1;
        valid2_reg_next = in_valid_2;
        valid3_reg_next = ready_mux_out ? 0 : valid3_reg;
    end
    else begin
        data1_reg_next = valid1_reg ? data1_reg : data_in_1;
        data2_reg_next = valid2_reg ? data2_reg : data_in_2;
        data3_reg_next = valid3_reg ? data3_reg : data_in_3;
        valid1_reg_next = valid1_reg ? valid1_reg : in_valid_1;
        valid2_reg_next = valid2_reg ? valid2_reg : in_valid_2;
        valid3_reg_next = valid3_reg ? valid3_reg : in_valid_3;
    end
end

//muxes
always_comb begin: muxes
    case(Arbiter_FSM)
        S_master1: address_mux_out = data1_reg[5:3];
        S_master2: address_mux_out = data2_reg[5:3];
        S_master3: address_mux_out = data3_reg[5:3];
        default: address_mux_out = 'd0;
    endcase
    case(Arbiter_FSM)
        S_master1: data_mux_out = data1_reg[2:0];
        S_master2: data_mux_out = data2_reg[2:0];
        S_master3: data_mux_out = data3_reg[2:0];
        default: data_mux_out = 'd0;
    endcase 
    case(Arbiter_FSM)
        S_master1: ready_mux_out = data1_reg[6] ? ready_slave2 : ready_slave1;
        S_master2: ready_mux_out = data2_reg[6] ? ready_slave2 : ready_slave1;
        S_master3: ready_mux_out = data3_reg[6] ? ready_slave2 : ready_slave1;
        default: ready_mux_out = 0;
    endcase
end

assign addr_out = address_mux_out;
assign value_out = data_mux_out;


// ArbiterFSM
always_ff @(posedge clk or negedge rst_n) begin: ArbiterFSM_reg
    if(!rst_n)
        Arbiter_FSM <= S_idle;
    else
        Arbiter_FSM <= Arbiter_FSM_next;
end 
always_comb begin: ArbiterFSM
    casex(Arbiter_FSM)
        S_idle: begin
            casex({in_valid_1, in_valid_2, in_valid_3})
                'b1xx: Arbiter_FSM_next = S_master1;
                'b01x: Arbiter_FSM_next = S_master2;
                'b001: Arbiter_FSM_next = S_master3;
                default: Arbiter_FSM_next = Arbiter_FSM;
            endcase
        end
        S_master1,S_master2,S_master3: begin
            if(ready_mux_out)
                Arbiter_FSM_next = S_handshake;
            else 
                Arbiter_FSM_next = Arbiter_FSM;
        end
        S_handshake: begin
            casex({valid2_reg, valid3_reg})
                'b1x: Arbiter_FSM_next = S_master2;
                'b01: Arbiter_FSM_next = S_master3;
                default: Arbiter_FSM_next = S_idle;
            endcase
        end
        default: Arbiter_FSM_next = Arbiter_FSM;
    endcase
end


// data valid
always_comb begin: valid_to_slave
    case(Arbiter_FSM)
        S_master1: valid_slave1 = ~data1_reg[6];
        S_master2: valid_slave1 = ~data2_reg[6];
        S_master3: valid_slave1 = ~data3_reg[6];
        default: valid_slave1 = 0;
    endcase
    case(Arbiter_FSM)
        S_master1: valid_slave2 = data1_reg[6];
        S_master2: valid_slave2 = data2_reg[6];
        S_master3: valid_slave2 = data3_reg[6];
        default: valid_slave2 = 0;
    endcase      
end


//handshake
always_ff @(posedge clk or negedge rst_n) begin: hs_1
    if(!rst_n)
        handshake_slave1_ready <= 0;
    else
        handshake_slave1_ready <= handshake_slave1_next;
end
always_ff @(posedge clk or negedge rst_n) begin: hs_2
    if(!rst_n)
        handshake_slave2_ready <= 0;
    else
        handshake_slave2_ready <= handshake_slave2_next;
end
always_comb begin: hs_comb
    handshake_slave1_next = valid_slave1 & ready_slave1;
    handshake_slave2_next = valid_slave2 & ready_slave2;
    handshake_slave1 = handshake_slave1_ready & (Arbiter_FSM == S_handshake);
    handshake_slave2 = handshake_slave2_ready & (Arbiter_FSM == S_handshake);
end


endmodule
