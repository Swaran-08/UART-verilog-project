`timescale 1ns/1ps

module uart_tb;

    reg clk;
    reg rst;
    reg wr_en;
    reg rdy_clr;
    reg [7:0] data_in;

    wire tx;
    wire rx;
    wire busy;
    wire rdy;
    wire [7:0] data_out;

    assign rx = tx;   // loopback: transmitter connected to receiver

    uart_top dut(
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rdy_clr(rdy_clr),
        .data_in(data_in),
        .rx(rx),
        .tx(tx),
        .busy(busy),
        .rdy(rdy),
        .data_out(data_out)
    );

    always #10 clk = ~clk;   // 50 MHz clock

    task send_data;
        input [7:0] value;
        begin
            wait(busy == 0);

            @(negedge clk);
            data_in = value;
            wr_en = 1'b1;

            @(negedge clk);
            wr_en = 1'b0;

            wait(rdy == 1'b1);

            $display("Received data = %h", data_out);

            @(negedge clk);
            rdy_clr = 1'b1;

            @(negedge clk);
            rdy_clr = 1'b0;
        end
    endtask

    initial begin
        $dumpfile("uart_tb.vcd");
        $dumpvars(0, uart_tb);

        clk = 0;
        rst = 1;
        wr_en = 0;
        rdy_clr = 0;
        data_in = 8'h00;

        #200;
        rst = 0;

        send_data(8'h55);
        send_data(8'hA3);
        send_data(8'h0D);

        #100000;
        $finish;
    end

endmodule
