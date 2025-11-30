class ahb_agt extends uvm_agent;
 `uvm_component_utils(ahb_agt)

 function new(string name="ahb_agt",uvm_component parent=null);
  super.new(name,parent);
 endfunction

 bridge_cfg ahb_apb_cfg;
 ahb_sequencer ahb_seqr;
 ahb_driver ahb_drv;
 ahb_monitor ahb_mon;

 virtual function void build_phase(uvm_phase phase);
   if(!uvm_config_db #(bridge_cfg)::get(this,"","bridge_cfg",ahb_apb_cfg))
     `uvm_fatal(get_type_name(),"bridge_cfg get operation failed")

  super.build_phase(phase);

  ahb_mon = ahb_monitor::type_id::create("ahb_mon",this);
  
  if(ahb_apb_cfg.ahb_is_active == UVM_ACTIVE)
   begin
    ahb_seqr = ahb_sequencer::type_id::create("ahb_seqr",this);
    ahb_drv = ahb_driver::type_id::create("ahb_drv",this);
   end
 endfunction

 virtual function void connect_phase(uvm_phase phase);
  if(ahb_apb_cfg.ahb_is_active == UVM_ACTIVE)
   begin  
    ahb_drv.seq_item_port.connect(ahb_seqr.seq_item_export);
   end
 endfunction

endclass
