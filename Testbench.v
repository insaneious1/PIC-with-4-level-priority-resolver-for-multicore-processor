`timescale 1ns / 1ps

module tb_intrcntrl;

    // Parameters
    parameter CLK_PERIOD = 20; // Clock period in ns

    // Signals
    reg clk = 0;               // Clock signal
    reg reset;             // Reset signal
    reg read = 0;             // Read/Write control signal
    reg int_ack1 = 0;           // Interrupt acknowledgment from microprocessor
    reg int_ack2 = 0;
    reg int_ack3 = 0;
    reg int_ack4 = 0;
    reg [63:0]prio_cnfg;
    reg [31:0] irq = 32'b0;  // Interrupt requests from 8 sources (IR0 - IR7)
    reg [1:0] s = 2'b00;       // Select lines to select the register whose value is to be read by the processor
    reg [31:0] imq = 32'b0; // Data to write on mask register
    wire int_req1;              // Interrupt request output to microprocessor
    wire int_req2;
    wire int_req3;
    wire int_req4;
    wire [31:0] data_bus1;       // Data bus to transmit vector address to microprocessor
    wire [31:0] data_bus2;
    wire [31:0] data_bus3;
    wire [31:0] data_bus4;
    
    

    // Instantiate the intrcntrl module
    intrcntrl intrcntrl_inst (
        .clk(clk),
        .reset(reset),
        .read(read),
        .irq(irq),
        .prio_cnfg(prio_cnfg),
        .int_ack1(int_ack1),
        .int_ack2(int_ack2),
        .int_ack3(int_ack3),
        .int_ack4(int_ack4),
        .int_req1(int_req1),
        .int_req2(int_req2),
        .int_req3(int_req3),
        .int_req4(int_req4),
        .data_bus1(data_bus1),
        .data_bus2(data_bus2),
        .data_bus3(data_bus3),
        .data_bus4(data_bus4),
        .s(s),
        .imq(imq)
    );
        
    // Clock generation
    always #((CLK_PERIOD / 2)) clk = ~clk;

   initial begin
        // Test case 1: Write to mask register and acknowledge interrupt
        reset = 1;prio_cnfg = 64'b1100000000000000000000000000000000100000000010000111000000011011;
        #200 reset = 0;
        irq = 32'b10000000000000000110011011001111;//(31,14,13,10,9,7,6,3,2,1,0)
        imq = 32'b11111111111111111111111111110110;  //(3)
        repeat(3)
        @(posedge clk);
        int_ack1 = 1; irq = 32'b00000000000000000110011011001111; //31 served
        @(posedge clk);
        int_ack1 = 0;
        repeat(3)
        @(posedge clk);
        int_ack2 = 1; irq = 32'b00000000000000000110011010001111; //6 served
        @(posedge clk);
        int_ack2 = 0;
        repeat(3)
        @(posedge clk);
        int_ack1 = 1; irq = 32'b00000000000000000110011010001110; //0 served
        @(posedge clk);
        int_ack1 = 0;
        repeat(3)
        @(posedge clk);
        int_ack4 = 1; irq = 32'b00000000000000000010011010001110; //14 served
        @(posedge clk);
        int_ack4 = 0;
        repeat(3)
        @(posedge clk);
        int_ack3 = 1; irq = 32'b00000000000000000010010010001110;  //9 served
        @(posedge clk);
        int_ack3 = 0;
        repeat(3)
        @(posedge clk);
        int_ack2 = 1; irq = 32'b00000000000000000010010010001100;  //1 served
        @(posedge clk);
        int_ack2 = 0;
         repeat(3)
        @(posedge clk);
        int_ack4 = 1; irq = 32'b00000000000000000010010000001100;  //7 served
        @(posedge clk);
        int_ack4 = 0;
        repeat(3)
        @(posedge clk);
        int_ack1 = 1; irq = 32'b00000000000000000010010000001000;  //2 served
        @(posedge clk);
        int_ack1 = 0;
        repeat(3)
        @(posedge clk);
        int_ack2 = 1; irq = 32'b00000000000000000000010000001000;  //13 served
        @(posedge clk);
        int_ack2 = 0;
        repeat(3)
        @(posedge clk);
        int_ack3 = 1; irq = 32'b00000000000000000000000000001000;  //10 served
        @(posedge clk);
        int_ack3 = 0;
        repeat(3)
        @(posedge clk);
        int_ack4 = 1; irq = 32'b00000000000000000000000000000000;  //3 served
        @(posedge clk);
        int_ack4 = 0;
        # 50 $finish;
    
       
        
        
    end

endmodule
