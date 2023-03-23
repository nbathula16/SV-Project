vlib work
vdel -all
vlib work

vlog main.sv -lint
vlog testbench.sv -lint


vsim work.top 


vlog -cover bcst -sv testbench.sv
vsim -coverage -c top

run -all
