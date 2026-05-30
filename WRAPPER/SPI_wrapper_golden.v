module WRAPPER_golden (MOSI, MISO, SS_n, clk, rst_n);

input  MOSI, SS_n, clk, rst_n;
output MISO;

wire [9:0] rx_data_din;
wire       rx_valid;
wire       tx_valid;
wire [7:0] tx_data_dout;

RAM_golden RAM_golden_instance (
    .clk(clk),
    .rst_n(rst_n),
    .rx_valid(rx_valid),
    .din(rx_data_din),
    .dout(tx_data_dout),
    .tx_valid(tx_valid)
);

SPI_slave_golden SLAVE_golden_instance (
    .clk(clk),
    .rst_n(rst_n),
    .SS_n(SS_n),
    .MOSI(MOSI),
    .tx_valid(tx_valid),
    .tx_data(tx_data_dout),
    .MISO(MISO),
    .rx_valid(rx_valid),
    .rx_data(rx_data_din)
);

endmodule