vlib work

vlog -sv ../rtl/altsyncram.v
vlog -sv ../rtl/RAM2p.v
vlog -sv ../rtl/RAM2p_bb.v
vlog -sv ../rtl/sort.sv
vlog -sv sort_tb.sv

vsim -novopt serializer_tb
add log -r /*
add wave -r *
run -all