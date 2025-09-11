@echo off
call xv.bat
if %ERRORLEVEL% GEQ 1 EXIT /B 1
vsim -gui work.axi4_lite_slave_tb -voptargs="+acc" -do "do wave.do;run -all; quit" 

