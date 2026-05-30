package spi_slave_scoreboard_pkg;
    import uvm_pkg::*;
    import spi_slave_seq_item_pkg::*;
    `include "uvm_macros.svh"
    
    class spi_slave_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(spi_slave_scoreboard)
        
        uvm_analysis_export #(spi_slave_seq_item) sb_export;
        uvm_tlm_analysis_fifo #(spi_slave_seq_item) sb_fifo;
        spi_slave_seq_item seq_item_sb;
        
        logic [9:0]  rx_data_ref;
        logic rx_valid_ref ;
        logic MISO_ref ;

        localparam IDLE      = 3'b000;
        localparam WRITE     = 3'b001;
        localparam CHK_CMD   = 3'b010;
        localparam READ_ADD  = 3'b011;
        localparam READ_DATA = 3'b100;
        logic [2:0] cs, ns;
        logic received_address ;
        logic [3:0] counter;

        int error_count   = 0 ;
        int correct_count = 0 ;
        
        function new(string name = "spi_slave_scoreboard", uvm_component parent = null);
            super.new(name, parent);
        endfunction
        
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sb_export = new("sb_export", this);
            sb_fifo = new("sb_fifo", this);
        endfunction
        
        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            sb_export.connect(sb_fifo.analysis_export);
        endfunction
        
        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                sb_fifo.get(seq_item_sb);
                
                // Check MISO
                if (seq_item_sb.MISO !== seq_item_sb.MISO_golden) begin
                    `uvm_error("run_phase", $sformatf("MISO Mismatch: DUT=%0b, Golden=%0b | %s",
                        seq_item_sb.MISO, seq_item_sb.MISO_golden, seq_item_sb.convert2string()));
                    error_count++;
                end else begin
                    `uvm_info("run_phase", $sformatf("MISO Correct: %s", seq_item_sb.convert2string()), UVM_HIGH);
                    correct_count++;
                end
                
                // Check rx_data
                if (seq_item_sb.rx_data !== seq_item_sb.rx_data_golden) begin
                    `uvm_error("run_phase", $sformatf("rx_data Mismatch: DUT=%0h, Golden=%0h | %s",
                        seq_item_sb.rx_data, seq_item_sb.rx_data_golden, seq_item_sb.convert2string()));
                    error_count++;
                end else begin
                    `uvm_info("run_phase", $sformatf("rx_data Correct: %s", seq_item_sb.convert2string()), UVM_HIGH);
                    correct_count++;
                end
                
                // Check rx_valid
                if (seq_item_sb.rx_valid !== seq_item_sb.rx_valid_golden) begin
                    `uvm_error("run_phase", $sformatf("rx_valid Mismatch: DUT=%0b, Golden=%0b | %s",
                        seq_item_sb.rx_valid, seq_item_sb.rx_valid_golden, seq_item_sb.convert2string()));
                    error_count++;
                end else begin
                    `uvm_info("run_phase", $sformatf("rx_valid Correct: %s", seq_item_sb.convert2string()), UVM_HIGH);
                    correct_count++;
                end
            end
        endtask
        
        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            `uvm_info("report_phase", $sformatf("Total correct checks: %0d", correct_count), UVM_MEDIUM)
            `uvm_info("report_phase", $sformatf("Total errors: %0d", error_count), UVM_MEDIUM)
        endfunction
    endclass
endpackage