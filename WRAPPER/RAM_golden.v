// Single Port Synchronous RAM
module RAM_golden (clk, rst_n, rx_valid, din, tx_valid, dout);

    parameter MEM_DEPTH = 256;
    parameter ADDR_SIZE = 8;

    input clk, rst_n, rx_valid;
    input [9:0] din;

    output reg tx_valid;
    output reg [7:0] dout;

    reg [ADDR_SIZE-1:0] write_addr, read_addr;
    reg [7:0] mem [MEM_DEPTH-1:0];

    always @(posedge clk) begin

        if (~rst_n) begin
            dout <= 0;
            tx_valid <= 0;
            write_addr <= 0;
            read_addr <= 0;
        end

        else begin
            tx_valid <= 0; // Default value

            if (rx_valid) begin
                case (din[9:8]) // Check Command bits
                    2'b00 : write_addr <= din[7:0];                            
                    2'b01 : mem[write_addr] <= din[7:0];
                    2'b10 : read_addr <= din[7:0];
                    2'b11 : begin
                            dout <= mem[read_addr];
                            tx_valid <= 1;
                    end 
                    default : dout <= 0;        
                endcase
            end
            
        end
    end
endmodule