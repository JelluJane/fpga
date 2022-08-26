vlib work

vlog -sv ../rtl/lifo.sv
vlog -sv lifo_tb.sv

vsim -novopt lifo_tb.sv
add wave -hex -in -out -internal -recursive -radix unsigned dut/*
run -all