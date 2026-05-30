package ram_test_pkg;
    import uvm_pkg::*;
    import ram_env_pkg::*;
    import ram_config_pkg::*;
    import ram_reset_sequence_pkg::*;
    import ram_write_only_sequence_pkg::*;
    import ram_read_only_sequence_pkg::*;
    import ram_write_read_sequence_pkg::*;
    `include "uvm_macros.svh"
    
    class ram_test extends uvm_test;
        `uvm_component_utils(ram_test)
        
        ram_config ram_cfg;
        ram_env ram_environment;
        ram_write_only_sequence write_only_seq;
        ram_read_only_sequence read_only_seq;
        ram_write_read_sequence write_read_seq;
        ram_reset_sequence reset_seq;
        virtual ram_if ram_vif;
        
        function new(string name = "ram_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction
        
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            ram_environment = ram_env::type_id::create("ram_environment", this);
            ram_cfg = ram_config::type_id::create("ram_cfg");
            write_only_seq = ram_write_only_sequence::type_id::create("write_only_seq", this);
            read_only_seq = ram_read_only_sequence::type_id::create("read_only_seq", this);
            write_read_seq = ram_write_read_sequence::type_id::create("write_read_seq", this);
            reset_seq = ram_reset_sequence::type_id::create("reset_seq", this);
            
            if(!uvm_config_db#(virtual ram_if)::get(this, "", "ram_IF", ram_cfg.ram_vif))
                `uvm_fatal("build_phase", "Test - Unable to get virtual interface")
            
            ram_cfg.is_active = UVM_ACTIVE;
            
            uvm_config_db#(ram_config)::set(this, "*", "ram_config", ram_cfg);
        endfunction
        
        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            phase.raise_objection(this);
            
            `uvm_info("run_phase", "Reset Asserted", UVM_LOW)
            reset_seq.start(ram_environment.agt.sqr);
            `uvm_info("run_phase", "Reset Deasserted", UVM_LOW)
            
            `uvm_info("run_phase", "Write Only Sequence Starting", UVM_LOW)
            write_only_seq.start(ram_environment.agt.sqr);
            `uvm_info("run_phase", "Write Only Sequence Completed", UVM_LOW)
            
            `uvm_info("run_phase", "Read Only Sequence Starting", UVM_LOW)
            read_only_seq.start(ram_environment.agt.sqr);
            `uvm_info("run_phase", "Read Only Sequence Completed", UVM_LOW)
            
            `uvm_info("run_phase", "Write-Read Sequence Starting", UVM_LOW)
            write_read_seq.start(ram_environment.agt.sqr);
            `uvm_info("run_phase", "Write-Read Sequence Completed", UVM_LOW)
            
            phase.drop_objection(this);
        endtask
    endclass
endpackage