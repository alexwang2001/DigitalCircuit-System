`timescale 1ns/1ns

module Maxmin_tb();
    logic clk, rst_n, in_valid;
    logic [7:0] in_num;
    logic [7:0] out_max, out_min;
    logic out_valid;
    int seed = 0904; //my birthday
    int correct_out_valid = 0;
    int correct_max, correct_min;
    int wrong = 0;

    Maxmin u1(.*);
    
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, clk, rst_n, in_valid, in_num, out_max, out_min, out_valid);
    end

    initial begin
        clk = 0;
        #10
        forever begin
            #5
            clk = ~clk;
        end
    end

    task reset();
        rst_n = 1;
        #1
        rst_n = 0;
        #3
        rst_n = 1;
    endtask

    task num_gen();
        correct_max = 0;
        correct_min = 255;
        @(negedge clk) begin
            in_valid = 1;
            in_num = {$random(seed)}%256;
            if(in_num > correct_max) correct_max = in_num;
            if(in_num < correct_min) correct_min = in_num;
        end
        repeat(14)@(negedge clk)begin 
            in_num = {$random(seed)}%256;
            if(in_num > correct_max) correct_max = in_num;
            if(in_num < correct_min) correct_min = in_num;
        end
        @(posedge clk) correct_out_valid = 1;
        @(negedge clk) begin
            in_valid = 0;
            in_num = 0;
            if(correct_max != out_max) begin
                $display("*             *");
                $display(" **         ** ");
                $display("   **     **   ");
                $display("     ** **     ");
                $display("     ** **     ");
                $display("   **     **   ");
                $display(" **         ** ");
                $display("*             *");
                $display("Wrong!\nout_max is not correct!");
                $display("your out max: %3d", out_max);
                $display("correct answer: %3d", correct_max);
                wrong = 1;
            end
            if(correct_min != out_min) begin
                $display("*             *");
                $display(" **         ** ");
                $display("   **     **   ");
                $display("     ** **     ");
                $display("     ** **     ");
                $display("   **     **   ");
                $display(" **         ** ");
                $display("*             *");
                $display("Wrong!\nout_min is not correct!");
                $display("your out min: %3d", out_min);
                $display("correct answer: %3d", correct_min);
                wrong = 1;
            end
        end
        @(posedge clk) correct_out_valid = 0;
    endtask

    always begin
        #5
        if(out_valid != correct_out_valid) begin
                $display("*             *");
                $display(" **         ** ");
                $display("   **     **   ");
                $display("     ** **     ");
                $display("     ** **     ");
                $display("   **     **   ");
                $display(" **         ** ");
                $display("*             *");
                $display("Wrong!\nout_valid should be %d!", correct_out_valid);
                $finish;
            end
    end

    initial begin
        in_num = 0;
        in_valid = 0;
        reset();
        repeat(3)@(posedge clk);
        for(int i=0; i<99; i=i+1) begin
            num_gen();
            if(wrong == 1) begin
                #10
                $finish;
            end 
            #((i/5+1)*10);
            $display("Pass test %2d", i+1);
        end
        /*
        $display("                   *********                  ");
        $display("           *************************          ");
        $display("       ********************************       ");
        $display("   ****************************************   ");
        $display("  ******************************************  ");
        $display(" ******************************************** ");
        $display("***********   *****************   ************");
        $display("*********   @   *************   @   **********");
        $display("***********   *****************   ************");
        $display("**********************************************");
        $display("**********************************************");
        $display("**********************************************");
        $display(" ******************************************** ");
        $display("  **********   *****************   *********  ");
        $display("   ***********   ************   ***********   ");
        $display("       **********            **********       ");
        $display("           *************************          ");
        $display("                   *********                  ");
        $display("==============================================");
        $display("         ALL PASS     Alex's birthday: 9/4    ");
        $display("==============================================");
        $finish;
        */
        $display("                                                                                                    ");     
        $display("                                                                                                    ");
        $display("                                                                                                    ");
        $display("                                                                                    :.:             ");
        $display("                                                                                 i 7rPv             ");
        $display("                                                                               :122uXq              ");
        $display("                                                                              71Y7Y1K               ");
        $display("                                  ....                                      i2uYsUq2                ");
        $display("                                .vL7777i.                              .:rs15J2557.                 ");
        $display("                                jvii:iiir                        .:ir7vJLLvJuKv.                    ");
        $display("                                j7iiiii:i:.                   .:rrrrrr7r7J5ur                       ");
        $display("                                 Yii:iii:ir               ..:i:iii:iirvUsr                          ");
        $display("                                 7viiiiiii:     ::::....::::::::iirivsr                             ");
        $display("                                 .v7iiii:iiri::i:::::::::::::iiiir7ur                               ");
        $display("                                   7J7rii:iiiir:::iii:i:::::iiiivLi                                 ");
        $display("                                     i7riririiii:iii::ii:::iiirJi                                   ");
        $display("                                       77rriiiiiiiiii:iiiiiiir7                                     ");
        $display("                                       77riiiriiirrriiiriiirrs.                                     ");
        $display("                                    :rJ77irirrrrrrrrrirrrrrr7J:                                     ");
        $display("                                   Ujvr777r777rrr7rrrrr77rr77I                                      ");
        $display("                                  sLv77r7777vr77ssLvvvY7L77r7u                                      ");
        $display("                                 7u77L77777v7rr7vvvYvvvLsJLvY7                                      ");
        $display("                                :Iv7L7v777YYL7v7v77rrrr7vr77Jr                                      ");
        $display("                               7YYLYvLL77s7JL7vLvL7vr77777r7rYS                                     ");
        $display("                             :11LvYvv7LvLvvLsvYvsvLLYLYvYLY7LruJ.                             .     ");
        $display("                           rI2LvvYYs7YvsvYvvJsLYLjvLYYvsLssYvv715Y                             . .  ");
        $display(".                        :52JLJYsuXS1vY7sLs71JJYJL77sLLvjYLYY7v7L2q7                    .     . . . ");
        $display("   .   .                vXsLYJjXPXr r5LLvjY7u1ssLv7LvYLsYJvYvLYL7ubL                 .   . . . . .  ");
        $display(". . .   .             :5Is1uPPXv:    IUvYJYr1U1LY7LvLvuLLvsYLvs7UU:                   . . . . . ... ");
        $display(". .. . . . .        rS5us1KK7.       .PULs7vJ21UuLvJLYYYLjYJYL7Ur                  . . . . . ...... ");
        $display(". ... . . .      ..7PuuIPX7           :KuYYYJ1uU1LJvYvYvsjJLsvjKL     .       .     . . . . . ..... ");
        $display(". .... . . .irvLjK5I1dPj:              s5sYvYUj1svvJsjvv7s211S22Pr                                  ");
        $display(".           .iEI2uuqSi        .        .bJJvJjU1UYvvL77vLuK25U21XZr  ...................:.:::.:...:.");
        $display("..... 77 ..:isS1JUP1 ............... .  1Uss7SSKSS2Uu25PXXIS25U2UKQi . ................:.....: .:.:.");
        $display("i.:..rEXiS r77XJId: ....:. :  .... .v   :5uvsXXIS2SSKSqS5I5I5I522IDi   . ......... :i.   .... .bU . ");
        $display(".. .PQPEDg::vqUYqQ. ....  7Q :Bq.5s.E   rIJLsX5SI5ISSSSKIX5XI5IS2IXd  .. .....  rP UXu r. Y.  ZBs . ");
        $display(". .MgSKSPQI KUs2dR. .... YBgv.Bb 5KqS   552sUKX5SIS5K5K5XSX5XSXI52SZr    ..     dQUSKD.MU Qq  gB::QS");
        $display(": :QdP5SXQi :I7ZZS .....  gQ  QP qqdP   :S7vuPSKSXSKSXXKXqSKSKIX5X5dP        .. 7BEPRS KB Db  :gr JB");
        $display(".  iRgPPgQ. rRJIKL  ..... EB::Qb Iq2Z:. .PUIPXXIXSKKqSKPdPPXqSXSK5SSZbr:iii:ii:.:s:7R. 7S E.  : :  L");
        $display("::.:J1Qd2Q. iX.:v77: .::..XX:7vv:Y1Yis..sMPPXqSKSKXqPggKsUdDXq5K5KIKKZDLr7r7i::ii::rvr.7u:vr.rrr7vr7");
        $display("   . :Pi 1. ii.:I:iuii7rvj5JYu2ujsJUU2vUQqKqqXKSqXPZg27i7r7ddKqXKSKSqKZvLrJPESqSXIIu22qUIISXK55UI2Iu");
        $display("UJ55j2Ju2q1q5S2XUII5XIII1jYuJsLvLY7vrrigbqKqKPKPXggSr:r7r7rvEMKKXKSqXKDSvj22JUJsvY7L7vvLvYLvYJsuY1Ls");
        $display("X52uUJJjsLsYJLL7vvLvv77vLv7777777rv7r:qZPKPKqqKPg5i:rYsrrr7irDgqPKPKPXRvivv7r7LvLLLvLvYYvLLvJYvLLvJv");
        $display("Iu2Jus112uUUJsu1IJUjUs2uIjjJjUIJ11v7QPbqdPdgdi7vvJ2vjYvLYvusLLYrjDMqdPbPgsrs1JjJJYYLusjuUYS5s1Uu2uIj");
        $display("Y7JjujUsjYsjLYJvsJ77jvYLY7vY77L7LvrigddddbMX:rv7vv7rrrvv77YYJu5UUuYbMPdPdZQ7iv7rrrrrYJ7rsYv7s7YvL7vr");
        $display("uYjUjv7YvJvvLvr77vvLjJvJvrrLr7vL77i:qQPEbdDQiiv77sv7rr77irLs7L7vrrirQgPdbZDRrru5YjuU1UJujjjU1ujvv1Uu");
        $display("Yr777LjsJvv7s7vvvYULr7JsuJ1JYLusuL2LPREdEbZQ1vJvUjjsI55usv11j1IJK1jL2MDbdbZgEL2211X5S2IXK1SIXIKISKKS");
        $display("U1JjJqYu12su1j2XUsu1JJvJ1UUuvJLUJ7vvrRZEbdbQYrY7vJ7U2svJ7uj77LuvvssLrjMgbEEgRLrJu2uuvYvvYYJ1JjYssIJ1");
        $display("27UJJLL7L2j7uJLvuJL7sjvrvvvY1JLiivuLiERbbbZQ2i7rY77JJ7s7vr7Yrr777L1vYrZRDdEbQ1ivYvsJ5UXUjj1JsvsYsvsv");
        $display("XXUUXXUIIjs2USq2sJJILjuuJjLu1qPSjS55YSQZdEbQP1IK51YssYjUYvUXSPS51Pqq17LBZZdEgQLJJjsU1X11jUIXUjuXXq5X");
        $display("u7vvUsjY5Jv7J7r7YrvLLYLsJrv12uIULuY:i7BEdbERKi7rrrYLYrvYIIUssJuJ1sJ7rirDQEEdgg2YuLJYvYvsIU5vvYUJ1JJL");
        $display("L1jL71L7vJv7r7vv77r7JuJYs1Ys7r77rrr7i:ggPZbQI:rrr777r7irrrir77rr71uLLJrIQDdZdQ5rJJLYJs7vsvvsjuvLsSX1");
        $display("1jS5X1s7LYJLsIKPqIXUuJSS2USJJsYsuvrL7iRgEdEgPi12IUX5SZPIu77vjLYvvrr7uLJ7gRZEDZQsvuJ7v7v7sjLvv7777vsL");
        $display("Yvv7rvssrvsjjIsvrv7Jsu7r77r777rLvv7YvvQQEZdgg:rs7772juJ5J7vJ7sYv7LL77vvr7QgDbDQbrYvYsS5u771PJ22UU5sv");
        $display("vrr712UY2L777rL77Jjr777r7vJvvvYvv157r:UdgggQd.rrvr7ir7Y777Lv7rsLv7rrvv7i.JBggZMBJrYvv7u2K2X25uu1IIqJ");
        $display("uUY7rYssvuYvvv7vvY77r77Lr7v1L7r7r7js7ii7XSXq2i7v77rLLYrrrs7rrrrY77uKPP52vrZBRRgQu:sIJvYYvuvvvvrr7v7L");
        $display("ULsYLv1vrvLrvs2L77vLu15sYv7r7v17LLi71uRgEKSKEdrirrrr7777J7LLL77rvvvvss1JJri2ZP5qqr7v7rr7YYvv11jYU2UJ");
        $display("vrvj7r7u2KIJ7vLv777JJvrY777ri7LjLjqEDREDdDZDdgj7777rivLsSdPPUv7j7LLv77rir77isXSqSPv77vuj77rLvYLYYu1u");
        $display("X1I1s7vYjJ125jus5II2dgZPPXgDDgMdPXqqPqZPPSKKPKbZgZDdggRggdPPRgZ121jJ1LLJX5PDgPZPEbZDRQQMRDPssuvrr7L7");
        $display("L12222IKU1IXU2uIJ7rvr7vs7u5KX5Lr7XPqXX5SISXqXSIK5XIKXKSIv77vL1Uv1DEDEbqX12j1SqXKSPqqqbPqqgZqK52PqXUs");
        $display("DbbPEZZZQMQgggDKSKPI2I5U11YYI2KqSuU2IISIKqdPq2XIqXPPqKPZPjjus7JJ225I5PDb2J5SdPPKPXX1svu15ISSZMMZPJ1Y");
        $display("7vvLvLY1vYJUU1u5557L7rr7vuvsvrrsISXEPPqPSSSU7Yu215UJ777vv2qK1215qdbbKXuuSMMgPbXKS22SjJJ115U1uuLsYIIK");
        $display("K2KIS5SIUu2122Iu2Ju5qqbXS5PPEPX2PPbqPIXXKSSu1JU1I5KS5jsrv7vrvJs7vLsJsLs7rrrrU1I2SKPKdKXJjYvYJYjUq55U");
    end
endmodule