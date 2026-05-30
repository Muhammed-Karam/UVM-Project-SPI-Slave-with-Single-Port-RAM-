package wrapper_env_pkg;
    import uvm_pkg::*;
    import wrapper_agent_pkg::*;
    import wrapper_scoreboard_pkg::*;
    import wrapper_coverage_pkg::*;
    import ram_agent_pkg::*;
    import spi_slave_agent_pkg::*;
    import ram_coverage_pkg::*;
    import spi_slave_coverage_pkg::*;
    `include "uvm_macros.svh"
    
    class wrapper_env extends uvm_env;
        `uvm_component_utils(wrapper_env)
        
        // Wrapper agent (active)
        wrapper_agent wrapper_agt;
        wrapper_scoreboard wrapper_sb;
        wrapper_coverage wrapper_cov;
        
        // RAM agent (passive - monitoring only)
        ram_agent ram_agt;
        ram_coverage ram_cov;
        
        // SPI Slave agent (passive - monitoring only)
        spi_slave_agent spi_agt;
        spi_slave_coverage spi_cov;
        
        function new(string name = "wrapper_env", uvm_component parent = null);
            super.new(name, parent);
        endfunction
        
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            
            // Build wrapper components
            wrapper_agt = wrapper_agent::type_id::create("wrapper_agt", this);
            wrapper_sb = wrapper_scoreboard::type_id::create("wrapper_sb", this);
            wrapper_cov = wrapper_coverage::type_id::create("wrapper_cov", this);
            
            // Build RAM components (passive)
            ram_agt = ram_agent::type_id::create("ram_agt", this);
            ram_cov = ram_coverage::type_id::create("ram_cov", this);
            
            // Build SPI Slave components (passive)
            spi_agt = spi_slave_agent::type_id::create("spi_agt", this);
            spi_cov = spi_slave_coverage::type_id::create("spi_cov", this);
        endfunction
        
        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            
            // Connect wrapper agent to scoreboard and coverage
            wrapper_agt.agt_ap.connect(wrapper_sb.sb_export);
            wrapper_agt.agt_ap.connect(wrapper_cov.cov_export);
            
            // Connect RAM agent to coverage
            ram_agt.agt_ap.connect(ram_cov.cov_export);
            
            // Connect SPI Slave agent to coverage
            spi_agt.agt_ap.connect(spi_cov.cov_export);
        endfunction
    endclass
endpackage