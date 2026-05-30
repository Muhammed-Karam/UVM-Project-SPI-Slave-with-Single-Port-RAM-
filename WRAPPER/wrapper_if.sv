interface wrapper_if (clk);
    input clk;
    
    // Primary wrapper inputs/outputs
    logic MOSI;
    logic SS_n;
    logic rst_n;
    logic MISO;
    
    // Golden model output
    logic MISO_golden;
    
    // Internal signals for monitoring (from SPI Slave to RAM)
    logic [9:0] rx_data;
    logic rx_valid;
    logic [7:0] tx_data;
    logic tx_valid;
    
    // Internal golden signals for monitoring
    logic [9:0] rx_data_golden;
    logic rx_valid_golden;
    logic [7:0] tx_data_golden;
    logic tx_valid_golden;
    
endinterface : wrapper_if