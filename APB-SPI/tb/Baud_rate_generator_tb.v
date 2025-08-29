module Baud_rate_generator_tb();
reg PCLK,PRESET_n;
reg [1:0]spi_mode_i;
reg spiswai_i;
reg [2:0] sppr_i,spr_i;
reg cpol_i,cpha_i,ss_i;
wire sclk_o;
wire miso_receive_sclk_o,miso_receive_sclk0_o,
mosi_send_sclk_o,mosi_send_sclk0_o;
wire  [11:0] BaudRateDivisor_o ;

Baud_rate_generator DUT(.PCLK(PCLK),.PRESET_n(PRESET_n),.spi_mode_i(spi_mode_i),
                        .spiswai_i(spiswai_i),.sppr_i(sppr_i),.spr_i(spr_i),
								.cpol_i(cpol_i),.cpha_i(cpha_i),.ss_i(ss_i),.sclk_o(sclk_o),
.miso_receive_sclk_o(miso_receive_sclk_o),.miso_receive_sclk0_o(miso_receive_sclk0_o),
.mosi_send_sclk_o(mosi_send_sclk_o),.mosi_send_sclk0_o(mosi_send_sclk0_o),
.BaudRateDivisor_o(BaudRateDivisor_o));

initial 
begin
PCLK=1'b0;
forever #10 PCLK=~PCLK;
end

task initialize;
begin
{PCLK,spi_mode_i,spiswai_i,sppr_i,spr_i,ss_i}=0;
PRESET_n=1;

{cpol_i,cpha_i}=2'b11;
 
end
endtask

task reset();
begin
PRESET_n=1'b0;
#25 ;
PRESET_n=1'b1;
end
endtask

task one(input[1:0]k,input m,l);
begin
spi_mode_i=k;
spiswai_i=m;
ss_i=l;
end
endtask

task two(input [2:0]r,s,input t,u);
begin
sppr_i=r;
spr_i=s;
cpol_i=t;
cpha_i=u;
end
endtask

initial
begin
initialize;
#10 reset;
#20;
one(2'b00,1'b0,1'b0);
two(3'b000,3'b001,1'b1,1'b1);
#100  one(2'b00,1'b0,1'b0);
two(3'b000,3'b001,1'b0,1'b0);
#100 one(2'b00,1'b0,1'b0);
two(3'b000,3'b001,1'b1,1'b0);
#100 one(2'b00,1'b0,1'b0);
two(3'b000,3'b001,1'b0,1'b1);
end
endmodule



