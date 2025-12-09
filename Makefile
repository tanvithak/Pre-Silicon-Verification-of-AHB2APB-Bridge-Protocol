
# -----------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------
# Source Files
# FIXED: Added missing RTL source files (ahb_slave, apb_controller, etc.)
# Order is important: Definitions -> Submodules -> Top Modules -> TB
RTL_SRC   = definitions.v \
            ahb_intf.sv \
            apb_intf.sv \
            ahb_slave.v \
            apb_controller.v \
            apb_interface.v \
            ahb_apb_top.v \
            ahb_apb_pkg.sv \
            top.sv

# List of all tests for regression
TEST_LIST = test_one test_two test_three test_four test_five test_six test_pipeline test_config test_seven test_eight

# Default Test
TEST      ?= test_one

# Random Seed
SEED      ?= $(shell date +%s)

# Output Directories
LOG_DIR   = regression_logs
COV_DIR   = coverage_data

# -----------------------------------------------------------
# TARGETS
# -----------------------------------------------------------
.PHONY: all compile run regression report clean

all: compile regression report

# 1. COMPILATION
# Added +cover=bcesf to enable Code Coverage
compile:
	vlog +cover=bcesf $(RTL_SRC)

# 2. RUN SINGLE TEST
# Usage: make run TEST=test_three
run: compile
	@mkdir -p $(COV_DIR)
	vsim -c -voptargs="+acc" -coverage -sv_seed $(SEED) -t 1ns \
	+UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=UVM_LOW \
	-do "coverage save -onexit $(COV_DIR)/$(TEST).ucdb; run -all; exit" \
	work.top -l $(TEST).log

# 3. REGRESSION SUITE
regression: compile
	@echo "------------------------------------------------"
	@echo "  STARTING REGRESSION (Seed: $(SEED))"
	@echo "------------------------------------------------"
	@mkdir -p $(LOG_DIR)
	@mkdir -p $(COV_DIR)
	@rm -f $(COV_DIR)/*.ucdb 
	@pass_count=0; \
	fail_count=0; \
	for t in $(TEST_LIST); do \
		echo "Running $$t..."; \
		logfile="$(LOG_DIR)/$$t.log"; \
		covfile="$(COV_DIR)/$$t.ucdb"; \
		vsim -c -voptargs="+acc" -coverage -sv_seed $(SEED) -t 1ns \
			+UVM_TESTNAME=$$t +UVM_VERBOSITY=UVM_LOW \
			-do "coverage save -onexit $$covfile; run -all; exit" \
			work.top > $$logfile 2>&1; \
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

# 4. COVERAGE REPORT
report:
	@echo "Checking for coverage files..."
	@if ls $(COV_DIR)/*.ucdb 1> /dev/null 2>&1; then \
		echo "Merging coverage files..."; \
		vcover merge $(COV_DIR)/merged_coverage.ucdb $(COV_DIR)/*.ucdb; \
		echo "Generating HTML report..."; \
		vcover report -html $(COV_DIR)/merged_coverage.ucdb -output cov_html; \
		echo "------------------------------------------------"; \
		echo "Coverage Report generated in: cov_html/index.html"; \
		echo "------------------------------------------------"; \
	else \
		echo "ERROR: No .ucdb files found in $(COV_DIR). Run 'make regression' first."; \
	fi

# 5. CLEANUP
clean:
	rm -rf work transcript *.log $(LOG_DIR) $(COV_DIR) cov_html *.ucdb




# -----------------------------------------------------------
# 5. COVERAGE SUMMARY (Clean & Readable)
# -----------------------------------------------------------
coverage_summary:
	@echo "================================================="
	@echo "         PROCESSING COVERAGE DATA                "
	@echo "================================================="
	
	# 1. Merge all test files into one database (suppress huge output)
	@if ls $(COV_DIR)/*.ucdb 1> /dev/null 2>&1; then \
		vcover merge $(COV_DIR)/merged_coverage.ucdb $(COV_DIR)/*.ucdb > /dev/null; \
	else \
		echo "ERROR: No .ucdb files found. Run 'make regression' first."; \
		exit 1; \
	fi

	# 2. Generate a SUMMARY report (not details)
	@vcover report -summary -codeAll -cvg -file $(COV_DIR)/summary.txt $(COV_DIR)/merged_coverage.ucdb > /dev/null

	# 3. Print the clean results to the terminal
	@echo ""
	@echo "-------------------------------------------------"
	@echo "           COVERAGE RESULTS SUMMARY              "
	@echo "-------------------------------------------------"
	@echo "CODE COVERAGE:"
	@grep "Statement" $(COV_DIR)/summary.txt | head -n 1 || echo "  Statement : N/A"
	@grep "FSM"       $(COV_DIR)/summary.txt | head -n 1 || echo "  FSM       : N/A"
	@echo ""
	@echo "FUNCTIONAL COVERAGE:"
	@grep "Covergroup" $(COV_DIR)/summary.txt | head -n 1 || echo "  Covergroup: N/A"
	@echo ""
	@echo "OVERALL:"
	@grep "Total Coverage" $(COV_DIR)/summary.txt | head -n 1 || echo "  Total     : N/A"
	@echo "-------------------------------------------------"
	@echo "For detailed HTML report, run: make report"
	@echo "================================================="
