del *.out
del *.vcd
iverilog -g2009 CN.sv CN_tb.sv
vvp a.out
gtkwave wave.vcd