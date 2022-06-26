del *.out
del *.vcd
iverilog -g2009 -o rtl.out Timer.sv Timer_tb.sv 
vvp rtl.out
gtkwave wave.vcd
cmd