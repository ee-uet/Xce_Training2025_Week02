PROJECT_ROOT = /home/aziz/Documents/xceleroum_training/Xce_Training2025_Week02/Muhammad_Boota

files = $(PROJECT_ROOT)/defines/*.sv \
        $(PROJECT_ROOT)/lab2/task_2/src/*.sv \
        $(PROJECT_ROOT)/lab2/task_2/tests/*.sv
all:clean c run
c:
	@vlib work
	vlog -sv $(files)

run:c
	vsim -c -voptargs="+acc" binary_to_bcd_tb -do "run -all; quit"
sim:c
	vsim -gui -voptargs="+acc" binary_to_bcd_tb -do "add wave -r /*;run -all; quit"
clean:
	@rm -rf work transcript vsim.wlf 
