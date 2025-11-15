class ahb_apb_vseqr extends uvm_sequencer;
 `uvm_component_utils(ahb_apb_vseqr)
 
 ahb_sequencer ahb_sqr;
 apb_sequencer apb_sqr;
 
 function new(string name="ahb_apb_vseqr",uvm_component parent);
  super.new(name,parent);
 endfunction
 
endclass
