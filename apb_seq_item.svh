class apb_seq_item extends uvm_sequence_item;
 `uvm_object_utils(apb_seq_item)

 bit clk;
 bit presetn;
 logic penable;
 logic pwrite;
 logic psel;
 logic [31:0] paddr;
 logic [31:0] pwdata;

 rand logic [31:0] prdata;
 logic pready;

 function new(string name="apb_seq_item");
  super.new(name);
 endfunction

 virtual function void do_print(uvm_printer printer);
   super.do_print(printer);
   printer.print_field("clk",     clk,     1, UVM_BIN);
   printer.print_field("presetn", presetn, 1, UVM_BIN);
   printer.print_field("pwrite",  pwrite,  1, UVM_BIN);
   printer.print_field("penable", penable, 2, UVM_BIN);
   printer.print_field("psel",    psel,    3, UVM_DEC);
        
   printer.print_field("paddr",   paddr,   32, UVM_HEX);
   printer.print_field("pwdata",  pwdata,  32, UVM_HEX);

   printer.print_field("prdata",  prdata,  32, UVM_HEX);
   printer.print_field("pready",  pready,  1, UVM_BIN);

  endfunction
endclass
