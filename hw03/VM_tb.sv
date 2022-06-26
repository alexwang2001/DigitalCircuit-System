`timescale 1ns/1ps

module TESTBED();
    logic clk;
    logic rst_n;
    // input
    logic in_item_valid;
    logic in_coin_valid;
    logic [5:0] in_coin;
    logic in_rtn_coin;
    logic [2:0] in_buy_item;
    logic [4:0] in_item_price;
    // output
    logic [8:0] out_monitor;
    logic out_valid;
    logic [3:0] out_consumer;
    logic [5:0] out_sell_num;

    VM U1(.*);

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, TESTBED);
    end

    initial begin
        clk = 0;
        #20
        forever begin
            #5
            clk = ~clk;
        end
    end
    
    task reset();
        rst_n = 1;
        #1 rst_n = 0;
        #4 rst_n = 1;
    endtask

    initial begin
        in_buy_item = 0;
        in_coin = 0;
        in_coin_valid = 0;
        in_item_price = 0;
        in_item_valid = 0;
        in_rtn_coin = 0;
    end

    initial begin
        reset();
        newMur();
        incoin();
        in_rtn_coin = 1;
        @(negedge clk);
        in_rtn_coin = 0;
        @(negedge out_valid);
        @(negedge clk);
        incoin();
        in_buy_item = 3;
        @(negedge clk);
        in_buy_item = 0;
        @(negedge out_valid);
        @(negedge clk);
        incoin();
        in_buy_item = 6;
        @(negedge clk);
        in_buy_item = 0;
        @(negedge out_valid);
        @(negedge clk);
        #100
        $finish;
    end

    task newMur();
        @(negedge clk);
        in_item_valid = 1;
        in_item_price = $urandom % 64;
        repeat(5) @(negedge clk) in_item_price = $urandom % 64;
        @(negedge clk);
        in_item_valid = 0;
        in_item_price = 0;
    endtask

    function int moneygen();
        case($urandom % 5)
            0: return 50;
            1: return 20;
            2: return 10;
            3: return 5;
            4: return 1;
        endcase
    endfunction

    int len;
    task incoin();
        len = ($urandom % 9);
        for(int i=0; i<= len; i=i+1) begin
            @(negedge clk);
            in_coin_valid = 1;
            in_coin = moneygen();
        end
        @(negedge clk);
        in_coin_valid = 0;
        in_coin = 'd0;
    endtask

endmodule