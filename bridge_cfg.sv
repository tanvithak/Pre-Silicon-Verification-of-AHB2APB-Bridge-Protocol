class bridge_cfg extends uvm_object;
 `uvm_object_utils(bridge_cfg)

 virtual ahb_intf ahb_vif;
 virtual apb_intf apb_vif;

 uvm_active_passive_enum ahb_is_active;
 uvm_active_passive_enum apb_is_active;

 static int ahb_drv_count = 0;
 static int ahb_mon_count = 0;

 static int apb_drv_count = 0;
 static int apb_mon_count = 0;

 bit has_ahb_agent = 1;
 bit has_apb_agent = 1;
 bit has_scoreboard = 1;
 bit has_virtual_sequencer = 1;

 function new(string name="bridge_cfg");
  super.new(name);
 endfunction
endclass
