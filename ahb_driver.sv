class ahb_driver extends uvm_driver#(ahb_seq_item);
 `uvm_component_utils(ahb_driver)
 virtual ahb_intf ahb_vif;

 ahb_seq_item req_address;
 ahb_seq_item req_data_done;

/*
 ahb_driver's jobs:

1. function new
2. build_phase: get the virtual interface from the configuration database
3. task run_phase: Sequence to driver mechanism
4. task run_phase calls a send_to_dut function in a forever loop
5. send_to_dut: Drives address and control signals to the dut via virtual interface
6. send_to_dut: Need to consider write and read operations depending/waiting for HREADY
7. send_to_dut: Checking protocol's function of pipeline handling
8. ahb_drv_rst: a function for resetting the signals
*/
 
 function new(string name="ahb_driver",uvm_component parent);
  super.new(name);
 endfunction

 virtual function build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db::get(this,"","ahb_vif",ahb_vif))
   `uvm_fatal(get_full_name(), "Getting virtual interface from the configuration failed")
 endfunction

 virtual task run_phase(uvm_phase phase);
  ahb_drv_rst;
  
  seq_item_port.get_next_item(req_address);
  forever
   begin
    send_to_dut(req_address);

    req_data_done = req_address;
    seq_item_port.get_next_item(req_address);

    @(posedge ahb_vif.HCLK)
    wait (ahb_vif.HREADY == 1);

    seq_item_port.item_done();	
   end
 endtask

 task send_to_dut(ahb_seq_item xtn);

  @(posedge ahb_vif.HCLK) wait (ahb_vif.HREADY == 1);

    ahb_vif.AHB_DRV_MP.ahb_drv_cb.HADDR <= xtn.haddr;
    ahb_vif.AHB_DRV_MP.ahb_drv_cb.HTRANS <= xtn.htrans;
    ahb_vif.AHB_DRV_MP.ahb_drv_cb.HSIZE <= xtn.hsize; 
    ahb_vif.AHB_DRV_MP.ahb_drv_cb.HWRITE <= xtn.hwrite;
 
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

 endfunction


 task ahb_drv_rst;
  @(posedge ahb_vif.HCLK) wait(ahb_vif.HRESETn == 1);

  @(posedge ahb_vif.AHB_DRV_MP.ahb_drv_cb) 
   begin
    ahb_vif.AHB_DRV_MP.ahb_drv_cb.HADDR <= 'x;
    ahb_vif.AHB_DRV_MP.ahb_drv_cb.HWDATA <= 'x;
    ahb_vif.AHB_DRV_MP.ahb_drv_cb.HWRITE <= 'x;
    ahb_vif.AHB_DRV_MP.ahb_drv_cb.HTRANS <= 'x;
    ahb_vif.AHB_DRV_MP.ahb_drv_cb.HSIZE <= 'x;
   end
 endtask

endclass
