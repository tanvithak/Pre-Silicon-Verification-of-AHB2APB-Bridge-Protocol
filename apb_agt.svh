`include "uvm_macros.svh" 
`include "apb_sequencer.svh"
`include "apb_driver.svh"
`include "apb_monitor.svh"
import uvm_pkg::*;

class apb_agt extends uvm_agent;
 `uvm_component_utils(apb_agt)

 function new(string name="apb_agt",uvm_component parent);
  super.new(name,parent);
 endfunction

 apb_sequencer apb_seqr;
 apb_driver apb_drv;
 apb_monitor apb_mon;

 virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  apb_mon = apb_monitor::type_id::create("apb_mon",this);
  apb_seqr = apb_sequencer::type_id::create("apb_seqr",this);
  apb_drv = apb_driver::type_id::create("apb_drv",this);
 endfunction

 virtual function void connect_phase(uvm_phase phase);
  apb_drv.seq_item_port.connect(apb_seqr.seq_item_export);
 endfunction

endclass
