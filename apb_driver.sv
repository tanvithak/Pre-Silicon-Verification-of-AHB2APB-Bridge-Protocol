class apb_driver extends uvm_driver #(apb_seq_item);
 `uvm_component_utils(apb_driver)

 virtual apb_intf apb_vif;
 bridge_cfg ahb_apb_cfg;

 
 function new(string name="apb_driver",uvm_component parent=null);
  super.new(name,parent);
 endfunction

 virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db # (bridge_cfg)::get(this,"","bridge_cfg",ahb_apb_cfg))
   `uvm_fatal(get_full_name(), "Getting the configuration failed")
 endfunction


 function void connect_phase(uvm_phase phase);
  apb_vif = ahb_apb_cfg.apb_vif;
 endfunction

 virtual task run_phase(uvm_phase phase);
  forever
   begin
    seq_item_port.get_next_item(req);
    send_to_dut(req);
    `uvm_info("apb_driver","Generating apb_seq_item after send_to_dut task",UVM_LOW)
    req.print();
    seq_item_port.item_done();
   end
 endtask

 task send_to_dut(apb_seq_item apb_xtn);
  @(posedge apb_vif.CLK);

  apb_vif.APB_DRV_CB.PREADY <= apb_xtn.pready;
  apb_vif.APB_DRV_CB.PRDATA <= apb_xtn.prdata;

   
 endtask


endclass
