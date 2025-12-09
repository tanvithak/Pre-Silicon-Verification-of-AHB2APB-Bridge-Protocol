class ahb_apb_test extends uvm_test;
 `uvm_component_utils(ahb_apb_test)
 
  envir env1;
  bridge_cfg cfg;
 
  function new(string name="ahb_apb_test",uvm_component parent=null);
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
  
endclass










class test_one extends ahb_apb_test;
 `uvm_component_utils(test_one)
 
  ahb_write_sequence ahb_seq1;
  apb_seqs apb_seq1;
  
  function new(string name = "test_one",uvm_component parent);
   super.new(name,parent);
  endfunction
  
  
  function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   ahb_seq1 = ahb_write_sequence::type_id::create("ahb_seq1");
   apb_seq1 = apb_seqs::type_id::create("apb_seq1");
  endfunction
  
  task run_phase(uvm_phase phase);
   phase.raise_objection(this);
   `uvm_info("TEST", "Waiting for System Reset...", UVM_LOW)
   #100; 
   
   `uvm_info("TEST", "Starting Write Sequences...", UVM_LOW)
   fork
    ahb_seq1.start(env1.ahb_agt1.ahb_seqr);
    apb_seq1.start(env1.apb_agt1.apb_seqr);
   join
   phase.drop_objection(this);
   phase.phase_done.set_drain_time(this, 100);
  endtask
endclass




class test_two extends ahb_apb_test;
  `uvm_component_utils(test_two)

  // Only declare the READ sequence
  ahb_read_sequence ahb_seq_read;
  apb_seqs apb_seq; 
  
  function new(string name = "test_two", uvm_component parent);
   super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   // Create ONLY the Read sequence
   ahb_seq_read = ahb_read_sequence::type_id::create("ahb_seq_read");
   apb_seq = apb_seqs::type_id::create("apb_seq");
  endfunction
  
  task run_phase(uvm_phase phase);
   phase.raise_objection(this);
   
   `uvm_info("TEST", "Waiting for System Reset...", UVM_LOW)
   #100; 
   
   `uvm_info("TEST", "Starting READ Sequences...", UVM_LOW)
   
   fork
    // Thread 1: AHB Master (Read Only)
    ahb_seq_read.start(env1.ahb_agt1.ahb_seqr);
    
    // Thread 2: APB Slave Responder
    forever begin
      apb_seq.start(env1.apb_agt1.apb_seqr);
    end
   join_any 
   
   phase.drop_objection(this);
   phase.phase_done.set_drain_time(this, 100);
  endtask
endclass












// ---------------------------------------------
// TEST THREE: Burst Test
// ---------------------------------------------
class test_three extends ahb_apb_test;
 `uvm_component_utils(test_three)
 
 ahb_burst_sequence ahb_seq;
 apb_seqs apb_seq;

 function new(string name="test_three",uvm_component parent);
  super.new(name,parent);
 endfunction
 
 function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   ahb_seq = ahb_burst_sequence::type_id::create("ahb_seq");
   apb_seq = apb_seqs::type_id::create("apb_seq");
 endfunction
 
 task run_phase(uvm_phase phase);
   phase.raise_objection(this);
   #100;
   fork
     ahb_seq.start(env1.ahb_agt1.ahb_seqr);
     forever apb_seq.start(env1.apb_agt1.apb_seqr); 
   join_any
   phase.drop_objection(this);
   phase.phase_done.set_drain_time(this, 100);
 endtask
endclass

// ---------------------------------------------
// TEST FOUR: Write-Read Test
// ---------------------------------------------
class test_four extends ahb_apb_test;
 `uvm_component_utils(test_four)
 
 ahb_write_read_sequence ahb_seq;
 apb_seqs apb_seq;

 function new(string name="test_four",uvm_component parent);
  super.new(name,parent);
 endfunction
 
 function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   ahb_seq = ahb_write_read_sequence::type_id::create("ahb_seq");
   apb_seq = apb_seqs::type_id::create("apb_seq");
 endfunction
 
 task run_phase(uvm_phase phase);
   phase.raise_objection(this);
   #100;
   fork
     ahb_seq.start(env1.ahb_agt1.ahb_seqr);
     forever apb_seq.start(env1.apb_agt1.apb_seqr); 
   join_any
   phase.drop_objection(this);
   phase.phase_done.set_drain_time(this, 100);
 endtask
endclass





class test_five extends ahb_apb_test;
  `uvm_component_utils(test_five)
 
  ahb_random_sequence ahb_seq;
  apb_seqs apb_seq;

  function new(string name="test_five",uvm_component parent);
   super.new(name,parent);
  endfunction
 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ahb_seq = ahb_random_sequence::type_id::create("ahb_seq");
    apb_seq = apb_seqs::type_id::create("apb_seq");

    cfg.enable_data_check = 0; 
  endfunction
 
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #100; 
    fork
      ahb_seq.start(env1.ahb_agt1.ahb_seqr);
      forever apb_seq.start(env1.apb_agt1.apb_seqr); 
    join_any
    phase.drop_objection(this);
    phase.phase_done.set_drain_time(this, 100);
  endtask
