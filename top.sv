`include "uvm_macros.svh"
`include "ahb_apb_pkg.sv"

module top();

  import uvm_pkg::*;
  import bridge_pkg::*;

  // Clock signal
  bit clk;

  // Interface instances

  ahb_intf ahb_vif(clk);
  apb_intf apb_vif(clk);


  // DUT instantiation
  rtl_top dut(
    .Hclk(clk),
    .Hresetn(ahb_vif.HRESETn),
    .Htrans(ahb_vif.HTRANS),
    .Hsize(ahb_vif.HSIZE),
    .Hreadyin(1'b1),
    .Hwdata(ahb_vif.HWDATA),
    .Haddr(ahb_vif.HADDR),
    .Hwrite(ahb_vif.HWRITE),
    .Prdata(apb_vif.PRDATA),
    .Hrdata(ahb_vif.HRDATA),
    .Hresp(ahb_vif.HRESP),
    .Hreadyout(ahb_vif.HREADY_OUT),
    .Pselx(apb_vif.PSEL),
    .Pwrite(apb_vif.PWRITE),
    .Penable(apb_vif.PENABLE),
    .Paddr(apb_vif.PADDR),
    .Pwdata(apb_vif.PWDATA)

  );

  // Clock generation
  initial
    begin
      clk = 1'b0;
      forever #5 clk = ~clk;
    end


  initial
   begin
    ahb_vif.HRESETn = 1'b0;
    repeat(10)  @(posedge clk);
    ahb_vif.HRESETn = 1'b1;
   end

  assign apb_vif.PRESETn = ahb_vif.HRESETn;


  // Set virtual interfaces and run UVM test
  initial 
   begin
    //uvm_factory::get().print();	
    uvm_config_db #(virtual ahb_intf)::set(null, "*", "ahb_intf", ahb_vif);
    uvm_config_db #(virtual apb_intf)::set(null, "*", "apb_intf", apb_vif);

    run_test("test_two");
  end

endmodule
