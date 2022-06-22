vlib work

vlog -sv ../rtl/debouncer.sv
vlog -sv debouncer_tub.sv

vsim -novopt debouncer_tub
add log -r /*
add wave -r *
run -all