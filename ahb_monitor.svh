class ahb_monitor extends uvm_monitor;
 `uvm_component_utils(ahb_monitor)

 virtual ahb_intf ahb_vif;
 
 uvm_analysis_port #(ahb_seq_item) ahb_ap;

 function new(string name="ahb_monitor",uvm_component parent);
  super.new(name,parent);
 endfunction

 virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db#(virtual ahb_intf)::get(this,"","ahb_intf",ahb_vif))
   `uvm_fatal(get_full_name(), "Getting virtual interface from the configuration failed")
 endfunction

    
 task collect_data();
   ahb_seq_item xtn;
   xtn = ahb_seq_item::type_id::create("xtn");

   wait(ahb_vif.AHB_MON_CB.HREADY_OUT && (ahb_vif.AHB_MON_CB.HTRANS == 2'b10 || ahb_vif.AHB_MON_CB.HTRANS == 2'b11))
   xtn.htrans = ahb_vif.AHB_MON_CB.HTRANS;
   xtn.hwrite = ahb_vif.AHB_MON_CB.HWRITE;
   xtn.hsize  = ahb_vif.AHB_MON_CB.HSIZE;
   xtn.haddr  = ahb_vif.AHB_MON_CB.HADDR;
   xtn.hburst = ahb_vif.AHB_MON_CB.HBURST;

   @(ahb_vif.AHB_MON_CB);

   wait(ahb_vif.AHB_MON_CB.HREADY_OUT && (ahb_vif.AHB_MON_CB.HTRANS == 2'b10 || ahb_vif.AHB_MON_CB.HTRANS == 2'b11))
   if(ahb_vif.AHB_MON_CB.HWRITE == 1'b1)        
      xtn.hwdata = ahb_vif.AHB_MON_CB.HWDATA;
   else
	  xtn.hrdata = ahb_vif.AHB_MON_CB.HRDATA;

   xtn.print();//no delay, in the same cycle control and addr shud be collected
   ahb_ap.write(xtn);
 endtask
   
   
 task run_phase(uvm_phase phase);
  forever
    begin
      collect_data();
    end
 endtask
   
endclass
