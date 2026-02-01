//transmitter - info related to transmitter end

module uartT(input clk,
input reset,
input [8:1]data_in,
input transfer,
output reg transfering,
output reg data_out,
output baud_tick,
output reg[3:0]inte);
reg[1:0]i;
reg baud;
always @(posedge clk)begin
    if(reset)
    begin
        i<=0;
        baud<=0;
    end
    else begin
if(i==2'd3)begin
    baud<=1;
    i<=2'd0;
end
else begin
    i<=i+2'd1;
    baud<=0;
end

end
end
always @(posedge clk or posedge reset) begin
    if(transfer)
transfering<=1;
else begin
    
end
    if(reset)
    begin
     inte<=0;data_out<=1;transfering<=0;
    end
    else if(baud)
    begin
      if(transfering)
      begin 
        if(inte==0&&data_out==1)begin
            data_out<=0;    
            end
        else if(inte<4'd8)
        begin 
            inte=inte+4'd1; 
            data_out=data_in[inte]; 
        
        end
        else 
        begin // 9 is the stop num. 
        data_out<=1; inte<=9;// inte will become 0 again when reset is on so that next new msg will go.
        transfering<=0;
        end
        end
        else begin
            data_out<=1;
        end
    end
    else begin   inte<=inte;end
end
assign baud_tick=baud;
endmodule


//receiver - this contains info related to receiver end


module uartR(input data_in,
input clk,
input reset,
input baud,
output reg active,
output reg [7:0]data_out,
output reg received,
output baud_tick
);
reg [3:0]i;
reg[1:0]j;
assign baud_tick=baud;

always @(posedge clk)
begin
    if(reset)
    begin
        data_out<=8'd0;
        active<=0;i<=0;
        received<=0;
       
    end
    else begin
        if(baud)begin
        if(data_in==0&&active==0)
        active<=1;
        else if(active)
        begin
            if(i!=8)begin data_out[i]<=data_in;
            i<=i+3'd1;end
            else begin
                if(i==8&&data_in==1)begin
             active<=0; received<=1; i<=i+1; end
             else if(i==8&&data_in==0) begin
                active<=0;received<=0;i<=i+1;end
                else begin 
                    i<=0;
                    active<=0;
                end 
                end
                end 
                else begin
        
        end  
            end
        end
        end
endmodule


//mixi- this joins both of the above so that , transmitter output is connected receiver input.


module mixI(input clk,
    input reset,
    input transfer,
    input [8:1] data_in,
    output dataT,
    output baud1,
    output [7:0] dataR,
    output received);
wire[7:0]x;
wire y;
wire fakebaud;  
assign baud1=fakebaud;
assign dataR=x;
assign dataT=y;
uartT DUT1(
    .clk(clk),
    .reset(reset),
    .data_in(data_in),
    .transfer(transfer),
    .data_out(y),
    .baud_tick(fakebaud)
    );
uartR DUT2(
    .clk(clk),
    .reset(reset),
    .baud(fakebaud),
    .data_in(y),
    .data_out(x),
    .received(received));

endmodule

