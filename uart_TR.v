`timescale 1ns/1ps

module baud_generator(
    input clk,
    input rst,
    output reg tx_enb,
    output reg rx_enb
);

    // For simulation:
    // clk frequency = 50 MHz
    // baud rate     = 1 Mbps
    //
    // counter_tx = 50 MHz / 1 MHz = 50
    // counter_rx = 50 MHz / (1 MHz * 16) = around 3

    reg [5:0] counter_tx;  // enough for 50
    reg [1:0] counter_rx;  // enough for 3

    always @(posedge clk) begin
        if (rst) begin
            counter_tx <= 0;
            tx_enb <= 0;
        end
        else begin
            if (counter_tx == 6'd49) begin
                counter_tx <= 0;
                tx_enb <= 1'b1;
            end
            else begin
                counter_tx <= counter_tx + 1'b1;
                tx_enb <= 1'b0;
            end
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            counter_rx <= 0;
            rx_enb <= 0;
        end
        else begin
            if (counter_rx == 2'd2) begin
                counter_rx <= 0;
                rx_enb <= 1'b1;
            end
            else begin
                counter_rx <= counter_rx + 1'b1;
                rx_enb <= 1'b0;
            end
        end
    end

endmodule
`timescale 1ns/1ps

module uart_transmitter(
    input clk,
    input rst,
    input tx_enb,
    input wr_en,
    input [7:0] data_in,
    output reg tx,
    output busy
);

    parameter idle_state  = 2'b00;
    parameter start_state = 2'b01;
    parameter data_state  = 2'b10;
    parameter stop_state  = 2'b11;

    reg [7:0] data;
    reg [2:0] index;
    reg [1:0] state;

    assign busy = (state != idle_state);

    always @(posedge clk) begin
        if (rst) begin
            tx <= 1'b1;
            state <= idle_state;
            data <= 8'b0;
            index <= 3'b0;
        end
        else begin
            case (state)

                idle_state: begin
                    tx <= 1'b1;

                    if (wr_en) begin
                        state <= start_state;
                        data <= data_in;
                        index <= 3'b0;
                    end
                    else begin
                        state <= idle_state;
                    end
                end

                start_state: begin
                    if (tx_enb) begin
                        tx <= 1'b0;
                        state <= data_state;
                    end
                    else begin
                        state <= start_state;
                    end
                end

                data_state: begin
                    if (tx_enb) begin
                        tx <= data[index];

                        if (index == 3'd7) begin
                            state <= stop_state;
                            index <= 3'b0;
                        end
                        else begin
                            index <= index + 1'b1;
                        end
                    end
                end

                stop_state: begin
                    if (tx_enb) begin
                        tx <= 1'b1;
                        state <= idle_state;
                    end
                end

                default: begin
                    tx <= 1'b1;
                    state <= idle_state;
                end

            endcase
        end
    end

endmodule
`timescale 1ns/1ps

module uart_receiver(
    input clk,
    input rst,
    input rx,
    input rx_enb,
    input rdy_clr,
    output reg rdy,
    output reg [7:0] data_out
);

    parameter start_state    = 2'b00;
    parameter data_out_state = 2'b01;
    parameter stop_state     = 2'b10;

    reg [1:0] state;
    reg [3:0] sample;
    reg [2:0] index;
    reg [7:0] temp_register;

    always @(posedge clk) begin
        if (rst) begin
            state <= start_state;
            sample <= 0;
            index <= 0;
            temp_register <= 0;
            data_out <= 0;
            rdy <= 0;
        end
        else begin
            if (rdy_clr) begin
                rdy <= 1'b0;
            end

            if (rx_enb) begin
                case (state)

                    start_state: begin
                        if (rx == 1'b0) begin
                            if (sample == 4'd7) begin
                                sample <= 0;
                                index <= 0;
                                temp_register <= 0;
                                state <= data_out_state;
                            end
                            else begin
                                sample <= sample + 1'b1;
                            end
                        end
                        else begin
                            sample <= 0;
                            state <= start_state;
                        end
                    end

                    data_out_state: begin
                        // Middle of bit time: sample the rx value safely
                        if (sample == 4'd8) begin
                            temp_register[index] <= rx;
                        end

                        // End of bit time: move to next bit
                        if (sample == 4'd15) begin
                            sample <= 0;

                            if (index == 3'd7) begin
                                index <= 0;
                                state <= stop_state;
                            end
                            else begin
                                index <= index + 1'b1;
                            end
                        end
                        else begin
                            sample <= sample + 1'b1;
                        end
                    end

                    stop_state: begin
                        // Middle of stop bit: check stop bit is high
                        if (sample == 4'd8) begin
                            if (rx == 1'b0) begin
                                rdy <= 1'b0;
                            end
                        end

                        // End of stop bit: now update final output only once
                        if (sample == 4'd15) begin
                            sample <= 0;
                            data_out <= temp_register;
                            rdy <= 1'b1;
                            state <= start_state;
                        end
                        else begin
                            sample <= sample + 1'b1;
                        end
                    end

                    default: begin
                        state <= start_state;
                        sample <= 0;
                        index <= 0;
                    end

                endcase
            end
        end
    end

endmodule
`timescale 1ns/1ps

module uart_top(
    input clk,
    input rst,
    input wr_en,
    input rdy_clr,
    input [7:0] data_in,
    input rx,
    output tx,
    output busy,
    output rdy,
    output [7:0] data_out
);

    wire tx_enb;
    wire rx_enb;

    baud_generator baud_inst(
        .clk(clk),
        .rst(rst),
        .tx_enb(tx_enb),
        .rx_enb(rx_enb)
    );

    uart_transmitter tx_inst(
        .clk(clk),
        .rst(rst),
        .tx_enb(tx_enb),
        .wr_en(wr_en),
        .data_in(data_in),
        .tx(tx),
        .busy(busy)
    );

    uart_receiver rx_inst(
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .rx_enb(rx_enb),
        .rdy_clr(rdy_clr),
        .rdy(rdy),
        .data_out(data_out)
    );

endmodule
