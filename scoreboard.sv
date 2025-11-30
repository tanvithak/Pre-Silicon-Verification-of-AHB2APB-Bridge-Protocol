class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)

  // Declarations
  uvm_tlm_analysis_fifo #(ahb_seq_item) ahb_ap_fifo;
  uvm_tlm_analysis_fifo #(apb_seq_item) apb_ap_fifo;

  ahb_seq_item ahb_q[$];
  apb_seq_item apb_q[$];

  // Reference memory (Used only for Write-Read tests)
  bit [31:0] ref_memory[int];



ahb_seq_item cov_pkt; // Placeholder for sampling

  covergroup ahb_cg;
    option.per_instance = 1;
    option.comment = "AHB Protocol Coverage";

    // Cover HWRITE (Read vs Write)
    TRANS_TYPE: coverpoint cov_pkt.hwrite {
      bins write = {1};
      bins read  = {0};
    }

    // Cover HTRANS (Idle, NonSeq, Seq)
    TRANS_KIND: coverpoint cov_pkt.htrans {
      bins idle   = {2'b00};
      bins nonseq = {2'b10};
      bins seq    = {2'b11};
      ignore_bins busy = {2'b01}; 
    }

    // Cover HSIZE (8, 16, 32 bit)
    TRANS_SIZE: coverpoint cov_pkt.hsize {
      bins byte_8  = {3'b000};
      bins half_16 = {3'b001};
      bins word_32 = {3'b010};
    }

    // Cover HBURST (Single vs Incr4)
    BURST_TYPE: coverpoint cov_pkt.hburst {
      bins single = {3'b000};
      bins incr   = {3'b001};
      bins incr4  = {3'b011};
    }

    // Cross Coverage: Check combinations (e.g., Write + Burst)
    CROSS_RW_BURST: cross TRANS_TYPE, BURST_TYPE;
    CROSS_RW_SIZE:  cross TRANS_TYPE, TRANS_SIZE;
  endgroup



  function new(string name="scoreboard", uvm_component parent=null);
    super.new(name, parent);
    ahb_ap_fifo = new("ahb_ap_fifo", this);
    apb_ap_fifo = new("apb_ap_fifo", this);
    ahb_cg = new();
  endfunction

  // FIX 1: Strict 32-bit Address Matching
  // Previous [31:8] was too loose for consecutive aligned transactions
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

  // WRITE CHECK (Unchanged)
  task check_write(ahb_seq_item ahb_tx, apb_seq_item apb_tx);
    if (apb_tx.pwrite !== 1'b1)
      `uvm_error("Scoreboard",$sformatf("WRITE CONTROL MISMATCH at 0x%0h",ahb_tx.haddr))

    if (apb_tx.paddr !== ahb_tx.haddr)
      `uvm_error("Scoreboard",$sformatf("ADDRESS MISMATCH: AHB=0x%0h APB=0x%0h",ahb_tx.haddr, apb_tx.paddr))

    if (apb_tx.pwdata !== ahb_tx.hwdata)
      `uvm_error("Scoreboard",$sformatf("WRITE DATA MISMATCH: AHB=0x%0h APB=0x%0h", ahb_tx.hwdata, apb_tx.pwdata))
    else
      `uvm_info("Scoreboard",$sformatf("WRITE PASS: ADDR=0x%0h DATA=0x%0h", ahb_tx.haddr, ahb_tx.hwdata),UVM_LOW)

    ref_memory[int'(ahb_tx.haddr)] = ahb_tx.hwdata;
  endtask

  // FIX 2: READ CHECK updated for Bridge Transparency
  task check_read(ahb_seq_item ahb_tx, apb_seq_item apb_tx);
    
    // Check 1: Did the Address pass through correctly?
    if (apb_tx.paddr !== ahb_tx.haddr)
      `uvm_error("Scoreboard",$sformatf("READ ADDRESS MISMATCH: AHB=0x%0h APB=0x%0h",ahb_tx.haddr, apb_tx.paddr))

    // Check 2: Did the Control signal pass through?
    if (apb_tx.pwrite !== 1'b0)
      `uvm_error("Scoreboard",$sformatf("READ CONTROL MISMATCH at 0x%0h",ahb_tx.haddr))

    // Check 3: Did the Bridge pass the Slave's data back to the Master?
    // We compare AHB.HRDATA vs APB.PRDATA
    if (ahb_tx.hrdata !== apb_tx.prdata)
      `uvm_error("Scoreboard",$sformatf("READ DATA MISMATCH: AHB(Got)=0x%0h APB(Sent)=0x%0h",
                                       ahb_tx.hrdata, apb_tx.prdata))
    else
      `uvm_info("Scoreboard",$sformatf("READ PASS: ADDR=0x%0h DATA=0x%0h",ahb_tx.haddr, ahb_tx.hrdata),UVM_LOW)
  endtask

task run_phase(uvm_phase phase);
    forever begin
      ahb_seq_item a_in;
      apb_seq_item p_in;

      // Get AHB packet
      if (ahb_ap_fifo.try_get(a_in)) begin
        ahb_seq_item a_tmp = ahb_seq_item::type_id::create("a_tmp");

        // Copy fields
        a_tmp.haddr  = a_in.haddr;
        a_tmp.hwrite = a_in.hwrite;
        a_tmp.hwdata = a_in.hwdata;
        a_tmp.htrans = a_in.htrans;
        a_tmp.hrdata = a_in.hrdata;
        a_tmp.hburst = a_in.hburst; // Important for coverage
        a_tmp.hsize  = a_in.hsize;  // Important for coverage

        ahb_q.push_back(a_tmp);

        // --- SAMPLE COVERAGE HERE ---
        cov_pkt = a_tmp; 
        ahb_cg.sample(); 
      end

      // Get APB packet
      if (apb_ap_fifo.try_get(p_in)) begin
        apb_seq_item p_tmp = apb_seq_item::type_id::create("p_tmp");

        p_tmp.paddr  = p_in.paddr;
        p_tmp.pwrite = p_in.pwrite;
        p_tmp.pwdata = p_in.pwdata;
        p_tmp.prdata = p_in.prdata;

        apb_q.push_back(p_tmp);
      end

      // If both queues have data, try to match
      if (ahb_q.size() > 0 && apb_q.size() > 0)
        match_and_check();

      #1ns;
    end
  endtask
endclass
