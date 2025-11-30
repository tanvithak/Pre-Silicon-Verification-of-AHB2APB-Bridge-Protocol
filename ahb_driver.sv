class ahb_driver extends uvm_driver #(ahb_seq_item);
 `uvm_component_utils(ahb_driver)

 virtual ahb_intf ahb_vif;

 bridge_cfg ahb_apb_cfg;
 
 function new(string name="ahb_driver",uvm_component parent);
  super.new(name,parent);
 endfunction

 virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db #(bridge_cfg)::get(this,"","bridge_cfg",ahb_apb_cfg))
   `uvm_fatal(get_full_name(), "Getting the configuration failed")
 endfunction

 function void connect_phase(uvm_phase phase);
  ahb_vif = ahb_apb_cfg.ahb_vif;
 endfunction

 
 virtual task run_phase(uvm_phase phase);
  forever
   begin   
    seq_item_port.get_next_item(req);
    send_to_dut(req);
    `uvm_info("ahb_driver","Generating ahb_seq_item after send_to_dut task",UVM_LOW)
    req.print();
    seq_item_port.item_done();	
   end
 endtask

 task send_to_dut(ahb_seq_item xtn);

  @(posedge ahb_vif.CLK)
  wait (ahb_vif.AHB_DRV_CB.HREADY_OUT);
    xtn.hready <= ahb_vif.AHB_DRV_CB.HREADY_OUT;

    ahb_vif.AHB_DRV_CB.HADDR <= xtn.haddr;
    ahb_vif.AHB_DRV_CB.HTRANS <= xtn.htrans;
    ahb_vif.AHB_DRV_CB.HSIZE <= xtn.hsize; 
    ahb_vif.AHB_DRV_CB.HWRITE <= xtn.hwrite;
    ahb_vif.AHB_DRV_CB.HREADY_IN <= 1;
   
 
  if(xtn.hwrite)
   begin
    //write operation 
    ahb_vif.AHB_DRV_CB.HWDATA <= xtn.hwdata; 
   end
  else
   begin
    //read operation
    ahb_vif.AHB_DRV_CB.HWDATA <= 0;  
   end

 endtask

endclass
