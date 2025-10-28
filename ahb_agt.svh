`include "uvm_macros.svh" 
`include "ahb_sequencer.svh"
`include "ahb_driver.svh"
`include "ahb_monitor.svh"
import uvm_pkg::*;

class ahb_agt extends uvm_agent;
 `uvm_component_utils(ahb_agt)

 function new(string name="ahb_agt",uvm_component parent);
  super.new(name,parent);
 endfunction

 ahb_sequencer ahb_seqr;
 ahb_driver ahb_drv;
 ahb_monitor ahb_mon;

 virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  ahb_mon = ahb_monitor::type_id::create("ahb_mon",this);
  ahb_seqr = ahb_sequencer::type_id::create("ahb_seqr",this);
  ahb_drv = ahb_driver::type_id::create("ahb_drv",this);
 endfunction

 virtual function void connect_phase(uvm_phase phase);
  ahb_drv.seq_item_port.connect(ahb_seqr.seq_item_export);
 endfunction

endclass
