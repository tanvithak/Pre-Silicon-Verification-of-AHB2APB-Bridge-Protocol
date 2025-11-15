class ahb_apb_vseq extends uvm_sequence;
 `uvm_object_utils(ahb_apb_vseq)
 
 `uvm_declare_p_sequencer(ahb_apb_vseqr)
 
 function new(string name="ahb_apb_vseq");
  super.new(name);
 endfunction
 
 virtual task body();
  ahb_sequencer ahb_sqrh = p_sequencer.ahb_sqr;
  ahb_write_sequence write_seq;
  
  if(ahb_sqrh == null) 
    `uvm_fatal(get_type_name(), "AHB Sequencer handle is null")
    
    
  repeat(10)
   begin
    write_seq = ahb_write_sequence::type_id::create("write_seq");
    `uvm_do_on(write_seq, ahb_sqrh)
   end
 endtask
endclass
