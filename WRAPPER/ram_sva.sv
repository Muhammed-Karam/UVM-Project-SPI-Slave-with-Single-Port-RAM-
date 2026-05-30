module ram_sva(
    input clk, rst_n, rx_valid,
    input [9:0] din,
    input [7:0] dout,
    input tx_valid
);

    // Command sequences
    sequence write_addr_seq;
        (rx_valid && din[9:8] == 2'b00);
    endsequence
    
    sequence write_data_seq;
        (rx_valid && din[9:8] == 2'b01);
    endsequence
    
    sequence read_addr_seq;
        (rx_valid && din[9:8] == 2'b10);
    endsequence
    
    sequence read_data_seq;
        (rx_valid && din[9:8] == 2'b11);
    endsequence

    // Reset ensures outputs are low
    property reset_outputs_low;
        @(posedge clk) (!rst_n) |=> (tx_valid == 0 && dout == 0);
    endproperty

    // tx_valid remains deasserted during write_addr, write_data, and read_addr
    property tx_valid_low_during_addr_data;
        @(posedge clk) disable iff(!rst_n)
        (write_addr_seq or write_data_seq or read_addr_seq) |=> (tx_valid == 0);
    endproperty

    // After read_data, tx_valid rises and eventually falls
    property tx_valid_rise_fall_after_read_data;
        @(posedge clk) disable iff(!rst_n)
        (read_data_seq) |-> ##1 (tx_valid == 1) ##1 (!tx_valid[->1]);
    endproperty

    // Every Write Address must be eventually followed by Write Data
    property write_addr_eventually_write_data;
        @(posedge clk) disable iff(!rst_n)
        (write_addr_seq) |-> ##[1:$] (write_data_seq);
    endproperty

    // Every Read Address must be eventually followed by Read Data
    property read_addr_eventually_read_data;
        @(posedge clk) disable iff(!rst_n)
        (read_addr_seq) |-> ##[1:$] (read_data_seq);
    endproperty

    // Assert properties
    assert_reset_outputs: assert property (reset_outputs_low)
        else $error("Reset assertion failed: outputs not low during reset");
    
    assert_tx_valid_low: assert property (tx_valid_low_during_addr_data)
        else $error("tx_valid should be low during address/data phases");
    
    assert_tx_valid_toggle: assert property (tx_valid_rise_fall_after_read_data)
        else $error("tx_valid should rise after read_data and eventually fall");
    
    assert_write_sequence: assert property (write_addr_eventually_write_data)
        else $error("Write Address should be followed by Write Data");
    
    assert_read_sequence: assert property (read_addr_eventually_read_data)
        else $error("Read Address should be followed by Read Data");

    // Cover properties
    cover_reset_outputs: cover property (reset_outputs_low);
    cover_tx_valid_low: cover property (tx_valid_low_during_addr_data);
    cover_tx_valid_toggle: cover property (tx_valid_rise_fall_after_read_data);
    cover_write_sequence: cover property (write_addr_eventually_write_data);
    cover_read_sequence: cover property (read_addr_eventually_read_data);

endmodule