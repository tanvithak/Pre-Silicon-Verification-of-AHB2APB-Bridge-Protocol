class scoreboard extends uvm_scoreboard;
 `uvm_component_utils(scoreboard)

  uvm_tlm_analysis_fifo #(ahb_seq_item) ahb_ap_fifo;
  uvm_tlm_analysis_fifo #(apb_seq_item) apb_ap_fifo;
 
 ahb_seq_item ahb_tx;
 apb_seq_item apb_tx;
  
 bit [31:0] ref_memory [bit [31:0]];

 function new(string name="scoreboard", uvm_component parent);
  super.new(name,parent);
   ahb_ap_fifo = new("ahb_ap_fifo",this);
   apb_ap_fifo = new("apb_ap_fifo",this);
 endfunction
 
 function void build_phase(uvm_phase phase);
  super.build_phase(phase);
   /*ahb_tx = ahb_seq_item::type_id::create("ahb_tx");
   apb_tx = apb_seq_item::type_id::create("apb_tx");*/
 endfunction
 
  
  
 virtual task run_phase(uvm_phase phase);
  forever 
    begin
      ahb_ap_fifo.get(ahb_tx);
      if (ahb_tx.hwrite == 1) 
        check_write(ahb_tx);
      else 
        check_read(ahb_tx);
    end
 endtask
  
  
  
 virtual task check_write(ahb_seq_item ahb_tx_in);
  apb_ap_fifo.get(apb_tx); 
  if(apb_tx.pwrite != 1) 
    begin
      `uvm_error(get_type_name(), $sformatf("WRITE CONTROL MISMATCH: AHB Write resulted in APB Read/Idle for Addr=%0h", ahb_tx_in.haddr));
      return;
    end
        
  if(apb_tx.paddr != ahb_tx_in.haddr) 
    begin
     `uvm_error(get_type_name(), $sformatf("ADDRESS MISMATCH: AHB Addr=0x%0h vs APB PADDR=0x%0h", ahb_tx_in.haddr, apb_tx.paddr));
      return;
    end

  if(apb_tx.pwdata != ahb_tx_in.hwdata)
    `uvm_error(get_type_name(), $sformatf("WRITE DATA MISMATCH: AHB Data=0x%0h, but APB Data=0x%0h.",ahb_tx_in.hwdata, apb_tx.pwdata))
  else 
   `uvm_info(get_type_name(), $sformatf("AHB WRITE PASSED for Addr=0x%0h, Data=0x%0h", ahb_tx_in.haddr, ahb_tx_in.hwdata), UVM_LOW)
        
  ref_memory[apb_tx.paddr] = apb_tx.pwdata;
 endtask
  
  
  
  
  
 virtual task check_read(ahb_seq_item ahb_tx_in);
   bit [31:0] expected_data;

   if(ref_memory.exists(ahb_tx_in.haddr)) 
      expected_data = ref_memory[ahb_tx_in.haddr];
   else 
      expected_data = 32'h0; 

   apb_ap_fifo.get(apb_tx);

   if (apb_tx.pwrite != 0) 
     begin
       `uvm_error(get_type_name(), $sformatf("READ CONTROL MISMATCH: AHB Read resulted in APB Write for Addr=%0h", ahb_tx_in.haddr));
       return;
     end
        
   if (apb_tx.prdata != expected_data)
    `uvm_error(get_type_name(), $sformatf("READ DATA MISMATCH: Expected 0x%0h, but APB returned 0x%0h", expected_data, apb_tx.prdata))
   
   else 
     `uvm_info(get_type_name(), $sformatf("AHB READ PASSED for Addr=0x%0h, Data=0x%0h",ahb_tx_in.haddr, expected_data), UVM_LOW)
   
  
 endtask

endclass
