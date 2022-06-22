vlib work

vlog -sv ../rtl/priority_encoder.sv
vlog -sv priority_encoder_tub.sv

vsim -novopt priority_encoder_tub
add log -r /*
add wave -r *
run -all