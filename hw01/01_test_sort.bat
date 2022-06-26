del *.out
del *.vcd
iverilog -g2009 sorting.sv sorting_tb.sv
vvp a.out
gtkwave wave.vcd