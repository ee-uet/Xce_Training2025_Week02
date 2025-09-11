@echo off
call xv
if %ERRORLEVEL% GEQ 1 EXIT /B 1
vsim -c work.axi4_lite_slave_tb -voptargs="+acc" -do "run -all; quit" 
