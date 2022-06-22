vlib work

vlog -sv ../rtl/traffic_lights.sv
vlog -sv traffic_lights_tub.sv

vsim -novopt traffic_lights_tub
add log -r /*
add wave -r *
run -all