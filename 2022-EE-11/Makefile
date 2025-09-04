# Efficient Makefile for Verilog projects
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Define task directories
TASKS = Lab-01A_ALU Lab-01B_PriEnc Lab-02A_BarrelShft Lab-02B_Bin2BCD Lab-03_ProgCount Lab-04A_TrafficCtrl Lab-04B_Vending Lab-05_MModTimer Lab-06_SRAMCtrl Lab-07A_SyncFIFO Lab-07B_AsyncFIFO Lab-08A_UARTTransmitter Lab-08B_UARTReceiver Lab-09_SPIMasterCtrl Lab-10_Axi4LiteSlave

# Compile all tasks
all: compile run

compile:
	@echo "=== Compiling all modules ==="
	@for dir in $(TASKS); do \
		prefix=$$(echo $$dir | sed 's/Lab-0*\([0-9]*[A-Z]*\)_.*/\1/'); \
		cd $$dir && $(IVERILOG) -g2012 -o $${prefix}_test $${prefix}_tb.sv $${prefix}.sv; \
		cd .. ; \
	done

run:
	@echo "=== Running all simulations ==="
	@for dir in $(TASKS); do \
		prefix=$$(echo $$dir | sed 's/Lab-0*\([0-9]*[A-Z]*\)_.*/\1/'); \
		cd $$dir && $(VVP) $${prefix}_test; \
		cd .. ; \
	done

wave:
	@echo "=== Opening all waveforms ==="
	@for dir in $(TASKS); do \
		prefix=$$(echo $$dir | sed 's/Lab-0*\([0-9]*[A-Z]*\)_.*/\1/'); \
		cd $$dir && $(GTKWAVE) $${prefix}.vcd & \
		cd .. ; \
	done

clean:
	@echo "=== Cleaning all files ==="
	@for dir in $(TASKS); do \
		rm -f $$dir/*_test $$dir/*.vcd; \
	done

help:
	@echo "Available targets:"
	@echo "  all       - Compile and run all"
	@echo "  compile   - Compile all modules"
	@echo "  run       - Run all simulations"
	@echo "  wave      - Open all waveforms"
	@echo "  clean     - Remove generated files"

.PHONY: all compile run wave clean help
