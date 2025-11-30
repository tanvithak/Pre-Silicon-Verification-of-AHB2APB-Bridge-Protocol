class ahb_monitor extends uvm_monitor;
 `uvm_component_utils(ahb_monitor)

 virtual ahb_intf ahb_vif;
 bridge_cfg ahb_apb_cfg;
 ahb_seq_item xtn;

 uvm_analysis_port #(ahb_seq_item) ahb_ap;

 function new(string name="ahb_monitor",uvm_component parent);
  super.new(name,parent);
  ahb_ap = new("ahb_ap",this);
 endfunction

 virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db#(bridge_cfg)::get(this,"","bridge_cfg",ahb_apb_cfg))
   `uvm_fatal(get_full_name(), "Getting the configuration failed")
 endfunction

 function void connect_phase(uvm_phase phase);
  ahb_vif = ahb_apb_cfg.ahb_vif;
 endfunction



task collect_data();
   @(posedge ahb_vif.CLK);
   
   // 1. Capture Command Phase (Address, Control)
   if (ahb_vif.AHB_MON_CB.HREADY_OUT === 1 && 
       ahb_vif.AHB_MON_CB.HRESETn === 1 && 
       (ahb_vif.AHB_MON_CB.HTRANS == 2'b10 || ahb_vif.AHB_MON_CB.HTRANS == 2'b11)) 
   begin
      xtn = ahb_seq_item::type_id::create("xtn");
      
      xtn.haddr   = ahb_vif.AHB_MON_CB.HADDR;
      xtn.hwrite  = ahb_vif.AHB_MON_CB.HWRITE;
      xtn.htrans  = ahb_vif.AHB_MON_CB.HTRANS;
      xtn.hsize   = ahb_vif.AHB_MON_CB.HSIZE;
      xtn.hburst  = ahb_vif.AHB_MON_CB.HBURST;
      xtn.hresetn = ahb_vif.AHB_MON_CB.HRESETn;

      // 2. PIPELINE: Wait for Data Phase (Next Cycle)
      @(posedge ahb_vif.CLK);
      
      // 3. Handle Wait States (If Slave is not ready, wait)
      while (ahb_vif.AHB_MON_CB.HREADY_OUT === 0) 
         @(posedge ahb_vif.CLK);

      // 4. Now Capture Data
      xtn.hwdata = ahb_vif.AHB_MON_CB.HWDATA; 
      xtn.hrdata = ahb_vif.AHB_MON_CB.HRDATA;

      `uvm_info("ahb_monitor", $sformatf("Sampled Packet: ADDR=%0h DATA=%0h", xtn.haddr, xtn.hwdata), UVM_LOW)
      
      xtn.print();
      ahb_ap.write(xtn);
   end
endtask
   
   
 task run_phase(uvm_phase phase);
  @(posedge ahb_vif.CLK);
  forever
    begin
      collect_data();
    end
 endtask
   
endclass
