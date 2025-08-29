module spi_slave_select_tb();
    reg        PRESET_n;
    reg  [1:0] spi_mode_i;
    reg        mstr_i;
    reg        spiswai_i;
    reg        PCLK;
    reg        send_data_i;
    reg  [11:0] BaudRateDivisor_i;
    wire   ss_o;
    wire   receive_data_o;
    wire       tip_o;
	 
spi_slave_select DUT(.spi_mode_i(spi_mode_i),
							.PRESET_n(PRESET_n),
							.mstr_i(mstr_i),
							.spiswai_i(spiswai_i),
							.PCLK( PCLK),
							.send_data_i(send_data_i),
							.BaudRateDivisor_i(BaudRateDivisor_i),
							.ss_o(ss_o),
							.receive_data_o(receive_data_o),
                     .tip_o(tip_o));



task initialize;
begin
 {spi_mode_i,mstr_i,spiswai_i,send_data_i, BaudRateDivisor_i}=0;							 
end
endtask

initial 
begin
PCLK=1'b0;
forever #10 PCLK=~PCLK;
end

task reset();
begin
PRESET_n=1'b0;
#25 ;
PRESET_n=1'b1;
end
endtask

task data(input[1:0]i,input[11:0]j,input k,l,m);
begin
    spi_mode_i=i;
	 BaudRateDivisor_i=j;
    mstr_i=k;
    spiswai_i=l;
    send_data_i=m;
	 
end
endtask

initial 
begin
reset;
initialize;

 data(2'b00,16'd4,1'b1,1'b0,1'b1);

#10 data(2'b00,16'd4,1'b1,1'b0,1'b0);

end
endmodule							 
