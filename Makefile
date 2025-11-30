# -----------------------------------------------------------

# VARIABLES

# -----------------------------------------------------------

# Source Files

RTL_SRC   = ahb_intf.sv apb_intf.sv ahb_apb_pkg.sv top.sv

# (Note: I added bridge_pkg.sv because it contains your environment classes)



# List of all tests for regression

TEST_LIST = test_one test_two test_three test_four



# Default Test (if you just type 'make run')

TEST      ?= test_one



# Random Seed (Default is random based on system time)

SEED      ?= $(shell date +%s)



# Log Directory

LOG_DIR   = regression_logs



# -----------------------------------------------------------

# TARGETS

# -----------------------------------------------------------

.PHONY: all compile run regression clean report



all: compile regression



# 1. COMPILATION

compile:

vlog $(RTL_SRC)



# 2. RUN SINGLE TEST

# Usage: make run TEST=test_three SEED=123

run: compile

vsim -c -voptargs="+acc" -sv_seed $(SEED) -t 1ns \

+UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=UVM_LOW \

-do "run -all; exit" work.top -l $(TEST).log



# 3. REGRESSION SUITE

regression: compile

@echo "------------------------------------------------"

@echo "  STARTING REGRESSION (Seed: $(SEED))"

@echo "------------------------------------------------"

@mkdir -p $(LOG_DIR)

@pass_count=0; \

fail_count=0; \

for t in $(TEST_LIST); do \

echo "Running $$t..."; \

logfile="$(LOG_DIR)/$$t.log"; \

vsim -c -voptargs="+acc" -sv_seed $(SEED) -t 1ns \

+UVM_TESTNAME=$$t +UVM_VERBOSITY=UVM_LOW \

-do "run -all; exit" work.top > $$logfile 2>&1; \

\

if grep -q "UVM_ERROR :    0" $$logfile && grep -q "UVM_FATAL :    0" $$logfile; then \

echo "  -> [PASS] $$t"; \

pass_count=$$((pass_count + 1)); \

else \

echo "  -> [FAIL] $$t (Check $$logfile)"; \

fail_count=$$((fail_count + 1)); \

fi; \

done; \

echo "------------------------------------------------"; \

echo "  SUMMARY: PASS=$$pass_count  FAIL=$$fail_count"; \

echo "------------------------------------------------"



# 4. CLEANUP

clean:

rm -rf work transcript *.log $(LOG_DIR)
