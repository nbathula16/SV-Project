vlib work
vdel -all
vlib work

vlog main.sv
vlog testbench.sv -lint +acc


vsim work.top 

add wave -r *

vlog -cover bcst -sv testbench.sv
vsim -coverage -c top

run -all
