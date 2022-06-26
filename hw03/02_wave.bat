del *.out
del *.vcd
iverilog -g2009 -o rtl.out VM.sv VM_tb.sv 
vvp rtl.out
gtkwave wave.vcd