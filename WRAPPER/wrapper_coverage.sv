package wrapper_coverage_pkg;
    import uvm_pkg::*;
    import wrapper_seq_item_pkg::*;
    `include "uvm_macros.svh"
    
    class wrapper_coverage extends uvm_component;
        `uvm_component_utils(wrapper_coverage)
        
        uvm_analysis_export #(wrapper_seq_item) cov_export;
        uvm_tlm_analysis_fifo #(wrapper_seq_item) cov_fifo;
        wrapper_seq_item seq_item_cov;
           
        covergroup wrapper_cg;
            // Coverpoint for command types
            cmd_cp: coverpoint seq_item_cov.MOSI {
                bins write_addr = (0 => 0 => 0);
                bins write_data = (0 => 0 => 1);
                bins read_addr  = (1 => 1 => 0);
                bins read_data  = (1 => 1 => 1);
            }

            // SS_n timing coverage
            SS_n_cp: coverpoint seq_item_cov.SS_n {
                bins ss_low  = {0};
                bins ss_high = {1};
            }

            // MOSI coverage
            MOSI_cp: coverpoint seq_item_cov.MOSI {
                bins mosi_low  = {0};
                bins mosi_high = {1};
            }

            // MISO coverage
            MISO_cp: coverpoint seq_item_cov.MISO {
                bins miso_low  = {0};
                bins miso_high = {1};
            }

            // Reset coverage
            rst_cp: coverpoint seq_item_cov.rst_n {
                bins reset_active   = {0};
                bins reset_inactive = {1};
            }

            // Cross coverage: Command type with SS_n
            cross_cmd_ss: cross cmd_cp, SS_n_cp {
                option.cross_auto_bin_max = 0;
                bins write_addr_active = binsof(cmd_cp.write_addr) && binsof(SS_n_cp.ss_low);
                bins write_data_active = binsof(cmd_cp.write_data) && binsof(SS_n_cp.ss_low);
                bins read_addr_active  = binsof(cmd_cp.read_addr)  && binsof(SS_n_cp.ss_low);
                bins read_data_active  = binsof(cmd_cp.read_data)  && binsof(SS_n_cp.ss_low);
            }

            // Cross coverage: MOSI and MISO
            cross_mosi_miso: cross MOSI_cp, MISO_cp {
                option.cross_auto_bin_max = 0;
                bins both_low  = binsof(MOSI_cp.mosi_low)  && binsof(MISO_cp.miso_low);
                bins both_high = binsof(MOSI_cp.mosi_high) && binsof(MISO_cp.miso_high);
                bins mosi_high_miso_low = binsof(MOSI_cp.mosi_high) && binsof(MISO_cp.miso_low);
                bins mosi_low_miso_high = binsof(MOSI_cp.mosi_low)  && binsof(MISO_cp.miso_high);
            }

        endgroup
        
        function new(string name = "wrapper_coverage", uvm_component parent = null);
            super.new(name, parent);
            wrapper_cg = new();
        endfunction
        
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            cov_export = new("cov_export", this);
            cov_fifo = new("cov_fifo", this);
        endfunction
        
        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            cov_export.connect(cov_fifo.analysis_export);
        endfunction
        
        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                cov_fifo.get(seq_item_cov);
                wrapper_cg.sample();
            end
        endtask
    endclass
endpackage