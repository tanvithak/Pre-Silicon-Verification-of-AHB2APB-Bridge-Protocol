package bridge_pkg;
 `include "uvm_macros.svh" 
 import uvm_pkg::*;

 `include "bridge_cfg.sv"
 `include "ahb_seq_item.sv"
 `include "ahb_sequencer.sv"
 `include "ahb_driver.sv"
 `include "ahb_monitor.sv"
 `include "ahb_agt.sv"

 `include "apb_seq_item.sv"
 `include "apb_sequencer.sv"
 `include "apb_driver.sv"
 `include "apb_monitor.sv"
 `include "apb_agt.sv"

 `include "scoreboard.sv"

 `include "envir.sv"


 `include "ahb_seqs.sv"
 `include "apb_seqs.sv"
 `include "test.sv"

endpackage
