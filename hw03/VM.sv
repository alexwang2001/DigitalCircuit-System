module VM(
    //Input 
    clk,
    rst_n,
    in_item_valid,
    in_coin_valid,
    in_coin,
    in_rtn_coin,
    in_buy_item,
    in_item_price,
    //Output
    out_monitor,
    out_valid,
    out_consumer,
    out_sell_num
);
//Input 
input clk;
input rst_n;
input in_item_valid;
input in_coin_valid;
input [5:0] in_coin;
input in_rtn_coin;
input [2:0] in_buy_item;
input [4:0] in_item_price;
//Output
output logic [8:0] out_monitor;
output logic [3:0] out_consumer;
output logic [5:0] out_sell_num;
output logic out_valid;
//---------------------------------------------------------------------
//  Your design(Using FSM)                            
//---------------------------------------------------------------------
logic [3:0] state;
logic [3:0] state_next;
logic [4:0] items_price_reg_out [6:1];
logic [4:0] items_price_reg_next [6:1];
logic [4:0] item_price;
logic [5:0] item_cnt_out [6:1];
logic [5:0] item_cnt_next [6:1];
logic [5:0] sel_cnt;
logic [5:0] sel_cnt_add1;
logic [1:6] sel_decode;
logic [8:0] coin_reg_out;
logic [8:0] coin_reg_next;
logic [8:0] coin_rtn_out;
logic [8:0] coin_rtn_next;
logic [2:0] rtn_num_seq;
// FSM
//---------------------------------------------------------------------
parameter S_idle = 0;
parameter S_rtn = 2; // 2~7
parameter S_nortn = 10; // 10~15
parameter S_dne1 = 1;
parameter S_dne2 = 8;
parameter S_dne3 = 9;

always_ff @(posedge clk or negedge rst_n) begin: FSM
    if(!rst_n)
        state <= S_idle;
    else
        state <= state_next;
end

always_comb begin : FSM_comb
    casez(state)
        S_idle: begin
            if(!in_rtn_coin & (in_buy_item == 0))
                state_next = S_idle;
            else if(coin_reg_out < item_price)
                state_next = S_nortn;
            else 
                state_next = S_rtn;
        end
        S_rtn,S_rtn+1,S_rtn+2,S_rtn+3,S_rtn+4,S_nortn,S_nortn+1,S_nortn+2,S_nortn+3,S_nortn+4: state_next = state + 1;
        S_rtn+5,S_nortn+5: state_next = S_idle;
        default: state_next = 'x;
    endcase
end

// sequential part
//---------------------------------------------------------------------
always_ff @(posedge clk) begin
    // item price reg: save the price of merchandises
    for(int i=1; i<=6; i=i+1) items_price_reg_out[i] <= items_price_reg_next[i];
    // item count reg: save the number of the items seld
    for(int i=1; i<=6; i=i+1) item_cnt_out[i] <= item_cnt_next[i];
    coin_rtn_out <= coin_rtn_next;
end

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        coin_reg_out <= 0;
        out_consumer <= 0;
    end
    else begin
        coin_reg_out <= coin_reg_next;
        out_consumer <= rtn_num_seq;
    end
end

// combinational part
//---------------------------------------------------------------------

