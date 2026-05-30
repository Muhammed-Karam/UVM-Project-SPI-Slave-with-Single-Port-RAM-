module SLAVE (MOSI,MISO,SS_n,clk,rst_n,rx_data,rx_valid,tx_data,tx_valid);

localparam IDLE      = 3'b000;
localparam WRITE     = 3'b001;
localparam CHK_CMD   = 3'b010;
localparam READ_ADD  = 3'b011;
localparam READ_DATA = 3'b100;

input            MOSI, clk, rst_n, SS_n, tx_valid;
input      [7:0] tx_data;
output reg [9:0] rx_data;
output reg       rx_valid, MISO;

reg [3:0] counter;
reg       received_address;

reg [2:0] cs, ns;

always @(posedge clk) begin
    if (~rst_n) begin
        cs <= IDLE;
    end
    else begin
        cs <= ns;
    end
end

always @(*) begin
    case (cs)
        IDLE : begin
            if (SS_n)
                ns = IDLE;
            else
                ns = CHK_CMD;
        end
        CHK_CMD : begin
            if (SS_n)
                ns = IDLE;
            else begin
                if (~MOSI)
                    ns = WRITE;
                else begin
                    if (received_address) 
                        ns = READ_DATA; // bug fixed
                    else
                        ns = READ_ADD; // bug fixed
                end
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
    endcase
end

always @(posedge clk) begin
    if (~rst_n) begin 
        rx_data <= 0;
        rx_valid <= 0;
        received_address <= 0;
        counter <= 0; //
        MISO <= 0;
    end
    else begin
        case (cs)
            IDLE : begin
                rx_valid <= 0;
            end
            CHK_CMD : begin
                counter <= 10;      
            end
            WRITE : begin
                if (counter > 0) begin
                    rx_data[counter-1] <= MOSI;
                    counter <= counter - 1;
                end
                else begin
                    rx_valid <= 1;
                end
            end
            READ_ADD : begin
                if (counter > 0) begin
                    rx_data[counter-1] <= MOSI;
                    counter <= counter - 1;
                end
                else begin
                    rx_valid <= 1;
                    received_address <= 1;
                end
            end
            READ_DATA : begin
                if (tx_valid) begin
                    if (counter > 0) begin
                        MISO <= tx_data[counter-1];
                        counter <= counter - 1;
                    end
                    else begin
                        received_address <= 0;
                        rx_valid <= 0; //
                    end
                end
                else begin
                    if (counter > 0) begin
                        rx_data[counter-1] <= MOSI;
                        counter <= counter - 1;
                    end
                    else begin
                        rx_valid <= 1;
                        counter <= 9; //
                    end
                end
            end
        endcase
    end
end

`ifdef SIM

    property idle_to_chk_cmd;
        @(posedge clk) disable iff (!rst_n)
        (cs == IDLE && !SS_n) |=> (cs == CHK_CMD);
    endproperty

    property chk_cmd_to_write;
        @(posedge clk) disable iff (!rst_n)
        (cs == CHK_CMD && !SS_n && !MOSI) |=> (cs == WRITE);
    endproperty

    property chk_cmd_to_read_add;
        @(posedge clk) disable iff (!rst_n)
        (cs == CHK_CMD && !SS_n && MOSI && !received_address) |=> (cs == READ_ADD);
    endproperty

    property chk_cmd_to_read_data;
        @(posedge clk) disable iff (!rst_n)
        (cs == CHK_CMD && !SS_n && MOSI && received_address) |=> (cs == READ_DATA);
    endproperty

    property write_to_idle;
        @(posedge clk) disable iff (!rst_n)
        (cs == WRITE && SS_n) |=> (cs == IDLE);
    endproperty

    property read_add_to_idle;
        @(posedge clk) disable iff (!rst_n)
        (cs == READ_ADD && SS_n) |=> (cs == IDLE);
    endproperty

    property read_data_to_idle;
        @(posedge clk) disable iff (!rst_n)
        (cs == READ_DATA && SS_n) |=> (cs == IDLE);
    endproperty

    a_idle_to_chk_cmd: assert property (idle_to_chk_cmd);
    a_chk_cmd_to_write: assert property (chk_cmd_to_write);
    a_chk_cmd_to_read_add: assert property (chk_cmd_to_read_add);
    a_chk_cmd_to_read_data: assert property (chk_cmd_to_read_data);
    a_write_to_idle: assert property (write_to_idle);
    a_read_add_to_idle: assert property (read_add_to_idle);
    a_read_data_to_idle: assert property (read_data_to_idle);

    c_idle_to_chk_cmd: cover property (idle_to_chk_cmd);
    c_chk_cmd_to_write: cover property (chk_cmd_to_write);
    c_chk_cmd_to_read_add: cover property (chk_cmd_to_read_add);
    c_chk_cmd_to_read_data: cover property (chk_cmd_to_read_data);
    c_write_to_idle: cover property (write_to_idle);
    c_read_add_to_idle: cover property (read_add_to_idle);
    c_read_data_to_idle: cover property (read_data_to_idle);

`endif
endmodule