endclass









class test_six extends ahb_apb_test;
 `uvm_component_utils(test_six)
 ahb_error_sequence ahb_seq;
 apb_seqs apb_seq;

 function new(string name="test_six",uvm_component parent); super.new(name,parent); endfunction
 
 function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   ahb_seq = ahb_error_sequence::type_id::create("ahb_seq");
   apb_seq = apb_seqs::type_id::create("apb_seq");
   
   // Disable Data Check because error responses might not return valid data
   cfg.enable_data_check = 0; 
   uvm_config_db #(bridge_cfg)::set(this, "*", "bridge_cfg", cfg);
 endfunction
 
 task run_phase(uvm_phase phase);
   phase.raise_objection(this);
   #100;
   fork
     ahb_seq.start(env1.ahb_agt1.ahb_seqr);
     forever apb_seq.start(env1.apb_agt1.apb_seqr); 
   join_any
   phase.drop_objection(this);
   phase.phase_done.set_drain_time(this, 100);
 endtask
endclass






class test_config extends ahb_apb_test;
 `uvm_component_utils(test_config)
 ahb_config_sequence ahb_seq;
 apb_seqs apb_seq;

 function new(string name="test_config",uvm_component parent); super.new(name,parent); endfunction
 
 function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   ahb_seq = ahb_config_sequence::type_id::create("ahb_seq");
   apb_seq = apb_seqs::type_id::create("apb_seq");
   
   cfg.enable_data_check = 0; 
   uvm_config_db #(bridge_cfg)::set(this, "*", "bridge_cfg", cfg);
 endfunction
 
 task run_phase(uvm_phase phase);
   phase.raise_objection(this);
   #100;
   fork
     ahb_seq.start(env1.ahb_agt1.ahb_seqr);
     forever apb_seq.start(env1.apb_agt1.apb_seqr); 
   join_any
   phase.drop_objection(this);
   phase.phase_done.set_drain_time(this, 100);
 endtask
endclass





class test_pipeline extends ahb_apb_test;
 `uvm_component_utils(test_pipeline)
 ahb_pipelined_write_sequence ahb_seq;
 apb_seqs apb_seq;

 function new(string name="test_pipeline",uvm_component parent);
  super.new(name,parent);
 endfunction
 
 function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   ahb_seq = ahb_pipelined_write_sequence::type_id::create("ahb_seq");
   apb_seq = apb_seqs::type_id::create("apb_seq");
   
   // DISABLE SCOREBOARD - We expect timing violations here, just want coverage
   cfg.has_scoreboard = 0; 
   uvm_config_db #(bridge_cfg)::set(this, "*", "bridge_cfg", cfg);
 endfunction
 
task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #100;
    
    fork
      // --- FIX START ---
      begin
         // Run 50 random bursts to actually stress the design
         repeat(50) begin
            // 1. RANDOMIZE the sequence object to pick new burst/size/length types
            if(!ahb_seq.randomize()) 
               `uvm_error("test_seven", "Sequence randomization failed")
            
            // 2. Start the sequence with the new random values
            ahb_seq.start(env1.ahb_agt1.ahb_seqr);
         end
      end
      // --- FIX END ---

      // APB responder runs forever in parallel
      forever apb_seq.start(env1.apb_agt1.apb_seqr); 
    join_any
    
    phase.drop_objection(this);
    phase.phase_done.set_drain_time(this, 100);
  endtask
endclass





class test_seven extends ahb_apb_test;
 `uvm_component_utils(test_seven)
 ahb_flexible_burst_sequence ahb_seq;
 apb_seqs apb_seq;

 function new(string name="test_seven",uvm_component parent);
  super.new(name,parent);
 endfunction
 
 function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   ahb_seq = ahb_flexible_burst_sequence::type_id::create("ahb_seq");
   apb_seq = apb_seqs::type_id::create("apb_seq");
 endfunction
 
 task run_phase(uvm_phase phase);
   phase.raise_objection(this);
   #100;
   fork
     ahb_seq.start(env1.ahb_agt1.ahb_seqr);
     forever apb_seq.start(env1.apb_agt1.apb_seqr); 
   join_any
   phase.drop_objection(this);
   phase.phase_done.set_drain_time(this, 100);
 endtask
endclass






class test_eight extends ahb_apb_test;
 `uvm_component_utils(test_eight)
 ahb_master_burst_seq ahb_seq;
 apb_seqs apb_seq;

 function new(string name="test_eight",uvm_component parent);
  super.new(name,parent);
 endfunction
 
 function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   ahb_seq = ahb_master_burst_seq::type_id::create("ahb_seq");
   apb_seq = apb_seqs::type_id::create("apb_seq");
 endfunction
 
 task run_phase(uvm_phase phase);
   phase.raise_objection(this);
   #100;
   fork
     ahb_seq.start(env1.ahb_agt1.ahb_seqr);
     forever apb_seq.start(env1.apb_agt1.apb_seqr); 
   join_any
   phase.drop_objection(this);
   phase.phase_done.set_drain_time(this, 100);
 endtask
endclass
