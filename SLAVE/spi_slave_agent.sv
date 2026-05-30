package spi_slave_agent_pkg;
    import uvm_pkg::*;
    import spi_slave_driver_pkg::*;
    import spi_slave_monitor_pkg::*;
    import spi_slave_sequencer_pkg::*;
    import spi_slave_config_pkg::*;
    import spi_slave_seq_item_pkg::*;
    `include "uvm_macros.svh"
    
    class spi_slave_agent extends uvm_agent;
        `uvm_component_utils(spi_slave_agent)
        
        spi_slave_driver drv;
        spi_slave_monitor mon;
        spi_slave_sequencer sqr;
        spi_slave_config spi_cfg;
        uvm_analysis_port #(spi_slave_seq_item) agt_ap;
        
        function new(string name = "spi_slave_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction
        
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(spi_slave_config)::get(this, "", "spi_slave_config", spi_cfg)) begin
                `uvm_fatal("build_phase", "Unable to get configuration object")
            end
            
            mon = spi_slave_monitor::type_id::create("mon", this);
            
            if(spi_cfg.is_active == UVM_ACTIVE) begin
                drv = spi_slave_driver::type_id::create("drv", this);
                sqr = spi_slave_sequencer::type_id::create("sqr", this);
            end
            agt_ap = new("agt_ap", this);
        endfunction
        
        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            mon.spi_vif = spi_cfg.spi_vif;
            if(spi_cfg.is_active == UVM_ACTIVE) begin
                drv.spi_vif = spi_cfg.spi_vif;
                drv.seq_item_port.connect(sqr.seq_item_export);
            end
            mon.mon_ap.connect(agt_ap);
        endfunction
    endclass
endpackage