class ahb_base_sequence extends uvm_sequence#(ahb_seq_item);
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

    repeat (5) begin
      req = ahb_seq_item::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {
            hwrite == 1;
            htrans == 2'b10;
            hburst == 3'b000;
            hready == 1;
          })
        `uvm_error("AHB_WRITE_SEQ", "Randomization failed");
      finish_item(req);

      `uvm_info("AHB_WRITE_SEQ", $sformatf("WRITE => ADDR=%0h DATA=%0h SIZE=%0d", req.haddr, req.hwdata, req.hsize), UVM_LOW)
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

    repeat (5) begin
      req = ahb_seq_item::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {
            hwrite == 0;
            htrans == 2'b10;
            hburst == 3'b000;
            hready == 1;
          })
        `uvm_error("AHB_READ_SEQ", "Randomization failed");
      finish_item(req);

      `uvm_info("AHB_READ_SEQ", $sformatf("READ => ADDR=%0h SIZE=%0d", req.haddr, req.hsize), UVM_LOW)
    end
  endtask
endclass


//Burst sequence
class ahb_burst_sequence extends ahb_base_sequence;
  `uvm_object_utils(ahb_burst_sequence)

  function new(string name = "ahb_burst_sequence");
    super.new(name);
  endfunction

  task body();
    ahb_seq_item req;
    ahb_seq_item prev;
    int num_beats;
    int i;

    num_beats = 4; // Example: INCR4 burst

    `uvm_info(get_type_name(),
      $sformatf("Starting AHB Burst Write with %0d beats", num_beats),
      UVM_LOW)

    for (i = 0; i < num_beats; i++) begin
      req = ahb_seq_item::type_id::create($sformatf("req_%0d", i));

      start_item(req);
      if (!req.randomize() with {
            hwrite == 1;
            hburst == 3'b001;  // INCR
            htrans == (i == 0) ? 2'b10 : 2'b11; // NONSEQ then SEQ
            hsize inside {[0:2]};
            haddr == (i == 0)
                     ? 32'h1000_0000
                     : (prev.haddr + (1 << prev.hsize));
          })
        `uvm_error("AHB_BURST_SEQ",
          $sformatf("Randomization failed at beat %0d", i));
      finish_item(req);

      prev = req; // store previous beat for address increment
    end

    `uvm_info(get_type_name(),"Completed AHB Burst Write Sequence",UVM_LOW)
  endtask
endclass
