module testuart;
reg clk, reset,transfer;
reg [8:1]data_in;
wire baud_tick;
wire dataT,received;
wire[7:0]dataR;
mixI DUT1(
      .clk(clk),
      .reset(reset),
      .data_in(data_in),
      .dataT(dataT),
      .dataR(dataR),
      .transfer(transfer),
      .received(received),
      .baud1(baud_tick));
initial begin
    $dumpfile("uartTR.vcd");
    $dumpvars(0,testuart);
    reset=1;clk=0;
    @(posedge clk)
    data_in=8'b10010011;
    @(posedge clk)
    reset=0;transfer=1;
    #250;// to transfer another input , just reset and continue the same process.
    reset=1;transfer=0;
    #5;reset=0;transfer=1;
    data_in=8'b11110011;
    #250;
    $finish;
end
always #2 clk =~clk;
always @(posedge clk)begin
 if(baud_tick)   
    $display("T=%0t ,data=%0b,DATA=%0h",$time,dataT,dataR);
end
endmodule