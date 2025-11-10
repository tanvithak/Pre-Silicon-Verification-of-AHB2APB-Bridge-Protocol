class ahb_seq_item extends uvm_sequence_item;

 `uvm_object_utils(ahb_seq_item)

 logic hclk;
 logic hresetn;

 rand logic [31:0] haddr;
 rand logic [31:0] hwdata;
 rand logic hwrite;
 rand logic [2:0] hsize;
 rand logic [1:0] htrans;
 rand logic [2:0] hburst;

 logic [31:0] hrdata;
 logic hready;
 logic hresp;

 rand logic [7:0] length;

 constraint valid_hsize{hsize inside {[0:2]};}

 constraint Hsize_count {hsize dist { 3'b000:=3, 3'b001:=3, 3'b010:=3};}

 constraint valid_length {(2**hsize) * length <= 1024;}

 function new(string name="ahb_seq_item");
  super.new(name);
 endfunction

// This method overrides the default print function and provides clean formatting.
 virtual function void do_print(uvm_printer printer);
   super.do_print(printer);
   printer.print_field("hclk",    hclk,    1, UVM_BIN);
   printer.print_field("hresetn", hresetn, 1, UVM_BIN);
   printer.print_field("hwrite",  hwrite,  1, UVM_BIN);
   printer.print_field("htrans",  htrans,  2, UVM_BIN);
   printer.print_field("hsize",   hsize,   3, UVM_DEC);
        
   printer.print_field("haddr",   haddr,   32, UVM_HEX);
   printer.print_field("hwdata",  hwdata,  32, UVM_HEX);

   printer.print_field("hrdata",  hrdata,  32, UVM_HEX);
   printer.print_field("hready",  hready,  1, UVM_BIN);
   printer.print_field("hresp",   hresp,   1, UVM_BIN);

  endfunction

endclass
