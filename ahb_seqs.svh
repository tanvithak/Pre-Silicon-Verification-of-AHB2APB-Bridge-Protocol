`include "uvm_macros.svh" 
`include "ahb_seq_item.svh"
import uvm_pkg::*;

class ahb_seqs extends uvm_sequence#(ahb_seq_item);
 `uvm_object_utils(ahb_seqs)

 function new(string name="ahb_seqs");
  super.new(name);
 endfunction

 task body;
  `uvm_info(get_type_name(), "Executing ahb_seqs sequence", UVM_LOW)
  repeat(5)
   `uvm_do(req)
 endtask

endclass
