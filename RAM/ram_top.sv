import uvm_pkg::*;
`include "uvm_macros.svh"
import ram_test_pkg::*;

module ram_top();
    
    bit clk;
    
    // Clock generation
    initial begin
        forever
            #1 clk = ~clk;
    end
    
    // Interface instantiation
    ram_if ram_if_inst(clk);
    
    // DUT instantiation
    RAM DUT(
        .clk(clk),
        .rst_n(ram_if_inst.rst_n),
        .rx_valid(ram_if_inst.rx_valid),
        .din(ram_if_inst.din),
        .dout(ram_if_inst.dout),
        .tx_valid(ram_if_inst.tx_valid)
    );
    
    // Golden model instantiation
    RAM_golden GOLDEN(
        .clk(clk),
        .rst_n(ram_if_inst.rst_n),
        .rx_valid(ram_if_inst.rx_valid),
        .din(ram_if_inst.din),
        .dout(ram_if_inst.dout_golden),
        .tx_valid(ram_if_inst.tx_valid_golden)
    );
    
    // Bind assertions to DUT
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
        uvm_config_db#(virtual ram_if)::set(null, "uvm_test_top", "ram_IF", ram_if_inst);
        run_test("ram_test");
    end
    
endmodule