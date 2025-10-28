`include "uvm_macros.svh" 
import uvm_pkg::*;

// Assuming these include files contain your UVM Agent classes (still necessary)
`include "ahb_agt.svh"
`include "apb_agt.svh"

class envir extends uvm_env;
	`uvm_component_utils(envir)

    // =========================================================================
    // 1. LOCAL CONFIGURATION CLASSES (Moved from separate files)
    // =========================================================================

    class ahb_agent_config extends uvm_object;
        `uvm_object_utils (ahb_agent_config)
        virtual ahb_if vif;
        uvm_active_passive_enum is_active = UVM_ACTIVE;
        int drv_data_count = 0; 
        int mon_data_count = 0;
        function new (string name = "ahb_agent_config");
            super.new(name);
        endfunction : new
    endclass

    class apb_agent_config extends uvm_object;
        `uvm_object_utils(apb_agent_config)
        virtual apb_if vif;
        uvm_active_passive_enum is_active = UVM_ACTIVE;
        int drv_data_count = 0; 
        int mon_data_count = 0;
        function new(string name = "apb_agent_config");
            super.new(name);
        endfunction
    endclass
    
    // =========================================================================
    // 2. ENVIRONMENT COMPONENTS AND CONFIGURATION HANDLES
    // =========================================================================
    
	ahb_agt ahb_agt1;
	apb_agt apb_agt1;
    
    // Configuration objects - MUST use scope resolution (envir::)
    envir::apb_agent_config apb_cfg;
    envir::ahb_agent_config ahb_cfg;

	function new(string name="envir", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
        
        // ---------------------------------------------
        // 1. CONFIGURE AHB AGENT (Master Role)
        // ---------------------------------------------
        
        // Use the local class definition
        ahb_cfg = ahb_agent_config::type_id::create("ahb_cfg", this);
        ahb_cfg.is_active = UVM_ACTIVE;
        
        // Note: The uvm_config_db SET call does NOT need scope resolution
        uvm_config_db#(ahb_agent_config)::set(this, "ahb_agt1", "cfg", ahb_cfg);

        // ---------------------------------------------
        // 2. CONFIGURE APB AGENT (Slave/Monitor Role)
        // ---------------------------------------------
        
        // Use the local class definition
        apb_cfg = apb_agent_config::type_id::create("apb_cfg", this);
        apb_cfg.is_active = UVM_PASSIVE; 
        
        uvm_config_db#(apb_agent_config)::set(this, "apb_agt1", "cfg", apb_cfg);

        // ---------------------------------------------
        // 3. CREATE AGENTS 
        // ---------------------------------------------
        ahb_agt1 = ahb_agt::type_id::create("ahb_agt1", this);
        apb_agt1 = apb_agt::type_id::create("apb_agt1", this);

	endfunction : build_phase

endclass
