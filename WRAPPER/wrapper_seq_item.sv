package wrapper_seq_item_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    typedef enum bit [2:0] {
        WRITE_ADD  = 3'b000,
        WRITE_DATA = 3'b001,
        READ_ADD   = 3'b110,
        READ_DATA  = 3'b111
    } cmd_type;
    
    class wrapper_seq_item extends uvm_sequence_item;
        `uvm_object_utils(wrapper_seq_item)
        
        // Inputs
        rand bit rst_n;
        rand bit SS_n;
        rand bit [10:0] MOSI_data;  // 11 bits: [10:8]=cmd, [7:0]=addr/data
        bit MOSI;
        
        // Output
        logic MISO;
        
        // Golden output
        logic MISO_golden;
        
        // Helper variables
        int cycles_counter;
        cmd_type prev_cmd;  // Track previous command for ordering constraints

        function new(string name = "wrapper_seq_item");
            super.new(name);
            cycles_counter = 0;
            prev_cmd = WRITE_ADD;
        endfunction

        function string convert2string();
            return $sformatf("cycles=%0d, rst_n=%0b, SS_n=%0b, MOSI_data=%11b, MOSI=%0b, MISO=%0b, prev_cmd=%s",
                cycles_counter, rst_n, SS_n, MOSI_data, MOSI, MISO, prev_cmd.name());
        endfunction
        
        function string convert2string_stimulus();
            return $sformatf("cycles=%0d, rst_n=%0b, SS_n=%0b, MOSI_data=%11b, MOSI=%0b",
                cycles_counter, rst_n, SS_n, MOSI_data, MOSI);
        endfunction

        // ---------------------- Constraints ----------------------
        
        // Constraint 1: Reset deasserted most of the time
        constraint rst_c {
            rst_n dist {1 := 98, 0 := 2};
        }

        // Constraint 3: Valid command combinations only
        constraint valid_cmd_c {
            MOSI_data[10:8] inside {WRITE_ADD, WRITE_DATA, READ_ADD, READ_DATA};
        }
        
        // Constraint 2: SS_n timing
        constraint SS_n_c {
            if (rst_n == 0) {
                SS_n == 1;
            }
            else if (MOSI_data[10:8] == READ_DATA) {
                // Extended transaction: 23 cycles
                if (cycles_counter >= 0 && cycles_counter <= 22) 
                    SS_n == 0;
                else 
                    SS_n == 1;
            }
            else {
                // Normal transaction: 13 cycles
                if (cycles_counter >= 0 && cycles_counter <= 12) 
                    SS_n == 0;
                else 
                    SS_n == 1;
            }
        }
        
        // Constraint 4: Write-only sequence
        constraint write_only_c {
            if (cycles_counter == 0) {
                MOSI_data[10:8] inside {WRITE_ADD, WRITE_DATA};
                
                if (prev_cmd == WRITE_ADD) {
                    MOSI_data[10:8] inside {WRITE_ADD, WRITE_DATA};
                }
            }
        }
        
        // Constraint 5: Read-only sequence
        constraint read_only_c {
            if (cycles_counter == 0) {
                if (prev_cmd == READ_ADD) {
                    MOSI_data[10:8] == READ_DATA;
                }
                else if (prev_cmd == READ_DATA) {
                    MOSI_data[10:8] == READ_ADD;
                }
            }
        }
        
        // Constraint 6: Write-Read sequence
        constraint write_read_c {
            if (cycles_counter == 0) {
                if (prev_cmd == WRITE_ADD) {
                    MOSI_data[10:8] inside {WRITE_ADD, WRITE_DATA};
                }
                else if (prev_cmd == WRITE_DATA) {
                    MOSI_data[10:8] dist {READ_ADD := 60, WRITE_ADD := 40};
                }
                else if (prev_cmd == READ_ADD) {
                    MOSI_data[10:8] == READ_DATA;
                }
                else if (prev_cmd == READ_DATA) {
                    MOSI_data[10:8] dist {WRITE_ADD := 60, READ_ADD := 40};
                }
            }
        }

        function void pre_randomize();
            if (SS_n == 0) begin
                cycles_counter++;
            end
            else begin
                cycles_counter = 0;
            end
            
            // Only randomize MOSI_data at start of transaction
            if (cycles_counter == 0) begin
                MOSI_data.rand_mode(1);
            end
            else begin
                MOSI_data.rand_mode(0);
            end
        endfunction
        
        function void post_randomize();
            // Drive MOSI serially
            if (cycles_counter >= 1 && cycles_counter <= 11) begin
                MOSI = MOSI_data[11 - cycles_counter];
            end
            else if (MOSI_data[10:8] == READ_DATA && cycles_counter >= 12 && cycles_counter <= 22) begin
                MOSI = 1'b0;
            end
            else begin
                MOSI = 1'b0;
            end
            
            // Update prev_cmd at end of transaction
            if (cycles_counter == 12 || (MOSI_data[10:8] == READ_DATA && cycles_counter == 22)) begin
                prev_cmd = cmd_type'(MOSI_data[10:8]);
            end
        endfunction
    endclass
endpackage