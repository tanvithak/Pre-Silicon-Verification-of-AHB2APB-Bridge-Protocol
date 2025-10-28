`include "uvm_macros.svh" 
`include "apb_seq_item.svh"
import uvm_pkg::*;

class apb_monitor extends uvm_monitor;
 `uvm_component_utils(apb_monitor)

 virtual apb_intf apb_vif;
 
 uvm_analysis_port #(apb_seq_item) apb_ap;

 function new(string name="apb_monitor",uvm_component parent);
  super.new(name,parent);
 endfunction

 virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db#(virtual apb_intf)::get(this,"","apb_vif",apb_vif))
   `uvm_fatal(get_full_name(), "Getting virtual interface from the configuration failed")
 endfunction

endclass
