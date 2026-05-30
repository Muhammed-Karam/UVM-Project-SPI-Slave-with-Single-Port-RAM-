package wrapper_scoreboard_pkg;
    import uvm_pkg::*;
    import wrapper_seq_item_pkg::*;
    `include "uvm_macros.svh"
    
    class wrapper_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(wrapper_scoreboard)
        
        uvm_analysis_export #(wrapper_seq_item) sb_export;
        uvm_tlm_analysis_fifo #(wrapper_seq_item) sb_fifo;
        wrapper_seq_item seq_item_sb;
        
        int error_count   = 0;
        int correct_count = 0;
        
        function new(string name = "wrapper_scoreboard", uvm_component parent = null);
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
            end
        endtask
        
        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            `uvm_info("report_phase", $sformatf("Total correct checks: %0d", correct_count), UVM_MEDIUM)
            `uvm_info("report_phase", $sformatf("Total errors: %0d", error_count), UVM_MEDIUM)
        endfunction
    endclass
endpackage