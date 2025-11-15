package bridge_pkg;
 `include "uvm_macros.svh" 
 import uvm_pkg::*;

 `include "bridge_cfg.svh"
 `include "ahb_seq_item.svh"
 `include "ahb_monitor.svh"
 `include "ahb_sequencer.svh"
 `include "ahb_seqs.svh"
 `include "ahb_driver.svh"
 `include "ahb_agt.svh"

 `include "apb_seq_item.svh"
 `include "apb_monitor.svh"
 `include "apb_sequencer.svh"
 `include "apb_seqs.svh"
 `include "apb_driver.svh"
 `include "apb_agt.svh"

 `include "scoreboard.svh"
 `include "virtual_sequencer.svh"
 `include "virtual_sequence.svh"
 `include "envir.svh"
 `include "test.svh"

endpackage
