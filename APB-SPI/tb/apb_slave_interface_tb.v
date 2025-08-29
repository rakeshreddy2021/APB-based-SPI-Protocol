

module apb_slave_interface_tb();

    // Testbench signals
    reg         PCLK;
    reg         PRESET_n;
    reg         PSEL_i;
    reg         PENABLE_i;
    reg         PWRITE_i;
	 reg         tip_i; 
    reg  [2:0]  PADDR_i;
    reg  [7:0]  PWDATA_i;
    wire [7:0]  PRDATA_o;
    wire        PREADY_o;
    wire        PSLVERR_o;

    // Instantiate DUT
    apb_slave_interface dut (
        .PCLK(PCLK),
        .PRESET_n(PRESET_n),
        .PSEL_i(PSEL_i),
        .PENABLE_i(PENABLE_i),
        .PWRITE_i(PWRITE_i),
        .PADDR_i(PADDR_i),
        .PWDATA_i(PWDATA_i),
        .PRDATA_o(PRDATA_o),
        .PREADY_o(PREADY_o),
        .PSLVERR_o(PSLVERR_o),
		  .tip_i(tip_i)
    );

    // Clock generation (10ns period)
    always #5 PCLK = ~PCLK;

    // APB write task
    task apb_write(input [2:0] addr, input [7:0] data);
    begin
        @(posedge PCLK);
        PSEL_i    = 1;
        PWRITE_i  = 1;
        PENABLE_i = 0;
        PADDR_i   = addr;
        PWDATA_i  = data;
		  tip_i =1;
        @(posedge PCLK);
        PENABLE_i = 1;  // Access phase
        @(posedge PCLK);
        PSEL_i    = 0;
        PENABLE_i = 0;
    end
    endtask

    // APB read task
    task apb_read(input [2:0] addr);
    begin
        @(posedge PCLK);
        PSEL_i    = 1;
        PWRITE_i  = 0;
        PENABLE_i = 0;
        PADDR_i   = addr;
        @(posedge PCLK);
        PENABLE_i = 1;  // Access phase
        @(posedge PCLK);
        PSEL_i    = 0;
        PENABLE_i = 0;
		  #5;
		  $display("Read Addr %0d => Data = %b", addr, PRDATA_o);
    end
    endtask

    // Test sequence
    initial begin
        // Init
        PCLK      = 0;
        PRESET_n  = 0;
        PSEL_i    = 0;
        PENABLE_i = 0;
        PWRITE_i  = 0;
        PADDR_i   = 0;
        PWDATA_i  = 0;

        // Reset release
        #20 PRESET_n = 1;

        // Write and Read Back
        apb_write(3'b000, 8'hA5);  // Write 0xA5 to register 0
        apb_read(3'b000);          // Read back

        apb_write(3'b001, 8'h3C);  // Write 0x3C to register 1
        apb_read(3'b001);

        apb_write(3'b010, 8'hFF);  // Write 0xFF to register 2
        apb_read(3'b010);

        #20;
        $finish;
    end

endmodule





