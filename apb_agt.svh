class apb_agt extends uvm_agent;
 `uvm_component_utils(apb_agt)

 function new(string name="apb_agt",uvm_component parent);
  super.new(name,parent);
 endfunction

 bridge_cfg ahb_apb_cfg;
 apb_sequencer apb_seqr;
 apb_driver apb_drv;
 apb_monitor apb_mon;

 virtual function void build_phase(uvm_phase phase);
   if(!uvm_config_db #(bridge_cfg)::get(this,"","bridge_cfg",ahb_apb_cfg))
   `uvm_fatal(get_type_name(),"bridge_cfg get operation failed")

  super.build_phase(phase);

  apb_mon = apb_monitor::type_id::create("apb_mon",this);

  if(ahb_apb_cfg.apb_is_active)
   begin
    apb_seqr = apb_sequencer::type_id::create("apb_seqr",this);
    apb_drv = apb_driver::type_id::create("apb_drv",this);
   end
 endfunction

 virtual function void connect_phase(uvm_phase phase);
  if(ahb_apb_cfg.apb_is_active)
   apb_drv.seq_item_port.connect(apb_seqr.seq_item_export);
 endfunction

endclass
