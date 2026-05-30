interface ram_if (clk);
    input clk;
    
    // Inputs to RAM
    logic [9:0] din;
    logic rst_n;
    logic rx_valid;
    // Outputs from RAM
    logic [7:0] dout;
    logic tx_valid;
    // Golden model outputs for comparison
    logic [7:0] dout_golden;
    logic tx_valid_golden;
    
endinterface : ram_if