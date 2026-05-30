module wrapper_sva(
    input clk, rst_n,
    input MOSI, SS_n,
    input MISO
);

    // Assertion 1: Whenever reset is asserted, MISO is inactive (low)
    property reset_miso_low;
        @(posedge clk) (!rst_n) |=> (MISO == 0);
    endproperty

    // Assertion 2: MISO remains stable eventually as long as it's not a read data operation
    // Read data sequence: SS_n falls, then 3 bits = 111
    
    // Non-read sequences
    sequence write_addr_seq;
        $fell(SS_n) ##0 (MOSI == 0) ##1 (MOSI == 0) ##1 (MOSI == 0);
    endsequence
    
    sequence write_data_seq;
        $fell(SS_n) ##0 (MOSI == 0) ##1 (MOSI == 0) ##1 (MOSI == 1);
    endsequence
    
    sequence read_add_seq;
        $fell(SS_n) ##0 (MOSI == 1) ##1 (MOSI == 1) ##1 (MOSI == 0);
    endsequence

    // MISO should remain stable during non-read-data operations
    property miso_stable_non_read_data;
        @(posedge clk) disable iff(!rst_n)
        (write_addr_seq or write_data_seq or read_add_seq) |-> ##[1:$] $stable(MISO);
    endproperty

    // Assert properties
    assert_reset_miso: assert property (reset_miso_low)
        else $error("Reset assertion failed: MISO not low during reset");
    
    assert_miso_stable: assert property (miso_stable_non_read_data)
        else $error("MISO should remain stable during non-read-data operations");

    // Cover properties
    cover_reset_miso: cover property (reset_miso_low);
    cover_miso_stable: cover property (miso_stable_non_read_data);

endmodule