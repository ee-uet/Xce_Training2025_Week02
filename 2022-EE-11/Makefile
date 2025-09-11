# Efficient Makefile for Verilog projects
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Define task directories
TASKS = Lab-01A Lab-01B Lab-02A Lab-02B Lab-03 Lab-04A Lab-04B Lab-05 Lab-06 Lab-07A Lab-07B Lab-08A Lab-08B Lab-09 Lab-10

# Compile all tasks
all: compile run

compile:
	@echo "=== Compiling all modules ==="
	@for dir in $(TASKS); do \
		prefix=$$(echo $$dir | sed 's/Lab-0*\([0-9]*[A-Z]*\)/\1/'); \
		cd $$dir && $(IVERILOG) -g2012 -o $${prefix}_test $${prefix}_tb.sv $${prefix}.sv; \
		cd .. ; \
	done

run:
	@echo "=== Running all simulations ==="
	@for dir in $(TASKS); do \
		prefix=$$(echo $$dir | sed 's/Lab-0*\([0-9]*[A-Z]*\)/\1/'); \
		cd $$dir && $(VVP) $${prefix}_test; \
		cd .. ; \
	done

wave:
	@echo "=== Opening all waveforms ==="
	@for dir in $(TASKS); do \
		prefix=$$(echo $$dir | sed 's/Lab-0*\([0-9]*[A-Z]*\)/\1/'); \
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
