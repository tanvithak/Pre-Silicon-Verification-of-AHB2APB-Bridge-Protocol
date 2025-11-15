class apb_monitor extends uvm_monitor;
 `uvm_component_utils(apb_monitor)

 virtual apb_intf apb_vif;
 
 uvm_analysis_port #(apb_seq_item) apb_ap;
 
 function new(string name="apb_monitor",uvm_component parent);
  super.new(name,parent);
 endfunction

 virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db#(virtual apb_intf)::get(this,"","apb_intf",apb_vif))
   `uvm_fatal(get_full_name(), "Getting virtual interface from the configuration failed")
 endfunction

    
 task collect_data();
   apb_seq_item xtn;
   xtn = apb_seq_item::type_id::create("xtn");

   wait(apb_vif.APB_MON_CB.PENABLE)
   xtn.paddr = apb_vif.APB_MON_CB.PADDR;
   xtn.pwrite = apb_vif.APB_MON_CB.PWRITE;
   xtn.psel = apb_vif.APB_MON_CB.PSEL;

   if(xtn.pwrite == 1)
	 xtn.pwdata = apb_vif.APB_MON_CB.PWDATA; 
   else
     xtn.prdata = apb_vif.APB_MON_CB.PRDATA;

   @(apb_vif.APB_MON_CB); 
	
   xtn.print();

   apb_ap.write(xtn);

   `uvm_info("apb_monitor", "Displaying apb_monitor data", UVM_LOW)
        
 endtask
   
   
 task run_phase(uvm_phase phase);
   forever
     begin
       collect_data();
     end
 endtask
   
endclass
