del *.out
del *.vcd
iverilog -g2012 -o rtl.out MIPS.sv PATTERN.sv TESTBEND.sv
vvp rtl.out
cmd