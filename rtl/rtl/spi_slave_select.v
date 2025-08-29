module spi_slave_select (
    input        PRESET_n,
    input  [1:0] spi_mode_i,
    input        mstr_i,
    input        spiswai_i,
    input        PCLK,
    input        send_data_i,
    input  [11:0] BaudRateDivisor_i,
    output reg   ss_o,
    output reg   receive_data_o,
    output       tip_o
);

    reg [15:0] count_s;
    reg [15:0] target_s;
    reg rcv_s;

    assign tip_o = ~ss_o;

    always @(*) begin
        target_s = (BaudRateDivisor_i/2)*16;
    end

    always @(posedge PCLK or negedge PRESET_n) begin
        if (!PRESET_n) begin
            count_s <= 16'hFFFF;
            ss_o    <= 1'b1;
            rcv_s   <= 1'b0;
        end else if (mstr_i && 
                    ((spi_mode_i == 2'b00) || ((spi_mode_i == 2'b01) && !spiswai_i))) begin
            if (send_data_i) begin
                ss_o    <= 1'b0;
                count_s <= 16'd0;
                //rcv_s   <= 1'b0;
					 rcv_s <= rcv_s;
            end else if (count_s < target_s - 1) begin
                ss_o    <= 1'b0;
                count_s <= count_s + 1;
                if (count_s == target_s - 1)
                    rcv_s <= 1'b1;
            end else begin
                ss_o    <= 1'b1;
                rcv_s   <= 1'b0;
                count_s <= 16'hFFFF;
            end
        end else begin
            ss_o    <= 1'b1;
            rcv_s   <= 1'b0;
            count_s <= 16'hFFFF;
        end
    end

    always @(posedge PCLK or negedge PRESET_n) begin
        if (!PRESET_n)
            receive_data_o <= 1'b0;
        else
            receive_data_o <= rcv_s;
    end

endmodule

