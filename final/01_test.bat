del *.out
del *.vcd
iverilog -g2012 -o rtl.out JAM.sv PATTERN.sv TESTBENCH.sv
vvp rtl.out
cmd