package wrapper_test_pkg;
    import uvm_pkg::*;
    import wrapper_env_pkg::*;
    import wrapper_config_pkg::*;
    import ram_config_pkg::*;
    import spi_slave_config_pkg::*;
    import wrapper_reset_sequence_pkg::*;
    import wrapper_write_only_sequence_pkg::*;
    import wrapper_read_only_sequence_pkg::*;
    import wrapper_write_read_sequence_pkg::*;
    `include "uvm_macros.svh"
    
    class wrapper_test extends uvm_test;
        `uvm_component_utils(wrapper_test)
        
        // Configurations
        wrapper_config wrapper_cfg;
        ram_config ram_cfg;
        spi_slave_config spi_cfg;
        
        // Environment
        wrapper_env wrapper_environment;
        
        // Sequences
        wrapper_write_only_sequence write_only_seq;
        wrapper_read_only_sequence read_only_seq;
        wrapper_write_read_sequence write_read_seq;
        wrapper_reset_sequence reset_seq;
        
        // Virtual interfaces
        virtual wrapper_if wrapper_vif;
        virtual ram_if ram_vif;
        virtual spi_slave_if spi_vif;
        
        function new(string name = "wrapper_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction
        
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            
            // Create environment
            wrapper_environment = wrapper_env::type_id::create("wrapper_environment", this);
            
            // Create config objects
            wrapper_cfg = wrapper_config::type_id::create("wrapper_cfg");
            ram_cfg = ram_config::type_id::create("ram_cfg");
            spi_cfg = spi_slave_config::type_id::create("spi_cfg");
            
            // Create sequences
            write_only_seq = wrapper_write_only_sequence::type_id::create("write_only_seq", this);
            read_only_seq = wrapper_read_only_sequence::type_id::create("read_only_seq", this);
            write_read_seq = wrapper_write_read_sequence::type_id::create("write_read_seq", this);
            reset_seq = wrapper_reset_sequence::type_id::create("reset_seq", this);
            
            // Get virtual interfaces from config_db
            if(!uvm_config_db#(virtual wrapper_if)::get(this, "", "wrapper_IF", wrapper_cfg.wrapper_vif))
                `uvm_fatal("build_phase", "Test - Unable to get wrapper virtual interface")
            
            if(!uvm_config_db#(virtual ram_if)::get(this, "", "ram_IF", ram_cfg.ram_vif))
                `uvm_fatal("build_phase", "Test - Unable to get RAM virtual interface")
            
            if(!uvm_config_db#(virtual spi_slave_if)::get(this, "", "spi_slave_IF", spi_cfg.spi_vif))
                `uvm_fatal("build_phase", "Test - Unable to get SPI Slave virtual interface")
            
            // Set wrapper agent as ACTIVE
            wrapper_cfg.is_active = UVM_ACTIVE;
            wrapper_cfg.spi_vif = spi_cfg.spi_vif;
            wrapper_cfg.ram_vif = ram_cfg.ram_vif;
            
            // Set RAM agent as PASSIVE
            ram_cfg.is_active = UVM_PASSIVE;
            
            // Set SPI Slave agent as PASSIVE
            spi_cfg.is_active = UVM_PASSIVE;
            
            // Set configurations in config_db
            uvm_config_db#(wrapper_config)::set(this, "*", "wrapper_config", wrapper_cfg);
            uvm_config_db#(ram_config)::set(this, "wrapper_environment.ram_agt*", "ram_config", ram_cfg);
            uvm_config_db#(spi_slave_config)::set(this, "wrapper_environment.spi_agt*", "spi_slave_config", spi_cfg);
        endfunction
        
        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            phase.raise_objection(this);
            
            `uvm_info("run_phase", "Reset Asserted", UVM_LOW)
            reset_seq.start(wrapper_environment.wrapper_agt.sqr);
            `uvm_info("run_phase", "Reset Deasserted", UVM_LOW)
            
            `uvm_info("run_phase", "Write Only Sequence Starting", UVM_LOW)
            write_only_seq.start(wrapper_environment.wrapper_agt.sqr);
            `uvm_info("run_phase", "Write Only Sequence Completed", UVM_LOW)
            
            `uvm_info("run_phase", "Read Only Sequence Starting", UVM_LOW)
            read_only_seq.start(wrapper_environment.wrapper_agt.sqr);
            `uvm_info("run_phase", "Read Only Sequence Completed", UVM_LOW)
            
            `uvm_info("run_phase", "Write-Read Sequence Starting", UVM_LOW)
            write_read_seq.start(wrapper_environment.wrapper_agt.sqr);
            `uvm_info("run_phase", "Write-Read Sequence Completed", UVM_LOW)
            
            phase.drop_objection(this);
        endtask
    endclass
endpackage