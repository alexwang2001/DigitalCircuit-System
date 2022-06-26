del *.out
del *.vcd
iverilog -g2012 -o rtl.out Conv.sv PATTERN.sv TESTBEND.sv
vvp rtl.out
cmd