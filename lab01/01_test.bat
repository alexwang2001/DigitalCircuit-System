del *.out
del *.vcd
iverilog Comb.sv Comb_tb.sv
vvp a.out
gtkwave wave.vcd