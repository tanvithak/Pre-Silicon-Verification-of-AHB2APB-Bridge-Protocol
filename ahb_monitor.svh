`include "uvm_macros.svh" 
`include "ahb_seq_item.svh"
import uvm_pkg::*;

class ahb_monitor extends uvm_monitor;
 `uvm_component_utils(ahb_monitor)

 virtual ahb_intf ahb_vif;
 
 uvm_analysis_port #(ahb_seq_item) ahb_ap;

 function new(string name="ahb_monitor",uvm_component parent);
  super.new(name,parent);
 endfunction

 virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db#(virtual ahb_intf)::get(this,"","ahb_vif",ahb_vif))
   `uvm_fatal(get_full_name(), "Getting virtual interface from the configuration failed")
 endfunction

endclass
