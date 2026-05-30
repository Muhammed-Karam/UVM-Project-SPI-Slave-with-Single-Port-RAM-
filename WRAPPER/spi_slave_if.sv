interface spi_slave_if (clk);
    input clk;
    // Inputs to SPI Slave
    logic MOSI;
    logic SS_n;  // Controlled by driver
    logic rst_n;
    logic tx_valid;
    logic [7:0] tx_data;
    // Outputs from SPI Slave
    logic MISO;
    logic [9:0] rx_data;
    logic rx_valid;
    // Golden model outputs for comparison
    logic MISO_golden;
    logic [9:0] rx_data_golden;
    logic rx_valid_golden;
endinterface : spi_slave_if