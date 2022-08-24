vlib work

vlog -sv ../rtl/lifo.sv
vlog -sv lifo_tb.sv

vsim -L altera_mf_ver -L lpm_ver -L cycloneiii_ver -L cycloneii_ver work.lifo_tb 
vsim -novopt lifo_tb.sv

add log -r /*
add wave -r *
run -all