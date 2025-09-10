PROJECT_ROOT = /home/aziz/Documents/xceleroum_training/Xce_Training2025_Week02/Muhammad_Boota

files = $(PROJECT_ROOT)/defines/*.sv \
        $(PROJECT_ROOT)/lab5/src/*.sv \
        $(PROJECT_ROOT)/lab5/tests/*.sv
all:clean c run
c:
	@vlib work
	vlog -sv $(files)
run_l5t1:c
	vsim -c -voptargs="+acc" multi_mode_timer_tb -do "run -all; quit"
sim_l5t1:c
	vsim -gui -voptargs="+acc" multi_mode_timer_tb -do "add wave -r /*;run -all; quit"
clean:
	@rm -rf work transcript vsim.wlf 
