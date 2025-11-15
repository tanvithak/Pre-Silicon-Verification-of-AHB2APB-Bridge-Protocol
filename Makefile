.PHONY: all compile run_coverage run clean report

# Default target
#all: clean compile run_coverage report

compile:
	vlog ahb_intf.svh apb_intf.svh ahb_apb_top.v top.svh 

#run_coverage:
#	vsim -cvgperinstance -c Bridge_Top top -do "coverage save -onexit covfile.ucdb; run -all; exit" 


run:
	vsim -c top -do "vsim -Q -timescale 1ns/1ns -access +rw +UVM_TESTNAME=test_one +UVM_VERBOSITY=UVM_NONE -uvmnocdnsextra work.top; run -all; quit"


clean:
	rm -rf work
	rm -rf transcript

#report:
#	vsim -cvgperinstance -viewcov covfile.ucdb -do "coverage report -file ahb_apb_bridge_report.txt -byfile -detail -noannotate -option -cvg"
