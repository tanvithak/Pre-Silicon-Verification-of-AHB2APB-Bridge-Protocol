class apb_seqs extends uvm_sequence #(apb_seq_item);
 `uvm_object_utils(apb_seqs)

 function new(string name="apb_seqs");
  super.new(name);
 endfunction

 task body;
  `uvm_info(get_type_name(), "Executing apb_seqs sequence", UVM_LOW)
  repeat(5)
   `uvm_do(req)
 endtask

endclass
