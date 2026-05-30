package spi_slave_env_pkg;
    import uvm_pkg::*;
    import spi_slave_agent_pkg::*;
    import spi_slave_scoreboard_pkg::*;
    import spi_slave_coverage_pkg::*;
    `include "uvm_macros.svh"
    
    class spi_slave_env extends uvm_env;
        `uvm_component_utils(spi_slave_env)
        
        spi_slave_agent agt;
        spi_slave_scoreboard sb;
        spi_slave_coverage cov;
        
        function new(string name = "spi_slave_env", uvm_component parent = null);
            super.new(name, parent);
        endfunction
        
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agt = spi_slave_agent::type_id::create("agt", this);
            sb = spi_slave_scoreboard::type_id::create("sb", this);
            cov = spi_slave_coverage::type_id::create("cov", this);
        endfunction
        
        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            agt.agt_ap.connect(sb.sb_export);
            agt.agt_ap.connect(cov.cov_export);
        endfunction
    endclass
endpackage