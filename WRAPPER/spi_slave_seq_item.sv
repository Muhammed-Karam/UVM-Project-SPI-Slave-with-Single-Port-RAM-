package spi_slave_seq_item_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    typedef enum bit [2:0] {
        WRITE_ADD  = 3'b000,
        WRITE_DATA = 3'b001,
        READ_ADD   = 3'b110,
        READ_DATA  = 3'b111
    } cmd_type;
    
    class spi_slave_seq_item extends uvm_sequence_item;
        `uvm_object_utils(spi_slave_seq_item)
        
        // Inputs
        rand bit rst_n;
        rand bit SS_n;
        rand bit [10:0] MOSI_data;  // 11 bits total:
                                     // [10:8] = 3-bit command
                                     // [7:0]  = 8-bit address/data
        bit MOSI; 
        rand bit tx_valid;
        rand bit [7:0] tx_data;
        
        // Outputs
        logic MISO;
        logic rx_valid;
        logic [9:0] rx_data;
        
        // Helper variables
        int cycles_counter;
        
        // Golden outputs
        logic MISO_golden;
        logic rx_valid_golden;
        logic [9:0] rx_data_golden;

        function new(string name = "spi_slave_seq_item");
            super.new(name);
            cycles_counter = 0;
        endfunction

        function string convert2string();
            return $sformatf("cycles_counter=%0d, rst_n=%0b, SS_n=%0b, MOSI_data=%11b, MOSI=%0b, tx_valid=%0b, tx_data=%0h, rx_valid=%0b, rx_data=%0h, MISO=%0b",
                cycles_counter, rst_n, SS_n, MOSI_data, MOSI, tx_valid, tx_data, rx_valid, rx_data, MISO);
        endfunction
        
        function string convert2string_stimulus();
            return $sformatf("cycles_counter=%0d, rst_n=%0b, SS_n=%0b, MOSI_data=%11b, MOSI=%0b, tx_valid=%0b, tx_data=%0h",
                cycles_counter, rst_n, SS_n, MOSI_data, MOSI, tx_valid, tx_data);
        endfunction

        // ---------------------- Constraints ----------------------
        
        // Requirement 1: Reset deasserted most of the time (98%)
        constraint rst_c {
            rst_n dist {1 := 98, 0 := 2};
        }

        // Requirement 3: Valid command combinations only (3 bits)
        constraint valid_cmd_c {
            MOSI_data[10:8] inside {WRITE_ADD, WRITE_DATA, READ_ADD, READ_DATA};
        }
        
        // Requirement 2: SS_n timing based on coverage requirements
        // normal_transaction = (1 => 0 [*13] => 1) means 13 cycles of SS_n=0
        // extended_transaction = (1 => 0 [*23] => 1) means 23 cycles of SS_n=0
        constraint SS_n_c {
            if (rst_n == 0) {
                SS_n == 1;  // SS_n must be high during reset
            }
            else if (MOSI_data[10:8] == READ_DATA) {
                // Extended transaction: 23 cycles of SS_n=0
                // Cycles 0-22: SS_n = 0
                // Cycle 23: SS_n = 1
                if (cycles_counter >= 0 && cycles_counter <= 22) 
                    SS_n == 0;
                else 
                    SS_n == 1;
            }
            else {
                // Normal transaction: 13 cycles of SS_n=0  
                // Cycles 0-12: SS_n = 0
                // Cycle 13: SS_n = 1
                if (cycles_counter >= 0 && cycles_counter <= 12) 
                    SS_n == 0;
                else 
                    SS_n == 1;
            }
        }
        
        // Requirement 4: tx_valid high for READ_DATA only
        constraint tx_valid_c {
            if (MOSI_data[10:8] == READ_DATA) {
                // tx_valid should be high during data transmission phase
                // After address is received, during MISO transmission
                if (cycles_counter >= 13 && cycles_counter <= 21)
                    tx_valid == 1;
                else
                    tx_valid == 0;
            }
            else {
                tx_valid == 0;
            }
        }

        // Pre-randomize: Update cycle counter and control randomization
        function void pre_randomize();
            // Track transaction progress
            if (SS_n == 0) begin
                cycles_counter++;
            end
            else begin
                cycles_counter = 0;
            end
            
            // Only randomize MOSI_data at the start of a new transaction
            if (cycles_counter == 0) begin
                MOSI_data.rand_mode(1);
            end
            else begin
                MOSI_data.rand_mode(0);
            end
        endfunction
        
        // Post-randomize: Drive MOSI bit-by-bit serially
        function void post_randomize();
            // Transmission timeline:
            // Cycle 0: SS_n falls, IDLE → CHK_CMD
            // Cycle 1: CHK_CMD samples MOSI[10] (1st cmd bit), sets counter=10
            // Cycles 2-11: Receive 10 bits into rx_data[9:0]
            //   - Cycle 2: rx_data[9] <= MOSI[9] (2nd cmd bit)
            //   - Cycle 3: rx_data[8] <= MOSI[8] (3rd cmd bit)
            //   - Cycles 4-11: rx_data[7:0] <= MOSI[7:0] (data/address)
            // Cycle 12: rx_valid = 1
            
            if (cycles_counter >= 1 && cycles_counter <= 11) begin
                // Shift out MSB first: MOSI_data[10] first, MOSI_data[0] last
                MOSI = MOSI_data[11 - cycles_counter];
            end
            else if (MOSI_data[10:8] == READ_DATA && cycles_counter >= 12 && cycles_counter <= 22) begin
                // For READ_DATA: During data transmission phase
                // MOSI is don't care during this phase (slave is transmitting on MISO)
                MOSI = 1'b0;
            end
            else begin
                MOSI = 1'b0;  // Default when not transmitting
            end
        endfunction
    endclass
endpackage