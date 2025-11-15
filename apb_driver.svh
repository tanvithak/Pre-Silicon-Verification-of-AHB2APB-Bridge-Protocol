class apb_driver extends uvm_driver#(apb_seq_item);
 `uvm_component_utils(apb_driver)
 virtual apb_intf apb_vif;

 apb_seq_item req;
 
 function new(string name="apb_driver",uvm_component parent);
  super.new(name,parent);
 endfunction

 virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db#(virtual apb_intf)::get(this,"","apb_intf",apb_vif))
   `uvm_fatal(get_full_name(), "Getting virtual interface from the configuration failed")
 endfunction


 virtual task run_phase(uvm_phase phase);
  forever
   begin
    seq_item_port.get_next_item(req);
    send_to_dut(req);
    req.print();
    seq_item_port.item_done();
   end
 endtask

 task send_to_dut(apb_seq_item apb_xtn);
  apb_vif.APB_DRV_MP.APB_DRV_CB.PRESETn <= apb_xtn.presetn;
  apb_vif.APB_DRV_MP.APB_DRV_CB.PENABLE <= apb_xtn.penable;
  apb_vif.APB_DRV_MP.APB_DRV_CB.PSEL <= apb_xtn.psel;
  apb_vif.APB_DRV_MP.APB_DRV_CB.PWRITE <= apb_xtn.pwrite;
  apb_vif.APB_DRV_MP.APB_DRV_CB.PADDR <= apb_xtn.paddr;

  if(apb_xtn.pwrite)
   apb_vif.APB_DRV_MP.APB_DRV_CB.PWDATA <= apb_xtn.pwdata;
  else
   apb_vif.APB_DRV_MP.APB_DRV_CB.PWDATA <= 'x;
 endtask


endclass
