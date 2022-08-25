vlib work

vlog -sv ../rtl/lifo.sv
vlog -sv lifo_tb.sv

vsim -novopt lifo_tb.sv
add log -r /*
add wave -r *
run -all