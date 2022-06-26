del *.out
del *.vcd
iverilog -g2009 -o rtl.out Maxmin.sv Maxmin_tb.sv 
vvp rtl.out
cmd