import uvm_pkg::*;
`include "uvm_macros.svh"
import spi_slave_test_pkg::*;

module spi_slave_top();
    
    bit clk;
    
    // Clock generation
    initial begin
        forever
            #1 clk = ~clk;
    end
    
    // Interface instantiation
    spi_slave_if spi_if(clk);
    
    // DUT instantiation
    SLAVE DUT(
        .clk(clk),
        .rst_n(spi_if.rst_n),
        .SS_n(spi_if.SS_n),
        .MOSI(spi_if.MOSI),
        .tx_valid(spi_if.tx_valid),
        .tx_data(spi_if.tx_data),
        .MISO(spi_if.MISO),
        .rx_valid(spi_if.rx_valid),
        .rx_data(spi_if.rx_data)
    );
    
    // Golden model instantiation
    SPI_slave_golden GOLDEN(
        .clk(clk),
        .rst_n(spi_if.rst_n),
        .SS_n(spi_if.SS_n),
        .MOSI(spi_if.MOSI),
        .tx_valid(spi_if.tx_valid),
        .tx_data(spi_if.tx_data),
        .MISO(spi_if.MISO_golden),
        .rx_valid(spi_if.rx_valid_golden),
        .rx_data(spi_if.rx_data_golden)
    );
    
    // Bind assertions to DUT
    bind SLAVE spi_slave_sva spi_sva_inst(
        .clk(clk),
        .rst_n(rst_n),
        .SS_n(SS_n),
        .MOSI(MOSI),
        .tx_valid(tx_valid),
        .tx_data(tx_data),
        .MISO(MISO),
        .rx_valid(rx_valid),
        .rx_data(rx_data)
    );
    
    // UVM configuration
    initial begin
        uvm_config_db#(virtual spi_slave_if)::set(null, "uvm_test_top", "spi_slave_IF", spi_if);
        run_test("spi_slave_test");
    end
    
endmodule