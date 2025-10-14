class ahb_seq_item extends uvm_sequence_item;

 logic hclk;
 rand logic hresetn;

 rand logic [31:0] haddr;
 rand logic [31:0] hwdata;
 rand logic hwrite;
 rand logic [2:0] hsize;
 rand logic [1:0] htrans;

 logic [31:0] hrdata;
 logic hready;
 logic hresp;
 
 `uvm_object_utils_begin(ahb_seq_item)
   `uvm_field_int(hclk,UVM_ALL_ON)

   `uvm_field_int(hresetn,UVM_ALL_ON | UVM_RAND)
   `uvm_field_int(hwdata,UVM_ALL_ON | UVM_RAND)
   `uvm_field_int(hwdata,UVM_ALL_ON | UVM_RAND)
   `uvm_field_int(hwrite,UVM_ALL_ON | UVM_RAND)
   `uvm_field_int(hsize,UVM_ALL_ON | UVM_RAND)
   `uvm_field_int(htrans,UVM_ALL_ON | UVM_RAND)

   `uvm_field_int(hrdata,UVM_ALL_ON)
   `uvm_field_int(hready,UVM_ALL_ON)
   `uvm_field_int(hresp,UVM_ALL_ON)
 `uvm_object_utils_end

 function new(string name="ahb_seq_item");
  super.new(name);
 endfunction

// This method overrides the default print function and provides clean formatting.
 virtual function void do_print(uvm_printer printer);
   super.do_print(printer);
   printer.print_field_int("hclk",    hclk,    1, UVM_BIN);
   printer.print_field_int("hresetn", hresetn, 1, UVM_BIN);
   printer.print_field_int("hwrite",  hwrite,  1, UVM_BIN);
   printer.print_field_int("htrans",  htrans,  2, UVM_BIN);
   printer.print_field_int("hsize",   hsize,   3, UVM_DEC);
        
   printer.print_field_int("haddr",   haddr,   32, UVM_HEX);
   printer.print_field_int("hwdata",  hwdata,  32, UVM_HEX);

   printer.print_field_int("hrdata",  hrdata,  32, UVM_HEX);
   printer.print_field_int("hready",  hready,  1, UVM_BIN);
   printer.print_field_int("hresp",   hresp,   1, UVM_BIN);

  endfunction

endclass
