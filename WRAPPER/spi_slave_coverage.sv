package spi_slave_coverage_pkg;
    import uvm_pkg::*;
    import spi_slave_seq_item_pkg::*;
    `include "uvm_macros.svh"
    
    class spi_slave_coverage extends uvm_component;
        `uvm_component_utils(spi_slave_coverage)
        
        uvm_analysis_export #(spi_slave_seq_item) cov_export;
        uvm_tlm_analysis_fifo #(spi_slave_seq_item) cov_fifo;
        spi_slave_seq_item seq_item_cov;
           
        covergroup spi_cg;
            rx_cmd_cp: coverpoint seq_item_cov.rx_data[9:8] {
                bins wr_addr = {2'b00};
                bins wr_data = {2'b01};
                bins rd_addr = {2'b10};
                bins rd_data = {2'b11};
                bins wr_addr_to_wr_addr   = (2'b00 => 2'b00);
                bins wr_addr_to_wr_data  = (2'b00 => 2'b01);
                bins wr_addr_to_rd_addr   = (2'b00 => 2'b10);
                bins wr_data_to_wr_addr  = (2'b01 => 2'b00);
                bins wr_data_to_wr_data = (2'b01 => 2'b01);
                bins wr_data_to_rd_data = (2'b01 => 2'b11);
                bins rd_addr_to_rd_addr   = (2'b10 => 2'b10);
                bins rd_addr_to_rd_data  = (2'b10 => 2'b11);
                bins rd_data_to_wr_addr  = (2'b11 => 2'b00);
                bins rd_data_to_wr_data = (2'b11 => 2'b01);
                bins rd_data_to_rd_data = (2'b11 => 2'b11);
            }

            SS_n_cp: coverpoint seq_item_cov.SS_n {
                bins normal_transaction = (1 => 0 [*13] => 1);
                bins extended_transaction = (1 => 0 [*23] => 1);
                bins SS_n_low  = {0} ;
                bins SS_n_high = {1};  
            }

            MOSI_cp: coverpoint seq_item_cov.MOSI {
                bins write_addr = (0 => 0 => 0);
                bins write_data = (0 => 0 => 1);
                bins read_addr  = (1 => 1 => 0);
                bins read_data  = (1 => 1 => 1);
                bins MOSI_low   = {0} ;
                bins MOSI_high  = {1};
            }

            cross SS_n_cp , MOSI_cp {
                option.cross_auto_bin_max = 0 ;
                bins ss_n_0_MOSI_0 = binsof (MOSI_cp.MOSI_low) && binsof (SS_n_cp.SS_n_low);
                bins ss_n_1_MOSI_0 = binsof (MOSI_cp.MOSI_low) && binsof (SS_n_cp.SS_n_high);
                bins ss_n_0_MOSI_1 = binsof (MOSI_cp.MOSI_high) && binsof (SS_n_cp.SS_n_low);
                bins ss_n_1_MOSI_1 = binsof (MOSI_cp.MOSI_high) && binsof (SS_n_cp.SS_n_high);
            }

        endgroup
        
        function new(string name = "spi_slave_coverage", uvm_component parent = null);
            super.new(name, parent);
            spi_cg = new();
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
                spi_cg.sample();
            end
        endtask
    endclass
endpackage