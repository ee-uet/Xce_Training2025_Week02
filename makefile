files=./defines/*.sv ./lab1/*.sv ./lab2/*.sv ./lab3/*.sv ./lab4/*.sv
c:
	@vlib work
	vlog -sv $(files)
l1:clean l1t1 l1t2  clean
l2:clean l2t1 l2t2  clean
l2:clean l3t1 clean
l1t1: clean run_l1t1  clean
l1t2: clean run_l1t2  clean
l2t1: clean run_l2t1  clean
l2t2: clean run_l2t2  clean
l3t1: clean run_l3t1  clean
l4t1: clean run_l4t1  clean
run_l1t1: c
	vsim -c -voptargs="+acc" alu_tb -do "run -all; quit"
sim_l1t1:c
	vsim -gui -voptargs="+acc" alu_tb -do "add wave -r /*;run -all; quit"
run_l1t2:c
	vsim -c -voptargs="+acc" Priority_Encoder_tb -do "run -all; quit"
sim_l1t2:c
	vsim -gui -voptargs="+acc" Priority_Encoder_tb -do "add wave -r /*;run -all; quit"
run_l2t1:c
	vsim -c -voptargs="+acc" barrel_shifter_tb -do "run -all; quit"
sim_l2t1:c
	vsim -gui -voptargs="+acc" barrel_shifter_tb -do "add wave -r /*;run -all; quit"
run_l2t2:c
	vsim -c -voptargs="+acc" binary_to_bcd_tb -do "run -all; quit"
sim_l2t2:c
	vsim -gui -voptargs="+acc" binary_to_bcd_tb -do "add wave -r /*;run -all; quit"
run_l3t1:c
	vsim -c -voptargs="+acc" programmable_counter_tb -do "run -all; quit"
sim_l3t1:c
	vsim -gui -voptargs="+acc" programmable_counter_tb -do "add wave -r /*;run -all; quit"
run_l4t1:c
	vsim -c -voptargs="+acc" traffic_controller_tb -do "run -all; quit"
sim_l4t1:c
	vsim -gui -voptargs="+acc" traffic_controller_tb -do "add wave -r /*;run -all; quit"
clean:
	@rm -rf work transcript vsim.wlf 
