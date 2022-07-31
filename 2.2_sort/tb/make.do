vlib work

vlog -sv ../rtl/RAM2p.v
vlog -sv ../rtl/sort.sv
vlog -sv sort_tb.sv

vsim -L altera_mf_ver -L lpm_ver -L cycloneiii_ver -L cycloneii_ver work.sort_tb 
vsim -novopt sort_tb.sv

add log -r /*
add wave -r *
run -all