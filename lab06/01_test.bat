del *.out
del *.vcd
iverilog -g2009 -o rtl.out Fpc.sv TESTBED.sv 
vvp rtl.out
cmd