always_comb begin
    // item price reg 1~5
    for(int i=1; i<6; i=i+1) items_price_reg_next[i] = in_item_valid? items_price_reg_out[i+1] : items_price_reg_out[i];
    // item price reg 6
    items_price_reg_next[6] = in_item_valid? in_item_price : items_price_reg_out[6];
    // item price sel: output the price of selected item 
    casez(in_buy_item)
        0: item_price = 0;
        1: item_price = items_price_reg_out[1];
        2: item_price = items_price_reg_out[2];
        3: item_price = items_price_reg_out[3];
        4: item_price = items_price_reg_out[4];
        5: item_price = items_price_reg_out[5];
        6: item_price = items_price_reg_out[6];
        default: item_price = 0;
    endcase
    // in coin: saving the coins coin into the VM
    coin_reg_next = (state == S_rtn)? 0 : (in_coin + coin_reg_out);
    // coin monitor
    out_monitor = (state == S_rtn)? 0 : coin_reg_out;
    // rtn coin: return the money left
    casez(state)
        S_idle: begin
            coin_rtn_next = coin_reg_out - item_price;
            rtn_num_seq = (coin_reg_out < item_price)? 0 : in_buy_item;
        end
        S_rtn: begin
            /*if(coin_rtn_out >= 421) begin
                coin_rtn_next = 0;
                rtn_num_seq = 9;
            end
            else if(coin_rtn_out >= 400) begin
                coin_rtn_next = 0;//coin_rtn_out - 400;
                rtn_num_seq = 8;
            end
            else */if(coin_rtn_out >= 325) begin // 325
                coin_rtn_next = coin_rtn_out - 350;
                rtn_num_seq = 7;
            end
            else if(coin_rtn_out >= 300) begin
                coin_rtn_next = coin_rtn_out - 300;
                rtn_num_seq = 6;
            end
            else if(coin_rtn_out >= 250) begin
                coin_rtn_next = coin_rtn_out - 250;
                rtn_num_seq = 5;
            end
            else if(coin_rtn_out >= 200) begin
                coin_rtn_next = coin_rtn_out - 200;
                rtn_num_seq = 4;
            end
            else if(coin_rtn_out >= 150) begin
                coin_rtn_next = coin_rtn_out - 150;
                rtn_num_seq = 3;
            end
            else if(coin_rtn_out >= 100) begin
                coin_rtn_next = coin_rtn_out - 100;
                rtn_num_seq = 2;
            end
            else if(coin_rtn_out >= 50) begin
                coin_rtn_next = coin_rtn_out - 50;
                rtn_num_seq = 1;
            end
            else begin
                coin_rtn_next = coin_rtn_out;
                rtn_num_seq = 0;
            end
        end
        S_rtn+1: begin
            if(coin_rtn_out >= 40) begin
                coin_rtn_next = coin_rtn_out - 40;
                rtn_num_seq = 2;
            end
            else if(coin_rtn_out >= 20) begin
                coin_rtn_next = coin_rtn_out - 20;
                rtn_num_seq = 1;
            end
            else begin
                coin_rtn_next = coin_rtn_out;
                rtn_num_seq = 0;
            end
        end
        S_rtn+2: begin
            if(coin_rtn_out >= 10) begin
                coin_rtn_next = coin_rtn_out - 10;
                rtn_num_seq = 1;
            end
            else begin
                coin_rtn_next = coin_rtn_out;
                rtn_num_seq = 0;
            end
        end
        S_rtn+3: begin
            if(coin_rtn_out >= 5) begin
                coin_rtn_next = coin_rtn_out - 5;
                rtn_num_seq = 1;
            end
            else begin
                coin_rtn_next = coin_rtn_out;
                rtn_num_seq = 0;
            end
        end
        S_rtn+4: begin
            coin_rtn_next = 'x;
            rtn_num_seq = coin_rtn_out;
        end
        S_rtn+5: begin
            coin_rtn_next = 'x;
            rtn_num_seq = coin_rtn_out; //0
        end
        S_nortn, S_nortn+1, S_nortn+2, S_nortn+3, S_nortn+4, S_nortn+5: begin
            coin_rtn_next = 'x;
            rtn_num_seq = 0;
        end
        S_dne1: begin
            coin_rtn_next = 'x;
            rtn_num_seq = 'x;
        end
        S_dne2,S_dne3: begin
            coin_rtn_next = 'x;
            rtn_num_seq = 0;
        end
        default: begin
            coin_rtn_next = 'x;
            rtn_num_seq = 'x;
        end
    endcase
    // sell num: save the amount of merchandises seld
    // mux out
    casez(in_buy_item)
        1: sel_cnt = item_cnt_out[1];
        2: sel_cnt = item_cnt_out[2];
        3: sel_cnt = item_cnt_out[3];
        4: sel_cnt = item_cnt_out[4];
        5: sel_cnt = item_cnt_out[5];
        6: sel_cnt = item_cnt_out[6];
        default: sel_cnt = 'x;
    endcase
    // adder
    sel_cnt_add1 = sel_cnt + 1;
    // decoder
    casez(in_buy_item)
        0: sel_decode = 'b000000;
        1: sel_decode = 'b100000;
        2: sel_decode = 'b010000;
        3: sel_decode = 'b001000;
        4: sel_decode = 'b000100;
        5: sel_decode = 'b000010;
        6: sel_decode = 'b000001;
        default: sel_decode = 'x;
    endcase
    // mux in
    for(int i=1; i<=6; i=i+1)
        item_cnt_next[i] = in_item_valid? 0 : (sel_decode[i] & ~(coin_reg_out < item_price)? sel_cnt_add1 : item_cnt_out[i]);
    // out_sell_num
    casez (state[2:0])
        S_rtn: out_sell_num = item_cnt_out[1];
        S_rtn+1: out_sell_num = item_cnt_out[2];
        S_rtn+2: out_sell_num = item_cnt_out[3];
        S_rtn+3: out_sell_num = item_cnt_out[4];
        S_rtn+4: out_sell_num = item_cnt_out[5];
        S_rtn+5: out_sell_num = item_cnt_out[6];
        default: out_sell_num = 0;
    endcase
    // out valid
    out_valid = (state[2:0] >= S_rtn);
end
endmodule
// 15314 //12803
