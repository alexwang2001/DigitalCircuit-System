del *.out
del *.vcd
iverilog -g2009 -o rtl.out Sequence.sv TESTBED.sv 
vvp rtl.out
cmd