del *.out
del *.vcd
iverilog -g2012 -o rtl.out CDC.sv TESTBED.sv synchronizer.v
vvp rtl.out
cmd