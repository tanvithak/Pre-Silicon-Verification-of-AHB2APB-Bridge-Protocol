class ahb_apb_test extends uvm_test;
 `uvm_component_utils(ahb_apb_test)
 
  envir env1;
  bridge_cfg cfg;
 
  function new(string name="ahb_apb_test",uvm_component parent);
   super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   cfg = bridge_cfg::type_id::create("cfg");
   
   uvm_config_db #(bridge_cfg)::set(this,"*","bridge_cfg",cfg);
   
   if(!uvm_config_db #(virtual ahb_intf)::get(this,"","ahb_intf",cfg.ahb_vif))
     `uvm_fatal(get_type_name(),"Getting ahb interface failed")
    
   if(!uvm_config_db #(virtual apb_intf)::get(this,"","apb_intf",cfg.apb_vif))
     `uvm_fatal(get_type_name(), "Getting apb virtual interface failed")
    
    cfg.has_ahb_agent = 1;
    cfg.has_apb_agent = 1;
    cfg.has_scoreboard = 1;
    cfg.ahb_is_active = UVM_ACTIVE;
    cfg.apb_is_active = UVM_ACTIVE;
    
    env1 = envir::type_id::create("env1",this);
  endfunction
  
  
  task run_phase(uvm_phase phase);
   ahb_apb_vseq vseq;
   phase.raise_objection(this);
   
   vseq = ahb_apb_vseq::type_id::create("vseq");
   
   vseq.start(env1.vsqr);
   
   #500ns;
   
   phase.drop_objection(this);
  endtask
endclass



class test_one extends ahb_apb_test;
 `uvm_component_utils(test_one)
 
  ahb_base_sequence ahb_seq1;
  apb_seqs apb_seq1;
  
  function new(string name = "test_one",uvm_component parent);
   super.new(name,parent);
  endfunction
  
  
  function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   ahb_seq1 = ahb_base_sequence::type_id::create("ahb_seq1");
   apb_seq1 = apb_seqs::type_id::create("apb_seq1");
  endfunction
  
  task run_phase(uvm_phase phase);
   phase.raise_objection(this);
   fork
    ahb_seq1.start(env1.ahb_agt1.ahb_seqr);
    apb_seq1.start(env1.apb_agt1.apb_seqr);
   join
   phase.drop_objection(this);
  endtask
endclass

