module spi_slave_sva(
    input clk, rst_n,
    input MOSI, SS_n, tx_valid,
    input [7:0] tx_data,
    input [9:0] rx_data,
    input rx_valid, MISO
);

    // Write Address sequence: SS_n falls, then 3 bits = 000
    sequence write_addr_seq;
        $fell(SS_n) ##0 (MOSI == 0) ##1 (MOSI == 0) ##1 (MOSI == 0);
    endsequence
    
    // Write Data sequence: SS_n falls, then 3 bits = 001
    sequence write_data_seq;
        $fell(SS_n) ##0 (MOSI == 0) ##1 (MOSI == 0) ##1 (MOSI == 1);
    endsequence
    
    // Read Address sequence: SS_n falls, then 3 bits = 110
    sequence read_add_seq;
        $fell(SS_n) ##0 (MOSI == 1) ##1 (MOSI == 1) ##1 (MOSI == 0);
    endsequence
    
    // Read Data sequence: SS_n falls, then 3 bits = 111
    sequence read_data_seq;
        $fell(SS_n) ##0 (MOSI == 1) ##1 (MOSI == 1) ##1 (MOSI == 1);
    endsequence

    property reset_a;
        @(posedge clk) (!rst_n) |=> (rx_valid == 0 && rx_data == 0 && MISO == 0 )
    endproperty

    property chck_rx_valid_a;
        @(posedge clk) disable iff(!rst_n)
            (write_addr_seq or write_data_seq or read_add_seq or read_data_seq) 
            |-> ##10 ($rose(rx_valid) && $rose(SS_n)[->1]);
    endproperty

    assert property (reset_a);
    assert property (chck_rx_valid_a);
    cover property (reset_a);
    cover property (chck_rx_valid_a);

endmodule