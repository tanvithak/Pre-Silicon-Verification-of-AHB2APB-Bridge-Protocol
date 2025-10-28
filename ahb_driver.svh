`include "uvm_macros.svh" 
`include "ahb_seq_item.svh"
import uvm_pkg::*;
class ahb_driver extends uvm_driver#(ahb_seq_item);
 `uvm_component_utils(ahb_driver)
 virtual ahb_intf ahb_vif;

 ahb_seq_item req;
 
 function new(string name="ahb_driver",uvm_component parent);
  super.new(name,parent);
 endfunction

 virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db#(virtual ahb_intf)::get(this,"","ahb_vif",ahb_vif))
   `uvm_fatal(get_full_name(), "Getting virtual interface from the configuration failed")
 endfunction

 virtual task run_phase(uvm_phase phase);
  req = ahb_seq_item::type_id::create("req");
  @(ahb_vif.ahb_drv_cb);
  ahb_vif.ahb_drv_cb.HRESETn <= 1'b0;

  @(ahb_vif.ahb_drv_cb);
  ahb_vif.ahb_drv_cb.HRESETn <= 1'b1;

  forever
   begin
    
    seq_item_port.get_next_item(req);
    send_to_dut(req);
    req.print();
    seq_item_port.item_done();	
   end
 endtask

 task send_to_dut(ahb_seq_item xtn);

    ahb_vif.AHB_DRV_MP.ahb_drv_cb.HADDR <= xtn.haddr;
    ahb_vif.AHB_DRV_MP.ahb_drv_cb.HTRANS <= xtn.htrans;
    ahb_vif.AHB_DRV_MP.ahb_drv_cb.HSIZE <= xtn.hsize; 
    ahb_vif.AHB_DRV_MP.ahb_drv_cb.HWRITE <= xtn.hwrite;
    ahb_vif.AHB_DRV_MP.ahb_drv_cb.HREADY_IN <= 1;

  @(posedge ahb_vif.AHB_DRV_MP.ahb_drv_cb) 
   wait (ahb_vif.HREADY_OUT);
 
  if(xtn.hwrite)
   begin
    //write operation 
    ahb_vif.AHB_DRV_MP.ahb_drv_cb.HWDATA <= xtn.hwdata; 
   end
  else
   begin
    //ready operation
    ahb_vif.AHB_DRV_MP.ahb_drv_cb.HWDATA <= 'x;  
   end

 endtask

endclass
