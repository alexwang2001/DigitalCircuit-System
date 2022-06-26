del *.out
del *.vcd
iverilog -g2012 -o rtl.out Lab07_01.sv PATTERN.sv TESTBEND.sv
vvp rtl.out
del *.out
del *.vcd
iverilog -g2012 -o rtl.out Lab07_02.sv PATTERN.sv TESTBEND.sv
vvp rtl.out
del *.out
del *.vcd
iverilog -g2012 -o rtl.out Lab07_03.sv PATTERN.sv TESTBEND.sv
vvp rtl.out
del *.out
del *.vcd
iverilog -g2012 -o rtl.out Lab07_04.sv PATTERN.sv TESTBEND.sv
vvp rtl.out
del *.out
del *.vcd
iverilog -g2012 -o rtl.out Lab07_05.sv PATTERN.sv TESTBEND.sv
vvp rtl.out
del *.out
del *.vcd
iverilog -g2012 -o rtl.out Lab07.sv PATTERN.sv TESTBEND.sv
vvp rtl.out
cmd