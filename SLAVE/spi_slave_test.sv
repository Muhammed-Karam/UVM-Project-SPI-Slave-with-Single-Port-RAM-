package spi_slave_test_pkg;
    import uvm_pkg::*;
    import spi_slave_env_pkg::*;
    import spi_slave_config_pkg::*;
    import spi_slave_reset_sequence_pkg::*;
    import spi_slave_main_sequence_pkg::*;
    `include "uvm_macros.svh"
    
    class spi_slave_test extends uvm_test;
        `uvm_component_utils(spi_slave_test)
        
        spi_slave_config spi_cfg;
        spi_slave_env spi_environment;
        spi_slave_main_sequence main_seq;
        spi_slave_reset_sequence reset_seq;
        virtual spi_slave_if spi_vif;
        
        function new(string name = "spi_slave_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction
        
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            spi_environment = spi_slave_env::type_id::create("spi_environment", this);
            spi_cfg = spi_slave_config::type_id::create("spi_cfg");
            main_seq = spi_slave_main_sequence::type_id::create("main_seq", this);
            reset_seq = spi_slave_reset_sequence::type_id::create("reset_seq", this);
            
            if(!uvm_config_db#(virtual spi_slave_if)::get(this, "", "spi_slave_IF", spi_cfg.spi_vif))
                `uvm_fatal("build_phase", "Test - Unable to get virtual interface")
            
            spi_cfg.is_active = UVM_ACTIVE;
            
            uvm_config_db#(spi_slave_config)::set(this, "*", "spi_slave_config", spi_cfg);
        endfunction
        
        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            phase.raise_objection(this);
            
            `uvm_info("run_phase", "Reset Asserted", UVM_LOW)
            reset_seq.start(spi_environment.agt.sqr);
            `uvm_info("run_phase", "Reset Deasserted", UVM_LOW)
            
            `uvm_info("run_phase", "Stimulus Generation starting", UVM_LOW)
            main_seq.start(spi_environment.agt.sqr);
            `uvm_info("run_phase", "Stimulus Generation completed", UVM_LOW)
            
            phase.drop_objection(this);
        endtask
    endclass
endpackage