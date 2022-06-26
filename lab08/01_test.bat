del *.out
del *.vcd
iverilog -g2012 -o rtl.out P_MUL.sv TESTBED.sv
vvp rtl.out
cmd