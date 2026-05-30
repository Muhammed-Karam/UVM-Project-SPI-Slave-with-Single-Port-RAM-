package ram_coverage_pkg;
    import uvm_pkg::*;
    import ram_seq_item_pkg::*;
    `include "uvm_macros.svh"
    
    class ram_coverage extends uvm_component;
        `uvm_component_utils(ram_coverage)
        
        uvm_analysis_export #(ram_seq_item) cov_export;
        uvm_tlm_analysis_fifo #(ram_seq_item) cov_fifo;
        ram_seq_item seq_item_cov;
           
        covergroup ram_cg;
            // Functional Coverage Requirement 1: Transaction ordering for din[9:8]
            
            // Check din[9:8] takes 4 possible values
            din_cmd_cp: coverpoint seq_item_cov.din[9:8] {
                bins write_addr = {2'b00};
                bins write_data = {2'b01};
                bins read_addr  = {2'b10};
                bins read_data  = {2'b11};
                
                // Check write data after write address
                bins write_addr_to_write_data = (2'b00 => 2'b01);
                // Check read data after read address
                bins read_addr_to_read_data = (2'b10 => 2'b11);
            }
            
            // Coverpoint for rx_valid
            rx_valid_cp: coverpoint seq_item_cov.rx_valid {
                bins rx_valid_low  = {0};
                bins rx_valid_high = {1};
            }
            
            // Coverpoint for tx_valid  
            tx_valid_cp: coverpoint seq_item_cov.tx_valid {
                bins tx_valid_low  = {0};
                bins tx_valid_high = {1};
            }
            
            // Functional Coverage Requirement 3 (first part):
            // Cross coverage between all bins of din[9:8] and rx_valid when it is high
            cross_din_rx_valid: cross din_cmd_cp, rx_valid_cp {
                option.cross_auto_bin_max = 0;
                bins write_addr_with_rx_valid = binsof(din_cmd_cp.write_addr) && binsof(rx_valid_cp.rx_valid_high);
                bins write_data_with_rx_valid = binsof(din_cmd_cp.write_data) && binsof(rx_valid_cp.rx_valid_high);
                bins read_addr_with_rx_valid  = binsof(din_cmd_cp.read_addr)  && binsof(rx_valid_cp.rx_valid_high);
                bins read_data_with_rx_valid  = binsof(din_cmd_cp.read_data)  && binsof(rx_valid_cp.rx_valid_high);
            }
            
            // Functional Coverage Requirement 3 (second part):
            // Cross between din[9:8] when it equals read data and tx_valid when it is high
            cross_read_data_tx_valid: cross din_cmd_cp, tx_valid_cp {
                option.cross_auto_bin_max = 0;
                bins read_data_with_tx_valid = binsof(din_cmd_cp.read_data) && binsof(tx_valid_cp.tx_valid_high);
            }

        endgroup
        
        function new(string name = "ram_coverage", uvm_component parent = null);
            super.new(name, parent);
            ram_cg = new();
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
                ram_cg.sample();
            end
        endtask
    endclass
endpackage