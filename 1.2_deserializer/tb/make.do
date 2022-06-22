vlib work

vlog -sv ../rtl/deserializer.sv
vlog -sv deserializer_tub.sv

vsim -novopt deserializer_tub
add log -r /*
add wave -r *
run -all