class apb_seq_item extends uvm_sequence_item;

 logic pclk;
 logic presetn;
 logic [31:0] paddr;
 logic [31:0] pwdata;
 logic pwrite;
 logic psel;
 logic penable;

 rand logic [31:0] prdata;
 rand logic pready;


 `uvm_object_utils_begin(apb_seq_item)
   `uvm_field_int(pclk,UVM_ALL_ON)
   `uvm_field_int(presetn,UVM_ALL_ON)
   `uvm_field_int(paddr,UVM_ALL_ON)
   `uvm_field_int(pwdata,UVM_ALL_ON)
   `uvm_field_int(pwrite,UVM_ALL_ON)
   `uvm_field_int(psel,UVM_ALL_ON)
   `uvm_field_int(penable,UVM_ALL_ON)
   `uvm_field_int(prdata,UVM_ALL_ON | UVM_RAND)
   `uvm_field_int(pready,UVM_ALL_ON | UVM_RAND)
 `uvm_object_utils_end

 
 function new(string name="apb_seq_item");
  super.new(name);
 endfunction

 virtual function void do_print(uvm_printer printer);
  super.do_print(print)
  printer.print_field_int("pclk",    pclk,    1,  UVM_BIN);
  printer.print_field_int("presetn", presetn, 1,  UVM_BIN);
  printer.print_field_int("pwrite",  pwrite,  1,  UVM_BIN);
  printer.print_field_int("psel",    psel,    1,  UVM_BIN);
  printer.print_field_int("penable", penable, 1,  UVM_BIN);

  printer.print_field_int("paddr",   paddr,   32, UVM_HEX);
  printer.print_field_int("pwdata",  pwdata,  32, UVM_HEX);

  printer.print_field_int("prdata",  prdata,  32, UVM_HEX);
  printer.print_field_int("pready",  pready,  1,  UVM_BIN);
 endfunction

endclass
