package ram_seq_item_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    typedef enum bit [1:0] {
        WRITE_ADDR = 2'b00,
        WRITE_DATA = 2'b01,
        READ_ADDR  = 2'b10,
        READ_DATA  = 2'b11
    } cmd_type;
    
    class ram_seq_item extends uvm_sequence_item;
        `uvm_object_utils(ram_seq_item)
        
        // Inputs
        rand bit rst_n;
        rand bit rx_valid;
        rand bit [1:0] cmd;
        rand bit [7:0] addr_data;
        // Combined din signal
        bit [9:0] din;
        // Outputs
        logic [7:0] dout;
        logic tx_valid;
        // Golden outputs
        logic [7:0] dout_golden;
        logic tx_valid_golden;
        // Helper variable to track previous command (for constraints)
        cmd_type prev_cmd;

        function new(string name = "ram_seq_item");
            super.new(name);
        endfunction

        function string convert2string();
            return $sformatf("rst_n=%0b, rx_valid=%0b, din=%10b (cmd=%2b, data=%8b), dout=%8b, tx_valid=%0b",
                rst_n, rx_valid, din, cmd, addr_data, dout, tx_valid);
        endfunction
        
        function string convert2string_stimulus();
            return $sformatf("rst_n=%0b, rx_valid=%0b, din=%10b (cmd=%2b, data=%8b)",
                rst_n, rx_valid, din, cmd, addr_data);
        endfunction

        // ---------------------- Constraints ----------------------
        
        // reset signal deasserted most of the time
        constraint rst_c {
            rst_n dist {1 := 99, 0 := 1};
        }

        // rx_valid asserted most of the time
        constraint rx_valid_c {
            rx_valid dist {1 := 95, 0 := 5};
        }
        
        // Write-only sequence behavior
        constraint write_only_c {
            // Force cmd to only be WRITE_ADDR or WRITE_DATA
            cmd inside {WRITE_ADDR, WRITE_DATA};

            // Every Write Address must be followed by Write Address or Write Data
            if (prev_cmd == WRITE_ADDR) {
                cmd inside {WRITE_ADDR, WRITE_DATA};
            }
        }
        
        // Read-only sequence behavior
        constraint read_only_c {
            // Every Read Address must be followed by Read Data
            if (prev_cmd == READ_ADDR) {
                cmd == READ_DATA;
            }
            // Every Read Data must be followed by Read Address
            else if (prev_cmd == READ_DATA) {
                cmd == READ_ADDR;
            }
        }
        
        // Write-Read sequence with probabilities
        constraint write_read_c {
            // Write Address must be followed by Write Address or Write Data
            if (prev_cmd == WRITE_ADDR) {
                cmd inside {WRITE_ADDR, WRITE_DATA};
            }
            // After Write Data: 60% Read Address, 40% Write Address
            else if (prev_cmd == WRITE_DATA) {
                cmd dist {READ_ADDR := 60, WRITE_ADDR := 40};
            }
            // Read Address must be followed by Read Data
            else if (prev_cmd == READ_ADDR) {
                cmd == READ_DATA;
            }
            // After Read Data: 60% Write Address, 40% Read Address
            else if (prev_cmd == READ_DATA) {
                cmd dist {WRITE_ADDR := 60, READ_ADDR := 40};
            }
        }

        function void post_randomize();
            // Combine cmd and addr_data into din
            din = {cmd, addr_data};
            // Update prev_cmd for next randomization (only if valid transaction)
            if (rx_valid && rst_n) begin
                prev_cmd = cmd_type'(cmd);
            end
        endfunction
    endclass
endpackage