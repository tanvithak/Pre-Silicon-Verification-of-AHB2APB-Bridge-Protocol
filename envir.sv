class envir extends uvm_env;
 `uvm_component_utils(envir)
 
 bridge_cfg ahb_apb_cfg;

 ahb_agt ahb_agt1;
 apb_agt apb_agt1;
 scoreboard sb;

 function new(string name="envir",uvm_component parent=null);
  super.new(name,parent);
 endfunction

 function void build_phase(uvm_phase phase);
   if(!uvm_config_db #(bridge_cfg)::get(this,"","bridge_cfg",ahb_apb_cfg))
   `uvm_fatal(get_type_name(),"Config_db get operation failed")

  super.build_phase(phase);
  
  if(ahb_apb_cfg.has_ahb_agent)
   ahb_agt1 = ahb_agt::type_id::create("ahb_agt1",this);
 
  if(ahb_apb_cfg.has_apb_agent)
   apb_agt1 = apb_agt::type_id::create("apb_agt1",this);

  if(ahb_apb_cfg.has_scoreboard)
   sb = scoreboard::type_id::create("sb",this);
   
 endfunction


 function void connect_phase(uvm_phase phase);
  uvm_top.print_topology();

  if(ahb_apb_cfg.has_ahb_agent && ahb_apb_cfg.has_scoreboard)
    ahb_agt1.ahb_mon.ahb_ap.connect(sb.ahb_ap_fifo.analysis_export);

  if(ahb_apb_cfg.has_apb_agent && ahb_apb_cfg.has_scoreboard)
    apb_agt1.apb_mon.apb_ap.connect(sb.apb_ap_fifo.analysis_export);

 endfunction

endclass
