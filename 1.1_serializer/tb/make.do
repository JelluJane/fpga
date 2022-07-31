vlib work

vlog -sv ../rtl/serializer.sv
vlog -sv serializer_tub.sv

vsim -novopt serializer_tub
add log -r /*
add wave -r *
run -all