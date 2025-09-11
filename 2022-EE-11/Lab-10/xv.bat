@echo off
del wlf*
rmdir /s /q work

vlog -work work +acc -sv -stats=none 10.sv 
vlog -work work +acc -sv -stats=none 10_tb.sv 

pause



