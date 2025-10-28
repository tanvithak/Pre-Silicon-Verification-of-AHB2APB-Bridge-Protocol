 `include "uvm_macros.svh" 
 import uvm_pkg::*;
`include "ahb_agt.svh"
`include "apb_agt.svh"

class envir extends uvm_env;
 `uvm_component_utils(envir)

 ahb_agt ahb_agt1;
 apb_agt apb_agt1;

 function new(string name="envir",uvm_component parent);
  super.new(name,parent);
 endfunction

 function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  ahb_agt1 = ahb_agt::type_id::create("ahb_agt1",this);
  apb_agt1 = apb_agt::type_id::create("apb_agt1",this);
 endfunction
endclass
