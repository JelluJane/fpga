vlib work

vlog -sv ../rtl/bit_population_counter.sv
vlog -sv bit_population_counter_tub.sv

vsim -novopt bit_population_counter_tub
add log -r /*
add wave -r *
run -all