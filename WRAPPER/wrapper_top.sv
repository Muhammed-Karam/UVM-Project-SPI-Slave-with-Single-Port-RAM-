import uvm_pkg::*;
`include "uvm_macros.svh"
import wrapper_test_pkg::*;

module wrapper_top();
    
    bit clk;
    
    // Clock generation
    initial begin
        forever
            #1 clk = ~clk;
    end
    
    // Instantiate all three interfaces
    wrapper_if wrapper_if_inst(clk);
    spi_slave_if spi_if_inst(clk);
    ram_if ram_if_inst(clk);
    
    // DUT instantiation (SPI Wrapper)
    WRAPPER DUT(
        .clk(clk),
        .rst_n(wrapper_if_inst.rst_n),
        .SS_n(wrapper_if_inst.SS_n),
        .MOSI(wrapper_if_inst.MOSI),
        .MISO(wrapper_if_inst.MISO)
    );
    
    // Golden model instantiation
    WRAPPER_golden GOLDEN(
        .clk(clk),
        .rst_n(wrapper_if_inst.rst_n),
        .SS_n(wrapper_if_inst.SS_n),
        .MOSI(wrapper_if_inst.MOSI),
        .MISO(wrapper_if_inst.MISO_golden)
    );

    // Connect internal signals from DUT to wrapper interface
    assign wrapper_if_inst.rx_data = DUT.rx_data_din;
    assign wrapper_if_inst.rx_valid = DUT.rx_valid;
    assign wrapper_if_inst.tx_data = DUT.tx_data_dout;
    assign wrapper_if_inst.tx_valid = DUT.tx_valid;
    
    // Connect internal signals from Golden to wrapper interface
    assign wrapper_if_inst.rx_data_golden = GOLDEN.rx_data_din;
    assign wrapper_if_inst.rx_valid_golden = GOLDEN.rx_valid;
    assign wrapper_if_inst.tx_data_golden = GOLDEN.tx_data_dout;
    assign wrapper_if_inst.tx_valid_golden = GOLDEN.tx_valid;
    
    // Connect SPI slave interface to internal signals for passive monitoring
    assign spi_if_inst.rst_n = wrapper_if_inst.rst_n;
    assign spi_if_inst.SS_n = wrapper_if_inst.SS_n;
    assign spi_if_inst.MOSI = wrapper_if_inst.MOSI;
    assign spi_if_inst.MISO = DUT.MISO;
    assign spi_if_inst.rx_data = DUT.rx_data_din;
    assign spi_if_inst.rx_valid = DUT.rx_valid;
    assign spi_if_inst.tx_data = DUT.tx_data_dout;
    assign spi_if_inst.tx_valid = DUT.tx_valid;
    assign spi_if_inst.MISO_golden = GOLDEN.MISO;
    assign spi_if_inst.rx_data_golden = GOLDEN.rx_data_din;
    assign spi_if_inst.rx_valid_golden = GOLDEN.rx_valid;
    
    // Connect RAM interface to internal signals for passive monitoring
    assign ram_if_inst.rst_n = wrapper_if_inst.rst_n;
    assign ram_if_inst.din = DUT.rx_data_din;
    assign ram_if_inst.rx_valid = DUT.rx_valid;
    assign ram_if_inst.dout = DUT.tx_data_dout;
    assign ram_if_inst.tx_valid = DUT.tx_valid;
    assign ram_if_inst.dout_golden = GOLDEN.tx_data_dout;
    assign ram_if_inst.tx_valid_golden = GOLDEN.tx_valid;
    
    // Bind assertions to DUT modules
    bind WRAPPER wrapper_sva wrapper_sva_inst(
        .clk(clk),
        .rst_n(rst_n),
        .SS_n(SS_n),
        .MOSI(MOSI),
        .MISO(MISO)
    );
    
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
    
    bind RAM ram_sva ram_sva_inst(
        .clk(clk),
        .rst_n(rst_n),
        .rx_valid(rx_valid),
        .din(din),
        .dout(dout),
        .tx_valid(tx_valid)
    );
    
    // UVM configuration
    initial begin
        uvm_config_db#(virtual wrapper_if)::set(null, "uvm_test_top", "wrapper_IF", wrapper_if_inst);
        uvm_config_db#(virtual spi_slave_if)::set(null, "uvm_test_top", "spi_slave_IF", spi_if_inst);
        uvm_config_db#(virtual ram_if)::set(null, "uvm_test_top", "ram_IF", ram_if_inst);
        run_test("wrapper_test");
    end
    
endmodule