class ahb_base_sequence extends uvm_sequence #(ahb_seq_item);
 `uvm_object_utils(ahb_base_sequence)

 function new(string name="ahb_base_sequence");
  super.new(name);
 endfunction

 task body;
  `uvm_info(get_type_name(), "Executing ahb_base_sequence sequence", UVM_LOW)
  repeat(5)
   `uvm_do(req)
 endtask

endclass

//write sequence:
class ahb_write_sequence extends ahb_base_sequence;
  `uvm_object_utils(ahb_write_sequence)

  function new(string name = "ahb_write_sequence");
    super.new(name);
  endfunction

  task body();
    ahb_seq_item req;

    repeat (10) begin
      // Send the ACTUAL Write Transaction
      req = ahb_seq_item::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {
            hwrite == 1;
            htrans == 2'b10; // NONSEQ
            hburst == 3'b000;
            hresetn == 1;
            hsize == 3'b010; 
            haddr[1:0] == 2'b00; 
            haddr inside {[32'h8000_0000 : 32'h8000_00FF]}; 
          })
        `uvm_error("ahb_write_seq", "Randomization failed");
      finish_item(req);
      
      `uvm_info("ahb_write_seq", $sformatf("WRITE => ADDR=%0h DATA=%0h", req.haddr, req.hwdata), UVM_LOW)

      //  Send an IDLE Transaction to clear the bus
      req = ahb_seq_item::type_id::create("req_idle");
      start_item(req);
      assert(req.randomize() with { 
          htrans == 2'b00; // IDLE
          hresetn == 1;
      });
      finish_item(req);

      #50; 
    end
  endtask
endclass


//read sequences
class ahb_read_sequence extends ahb_base_sequence;
  `uvm_object_utils(ahb_read_sequence)

  function new(string name = "ahb_read_sequence");
    super.new(name);
  endfunction

  task body();
    ahb_seq_item req;

    repeat (10) begin
      // 1. Send READ Transaction
      req = ahb_seq_item::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {
            hwrite == 0;      // READ
            htrans == 2'b10;  // NONSEQ
            hburst == 3'b000;
            hresetn == 1;
            hsize == 3'b010;  // 32-bit
            
            // FIX: Remove 'hready' constraint (it causes failures)
            // FIX: Force Address Alignment (Ends in 0,4,8,C)
            haddr[1:0] == 2'b00; 
            haddr inside {[32'h8000_0000 : 32'h8000_00FF]}; 
          })
        `uvm_error("ahb_read_seq", "Randomization failed");
      finish_item(req);

      `uvm_info("ahb_read_seq", $sformatf("READ => ADDR=%0h", req.haddr), UVM_LOW)

      // Send IDLE (Clear the bus)
      req = ahb_seq_item::type_id::create("req_idle");
      start_item(req);
      assert(req.randomize() with { 
          htrans == 2'b00; // IDLE
          hresetn == 1;
      });
      finish_item(req);

      #100; 
    end
  endtask
endclass









// ---------------------------------------------------------------
// BURST SEQUENCE (Fixed with Inter-Beat Delay)
// ---------------------------------------------------------------
class ahb_burst_sequence extends ahb_base_sequence;
  `uvm_object_utils(ahb_burst_sequence)

  function new(string name = "ahb_burst_sequence");
    super.new(name);
  endfunction

  task body();
    ahb_seq_item req;
    ahb_seq_item prev;
    int num_beats = 4;
    int i;

    repeat(5) begin // Send 5 Bursts
       `uvm_info("BURST_SEQ", "Starting INCR4 Burst with BUSY padding", UVM_LOW)

       for (i = 0; i < num_beats; i++) begin
         
         // 1. SEND DATA BEAT (NONSEQ or SEQ)
         req = ahb_seq_item::type_id::create($sformatf("req_%0d", i));
         start_item(req);
         if (!req.randomize() with {
               hwrite == 1; 
               hresetn == 1; 
               hsize == 3'b010; // 32-bit
               hburst == 3'b011; // INCR4
               
               if (i == 0) {
                   htrans == 2'b10; // NONSEQ (First Beat)
                   haddr[1:0] == 0; 
                   haddr inside {[32'h8000_0000 : 32'h8000_00F0]}; 
               } else {
                   htrans == 2'b11; // SEQ (Next Beats)
                   haddr == prev.haddr + 4; 
               }
             }) `uvm_error("SEQ", "Randomization failed");
         finish_item(req);
         prev = req;

         // 2. INSERT BUSY CYCLE (The Fix)
         // If this is not the last beat, insert a BUSY cycle to let APB catch up.
         if (i < num_beats - 1) begin
             req = ahb_seq_item::type_id::create("busy_beat");
             start_item(req);
             assert(req.randomize() with { 
                 htrans == 2'b01;     // BUSY
                 hresetn == 1; 
                 haddr == prev.haddr; // Address must remain stable during BUSY
                 hburst == 3'b011;    // Keep burst type
                 hwrite == 1;
                 hsize == 3'b010;
             });
             finish_item(req);
             
             // Wait 2 clock cycles for APB to finish the previous transfer
             #20; 
         end
       end

       // 3. END OF BURST - SEND IDLE
       req = ahb_seq_item::type_id::create("idle");
       start_item(req);
       assert(req.randomize() with { htrans==0; hresetn==1; });
       finish_item(req);
       
       #100; // Wait before starting the next burst
    end
  endtask
endclass







// ---------------------------------------------------------------
// WRITE-READ SEQUENCE (Data Integrity)
// ---------------------------------------------------------------
class ahb_write_read_sequence extends ahb_base_sequence;
  `uvm_object_utils(ahb_write_read_sequence)

  function new(string name = "ahb_write_read_sequence");
    super.new(name);
  endfunction

  task body();
    ahb_seq_item req;
    bit [31:0] target_addr;

    repeat (5) begin
      // 1. WRITE
      req = ahb_seq_item::type_id::create("req_write");
      start_item(req);
      assert(req.randomize() with {
            hwrite == 1; htrans == 2'b10; hburst == 0; hresetn == 1;
            hsize == 3'b010; haddr[1:0] == 0;
            haddr inside {[32'h8000_0000 : 32'h8000_00FF]}; 
      });
      target_addr = req.haddr; 
      finish_item(req);
      
      // Idle + Delay
      req = ahb_seq_item::type_id::create("idle");
      start_item(req); assert(req.randomize() with { htrans==0; hresetn==1; }); finish_item(req);
      #100;

      // 2. READ (Same Address)
      req = ahb_seq_item::type_id::create("req_read");
      start_item(req);
      assert(req.randomize() with {
            hwrite == 0; htrans == 2'b10; hburst == 0; hresetn == 1;
            hsize == 3'b010; 
            haddr == target_addr; // READ SAME ADDRESS
      });
      finish_item(req);

      // Idle + Delay
      req = ahb_seq_item::type_id::create("idle");
      start_item(req); assert(req.randomize() with { htrans==0; hresetn==1; }); finish_item(req);
      #100;
    end
  endtask
endclass
