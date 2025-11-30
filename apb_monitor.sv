class apb_monitor extends uvm_monitor;
  `uvm_component_utils(apb_monitor)
  virtual apb_intf apb_vif;
  bridge_cfg ahb_apb_cfg;
  apb_seq_item xtn;
  uvm_analysis_port #(apb_seq_item) apb_ap;
 
  function new(string name="apb_monitor", uvm_component parent);
    super.new(name,parent);
    apb_ap = new("apb_ap",this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db # (bridge_cfg)::get(this,"","bridge_cfg",ahb_apb_cfg))
      `uvm_fatal(get_full_name(), "Getting the configuration failed")
  endfunction

  function void connect_phase(uvm_phase phase);
    apb_vif = ahb_apb_cfg.apb_vif;
  endfunction
    
  task run_phase(uvm_phase phase);
    forever begin
       collect_data();
    end
  endtask

  task collect_data();
    // 1. WAIT FOR PENABLE HIGH (Active Phase of APB)
    // We rely on PENABLE because it is the only signal guaranteed to be 1 during valid data
    do begin
       @(posedge apb_vif.CLK);
    end while (apb_vif.APB_MON_CB.PENABLE !== 1 || apb_vif.APB_MON_CB.PRESETn === 0);

    // 2. CAPTURE
    xtn = apb_seq_item::type_id::create("xtn");
    xtn.paddr   = apb_vif.APB_MON_CB.PADDR;
    xtn.pwrite  = apb_vif.APB_MON_CB.PWRITE;
    xtn.psel    = apb_vif.APB_MON_CB.PSEL;
    xtn.pwdata  = apb_vif.APB_MON_CB.PWDATA; 
    xtn.prdata  = apb_vif.APB_MON_CB.PRDATA;
    xtn.pready  = apb_vif.APB_MON_CB.PREADY;
    xtn.penable = apb_vif.APB_MON_CB.PENABLE;

    // 3. PRINT
    if (xtn.pwrite)
       `uvm_info("APB_MON", $sformatf("WRITE Captured: ADDR=%0h DATA=%0h", xtn.paddr, xtn.pwdata), UVM_LOW)
    else
       `uvm_info("APB_MON", $sformatf("READ Captured:  ADDR=%0h DATA=%0h", xtn.paddr, xtn.prdata), UVM_LOW)

    apb_ap.write(xtn);

    // 4. WAIT FOR PENABLE LOW (Transaction Complete)
    do begin
       @(posedge apb_vif.CLK);
    end while (apb_vif.APB_MON_CB.PENABLE === 1);
  endtask
endclass
