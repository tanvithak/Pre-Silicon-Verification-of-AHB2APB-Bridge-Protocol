class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)


  uvm_tlm_analysis_fifo #(ahb_seq_item) ahb_ap_fifo;
  uvm_tlm_analysis_fifo #(apb_seq_item) apb_ap_fifo;

  ahb_seq_item ahb_q[$];
  apb_seq_item apb_q[$];

  // Reference memory
  bit [31:0] ref_memory[int];
  
  // Config Handle
  bridge_cfg cfg; 


  ahb_seq_item cov_pkt; 

covergroup ahb_cg;
    option.per_instance = 1;

    TRANS_TYPE: coverpoint cov_pkt.hwrite {
      bins write = {1};
      bins read  = {0};
    }

    TRANS_KIND: coverpoint cov_pkt.htrans {
      bins idle   = {2'b00};
      bins nonseq = {2'b10};
      bins seq    = {2'b11};
      ignore_bins busy = {2'b01}; 
    }

    // UPDATE: Enable Byte and Half-Word
    TRANS_SIZE: coverpoint cov_pkt.hsize {
      bins byte_8  = {3'b000};
      bins half_16 = {3'b001};
      bins word_32 = {3'b010};
      ignore_bins others = {[3'b011:3'b111]};
    }


    BURST_TYPE: coverpoint cov_pkt.hburst {
      bins single = {3'b000};
      bins incr   = {3'b001}; 
      bins incr4  = {3'b011};
      ignore_bins others = {3'b010, [3'b100:3'b111]}; 
    }

    CROSS_RW_BURST: cross TRANS_TYPE, BURST_TYPE;
    CROSS_RW_SIZE:  cross TRANS_TYPE, TRANS_SIZE;
  endgroup




  function new(string name="scoreboard", uvm_component parent=null);
    super.new(name, parent);
    ahb_ap_fifo = new("ahb_ap_fifo", this);
    apb_ap_fifo = new("apb_ap_fifo", this);
    ahb_cg = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Get the config object to see if data checking is enabled
    if(!uvm_config_db #(bridge_cfg)::get(this, "", "bridge_cfg", cfg))
       `uvm_fatal("SCOREBOARD", "Failed to get bridge_cfg")
  endfunction


  function bit addr_match(bit[31:0] ahb_addr, bit[31:0] apb_addr);
    return (ahb_addr === apb_addr);  
  endfunction


  task match_and_check();
    apb_seq_item apb_pkt;
    ahb_seq_item ahb_pkt;
    int idx = -1;

    apb_pkt = apb_q.pop_front();

    foreach (ahb_q[i]) begin
      if (addr_match(ahb_q[i].haddr, apb_pkt.paddr)) begin
        idx = i;
        break;
      end
    end

    if (idx == -1) begin
      apb_q.push_back(apb_pkt);
      return;
    end

    ahb_pkt = ahb_q[idx];
    ahb_q.delete(idx);

    if (ahb_pkt.hwrite)
      check_write(ahb_pkt, apb_pkt);
    else
      check_read(ahb_pkt, apb_pkt);
  endtask

  // WRITE CHECK
  task check_write(ahb_seq_item ahb_tx, apb_seq_item apb_tx);
    if (apb_tx.pwrite !== 1'b1)
      `uvm_error("Scoreboard",$sformatf("WRITE CONTROL MISMATCH at 0x%0h",ahb_tx.haddr))

    if (apb_tx.paddr !== ahb_tx.haddr)
      `uvm_error("Scoreboard",$sformatf("ADDRESS MISMATCH: AHB=0x%0h APB=0x%0h",ahb_tx.haddr, apb_tx.paddr))

    // --- DATA CHECK (CONDITIONAL) ---
    if (cfg.enable_data_check) begin
        if (apb_tx.pwdata !== ahb_tx.hwdata)
          `uvm_error("Scoreboard",$sformatf("WRITE DATA MISMATCH: AHB=0x%0h APB=0x%0h", ahb_tx.hwdata, apb_tx.pwdata))
        else
          `uvm_info("Scoreboard",$sformatf("WRITE PASS: ADDR=0x%0h DATA=0x%0h", ahb_tx.haddr, ahb_tx.hwdata),UVM_LOW)
    end else begin
        `uvm_info("Scoreboard", "WRITE PASS (Data Check Disabled)", UVM_LOW)
    end

    ref_memory[int'(ahb_tx.haddr)] = ahb_tx.hwdata;
  endtask

  // READ CHECK
  task check_read(ahb_seq_item ahb_tx, apb_seq_item apb_tx);
    if (apb_tx.paddr !== ahb_tx.haddr)
      `uvm_error("Scoreboard",$sformatf("READ ADDRESS MISMATCH: AHB=0x%0h APB=0x%0h",ahb_tx.haddr, apb_tx.paddr))

    if (apb_tx.pwrite !== 1'b0)
      `uvm_error("Scoreboard",$sformatf("READ CONTROL MISMATCH at 0x%0h",ahb_tx.haddr))

    // --- DATA CHECK (CONDITIONAL) ---
    if (cfg.enable_data_check) begin
        if (ahb_tx.hrdata !== apb_tx.prdata)
          `uvm_error("Scoreboard",$sformatf("READ DATA MISMATCH: AHB=0x%0h APB=0x%0h", ahb_tx.hrdata, apb_tx.prdata))
        else
          `uvm_info("Scoreboard",$sformatf("READ PASS: ADDR=0x%0h DATA=0x%0h", ahb_tx.haddr, ahb_tx.hrdata),UVM_LOW)
    end else begin
        `uvm_info("Scoreboard", "READ PASS (Data Check Disabled)", UVM_LOW)
    end
  endtask


  task run_phase(uvm_phase phase);
    forever begin
      ahb_seq_item a_in;
      apb_seq_item p_in;

      if (ahb_ap_fifo.try_get(a_in)) begin
        ahb_seq_item a_tmp = ahb_seq_item::type_id::create("a_tmp");
        a_tmp.haddr  = a_in.haddr;
        a_tmp.hwrite = a_in.hwrite;
        a_tmp.hwdata = a_in.hwdata;
        a_tmp.htrans = a_in.htrans;
        a_tmp.hrdata = a_in.hrdata;
        a_tmp.hburst = a_in.hburst;
        a_tmp.hsize  = a_in.hsize;

        ahb_q.push_back(a_tmp);

        cov_pkt = a_tmp; 
        ahb_cg.sample(); 
      end

      if (apb_ap_fifo.try_get(p_in)) begin
        apb_seq_item p_tmp = apb_seq_item::type_id::create("p_tmp");
        p_tmp.paddr  = p_in.paddr;
        p_tmp.pwrite = p_in.pwrite;
        p_tmp.pwdata = p_in.pwdata;
        p_tmp.prdata = p_in.prdata;
        
        apb_q.push_back(p_tmp);
      end

      if (ahb_q.size() > 0 && apb_q.size() > 0)
        match_and_check();

      #1ns;
    end
  endtask

endclass
