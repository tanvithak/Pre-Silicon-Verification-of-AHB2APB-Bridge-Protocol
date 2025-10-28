`include "uvm_macros.svh" 
`include "ahb_seq_item.svh"
import uvm_pkg::*;
class ahb_sequencer extends uvm_sequencer#(ahb_seq_item);
 `uvm_component_utils(ahb_sequencer)
 
 function new(string name="ahb_sequencer",uvm_component parent);
  super.new(name,parent);
 endfunction

endclass
