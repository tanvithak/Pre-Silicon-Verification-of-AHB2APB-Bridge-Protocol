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










// BURST SEQUENCE (Fixed with Inter-Beat Delay)

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
    bit do_write;
    

    repeat(5) begin // Send 5 Bursts
       `uvm_info("ahb_burst_sequence", "Starting INCR4 Burst with BUSY padding", UVM_LOW)
       do_write = $urandom_range(0,1);

       for (i = 0; i < num_beats; i++) begin
         
         // 1. SEND DATA BEAT (NONSEQ or SEQ)
         req = ahb_seq_item::type_id::create($sformatf("req_%0d", i));
         start_item(req);
         if (!req.randomize() with {
               hwrite == do_write; 
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
             }) 
           `uvm_error("ahb_burst_sequence", "Randomization failed");
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








// WRITE-READ SEQUENCE

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
      req = ahb_seq_item::type_id::create("req");
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
      start_item(req); 
      assert(req.randomize() with { htrans==0; hresetn==1; }); 
      finish_item(req);
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
      start_item(req); 
      assert(req.randomize() with { htrans==0; hresetn==1; }); 
      finish_item(req);
      #100;
    end
  endtask
endclass














// RANDOM SEQUENCE 


class ahb_random_sequence extends ahb_base_sequence;
  `uvm_object_utils(ahb_random_sequence)

  function new(string name = "ahb_random_sequence");
    super.new(name);
  endfunction

  task body();
    ahb_seq_item req;
    ahb_seq_item prev_req;
    int i, burst_len;

    `uvm_info("ahb_random_sequence", "Starting Randomized Stress Test...", UVM_LOW)

    repeat(50) begin 
      req = ahb_seq_item::type_id::create("req");
      start_item(req);

      if (!req.randomize() with {
            hresetn == 1;
            hwrite inside {0, 1};
            hburst inside {3'b000, 3'b001, 3'b011}; // Single, Incr, Incr4
            hsize inside {3'b000, 3'b001, 3'b010};  // Byte, Half, Word
            
            // Alignment
            if (hsize == 2) haddr[1:0] == 0;
            if (hsize == 1) haddr[0] == 0;
            
            haddr inside {[32'h8000_0000 : 32'h8000_00F0]}; 
            htrans == 2'b10; // NONSEQ
      }) 
       `uvm_error("ahb_random_sequence", "Randomization failed");

      finish_item(req);
      prev_req = req;


      // CASE 1: FIXED BURST (INCR4)

      if (req.hburst == 3'b011) begin 
         for(i=0; i<3; i++) begin
            // INSERT BUSY CYCLE
            req = ahb_seq_item::type_id::create("busy");
            start_item(req);
            assert(req.randomize() with { 
                htrans == 2'b01; // BUSY
                hresetn == 1; haddr == prev_req.haddr; 
                hburst == prev_req.hburst; hwrite == prev_req.hwrite; hsize == prev_req.hsize;
            });
            finish_item(req);
            #20; // Wait for APB

            // DATA BEAT
            req = ahb_seq_item::type_id::create("burst_beat");
            start_item(req);
            assert(req.randomize() with {
                hwrite == prev_req.hwrite; htrans == 2'b11; // SEQ
                hburst == prev_req.hburst; hsize  == prev_req.hsize; hresetn == 1;
                haddr  == prev_req.haddr + (1 << prev_req.hsize); 
            });
            finish_item(req);
            prev_req = req;
         end
      end
      

      // CASE 2: UNDEFINED BURST (INCR)

      else if (req.hburst == 3'b001) begin 
         burst_len = $urandom_range(2, 5);
         for(i=0; i<burst_len; i++) begin
            // INSERT BUSY CYCLE (FIXED HERE)
            req = ahb_seq_item::type_id::create("busy");
            start_item(req);
            assert(req.randomize() with { 
                htrans == 2'b01; // BUSY
                hresetn == 1; haddr == prev_req.haddr; 
                hburst == prev_req.hburst; hwrite == prev_req.hwrite; hsize == prev_req.hsize;
            });
            finish_item(req);
            #20; // Wait for APB

            // DATA BEAT
            req = ahb_seq_item::type_id::create("incr_beat");
            start_item(req);
            assert(req.randomize() with {
                hwrite == prev_req.hwrite; htrans == 2'b11; // SEQ
                hburst == prev_req.hburst; hsize  == prev_req.hsize; hresetn == 1;
                haddr == prev_req.haddr + (1 << prev_req.hsize); 
            });
            finish_item(req);
            prev_req = req;
         end
      end

      // Cleanup
      req = ahb_seq_item::type_id::create("idle");
      start_item(req);
      assert(req.randomize() with { htrans==0; hresetn==1; });
      finish_item(req);
      #100;
    end
    `uvm_info("ahb_random_sequence", "Random Sequence Completed", UVM_LOW)
  endtask
endclass












class ahb_error_sequence extends ahb_base_sequence;
  `uvm_object_utils(ahb_error_sequence)
  function new(string name="ahb_error_sequence"); super.new(name); endfunction

  task body();
    ahb_seq_item req;
    
    `uvm_info("ahb_error_sequence", "Starting Error Injection Test...", UVM_LOW)

    // CASE 1: UNALIGNED ACCESS (Should trigger ERROR response)

    req = ahb_seq_item::type_id::create("unaligned_req");
    start_item(req);
    // Force a 32-bit write to an address ending in '1' (Illegal!)
    assert(req.randomize() with { 
        hsize == 3'b010;      // 32-bit
        haddr[1:0] == 2'b01;  // Unaligned!
        htrans == 2'b10;      // NONSEQ
        hwrite == 1; 
        hresetn == 1;
    });
    finish_item(req);
    #50; 


    // CASE 2: ILLEGAL SEQ (SEQ without NONSEQ)

    // First, ensure bus is IDLE
    req = ahb_seq_item::type_id::create("idle");
    start_item(req); 
    assert(req.randomize() with { htrans==0; hresetn==1; });
    finish_item(req);
    #20;

    // Now send a SEQ packet immediately (Illegal from IDLE)
    req = ahb_seq_item::type_id::create("bad_seq");
    start_item(req);
    assert(req.randomize() with { 
        htrans == 2'b11; // SEQ (Illegal start!)
        hresetn == 1;
        haddr[1:0] == 0;
    });
    finish_item(req);
    #50;

    // Cleanup
    req = ahb_seq_item::type_id::create("idle");
    start_item(req); assert(req.randomize() with { htrans==0; hresetn==1; }); finish_item(req);
    #100;
  endtask
endclass
