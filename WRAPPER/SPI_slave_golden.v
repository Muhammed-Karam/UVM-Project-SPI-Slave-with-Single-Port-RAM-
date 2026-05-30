module SPI_slave_golden(
                 clk, rst_n, SS_n, MOSI, tx_valid, tx_data,
                 MISO, rx_valid, rx_data
                );

    // States
    parameter IDLE      = 3'b000;
    parameter CHK_CMD   = 3'b001;
    parameter WRITE     = 3'b010;
    parameter READ_ADD  = 3'b011;
    parameter READ_DATA = 3'b100;

    input clk;
    input rst_n;
    input SS_n;
    input MOSI;
    input tx_valid;
    input [7:0] tx_data;

    output reg MISO;
    output reg rx_valid;
    output reg [9:0] rx_data;

    reg read_addr_received; // To track if read address received                 
    reg [4:0] counter; // Counts bits for receive/transmission

    (* fsm_encoding = "gray" *)
    reg [2:0] cs, ns; // Current and next state

    // State memory
    always @(posedge clk) begin
        if (~rst_n) 
            cs <= IDLE;
        else
            cs <= ns;
    end

    // Next state logic
    always @(*) begin
        case (cs)
            IDLE : begin
                if (SS_n) 
                    ns = IDLE;
                else 
                    ns = CHK_CMD;
            end
            CHK_CMD: begin
                if (SS_n)
                    ns = IDLE;                                                     
                else begin
                    if (MOSI) begin
                        if (read_addr_received) 
                            ns = READ_DATA;
                        else
                            ns = READ_ADD;
                    end
                    else
                        ns = WRITE;
                end
            end
            WRITE : begin
                    if (SS_n)
                        ns = IDLE;
                    else 
                        ns = WRITE;
            end
            READ_ADD : begin
                    if (SS_n) 
                        ns = IDLE;
                    else
                        ns = READ_ADD;
            end
            READ_DATA : begin
                    if (SS_n)
                        ns = IDLE;
                    else
                        ns = READ_DATA;
            end

            // default : ns = IDLE;
        endcase
    end

    // Output logic
    always @(posedge clk) begin
        if (~rst_n) begin
            rx_data <= 0;
            rx_valid <= 0;
            counter <= 0;
            MISO <= 0;
            read_addr_received <= 0;
        end

        else if (cs == IDLE) begin    
            rx_valid <= 0;
        end
        else if (cs == CHK_CMD) begin    
            counter <= 10;
        end


        else if ((cs == WRITE) || (cs == READ_ADD)) begin

            if (counter > 0) begin
                rx_data[counter-1] <= MOSI;
                counter <= counter - 1;
            end
            else begin
                rx_valid <= 1;
                if (cs == READ_ADD)
                    read_addr_received <= 1;
            end
        end

        else if (cs == READ_DATA) begin   
            if (tx_valid) begin
                if (counter > 0) begin
                    MISO <= tx_data[counter-1];
                    counter <= counter - 1;
                end
                else begin
                    read_addr_received <= 0;
                    rx_valid <= 0;
                end
            end
            else begin
                if (counter > 0) begin
                    rx_data[counter-1] <= MOSI;
                    counter <= counter - 1;
                end
                else begin
                    rx_valid <= 1;
                    counter <= 9;
                end
            end
        end

        else begin
            rx_valid <= 0;
        end
    end

endmodule