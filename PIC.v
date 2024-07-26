`timescale 1ns / 1ps



module irr (
    input clk,               // Clock signal
    input reset,             // Reset signal
    input [31:0] irq,         // Interrupt requests from 8 sources (IR0 - IR7)
    input [31:0]isr1,isr2,isr3,isr4,         // In-Service Register indicating currently serviced interrupts
    output reg [31:0] irr     // Interrupt Request Register output
);

    // Internal register to hold the interrupt requests
     reg [31:0] irr2;
    // Always block to update the IRR on clock edge or reset
    always @(posedge clk or posedge reset /*or posedge irr2 posedge irq*/ ) begin
        if (reset) begin
            irr <= 32'd0;
        end else begin
           irr <= irq | irr2;
        end
    end
    always @(*)begin
        irr2 = irr;
        if(isr1 | isr2 | isr3 | isr4)begin
            irr2 = irr2 & isr1 & isr2 & isr3 & isr4;
        end
    end
endmodule

module priority_resolver (
    input clk,reset,
    input [31:0] irr,         // Interrupt Request Register
    input [31:0] imq,         // Interrupt Mask Register
    input [63:0]prio_cnfg,
    output reg [5:0] int_id  // Interrupt ID with the highest priority
);
   // reg [31:0]imr;
    reg [31:0] masked_irr;
    integer i;
    reg [7:0]priority[31:0];
    reg [5:0]id[31:0];
    reg [1:0]prio[31:0];
    reg [7:0] current_max;

  always @(posedge clk) begin
        if(reset)begin
                int_id <= 6'b111111;
                for (i = 0; i < 32; i = i + 1) begin
                      priority[i]<= 2'b00;
                      end
                end   
                else begin
                    for (i = 0; i < 32; i = i + 1) begin
                      prio[i] <= prio_cnfg[2*i +: 2];
                      id[i] <= i;
                      priority[i]<= {prio[i],id[i]};
                end
                      current_max = 8'b00000000;
  
    //    imr = imq;
        masked_irr = irr & imq;
            int_id <= 6'b111111;
        // Check if masked_irr is not all zeros
        if (masked_irr != 32'd0) begin
            // Search for the highest priority interrupt request
            for ( i = 1; i < 32; i = i + 1) begin
                if(masked_irr[i])begin
            if (priority[i] > current_max) begin
                current_max = priority[i];
            end
        end
      end   
      
            int_id <= current_max; 
             
                end
            end
        end
   
  
endmodule 



module isr (
    input clk,
    input reset,
    input int_ack1,int_ack2,int_ack3,int_ack4,
    input [5:0] int_id,
    output reg [31:0] isr1,isr2,isr3,isr4,isr
);


    // Update ISR based on interrupt acknowledgment
      always @(posedge clk or posedge reset) begin
       
        if (reset)begin
            isr1 <= 32'hffffffff;  // Reset ISR to all zeros
            isr2 <= 32'hffffffff;
            isr3 <= 32'hffffffff;
            isr4 <= 32'hffffffff;
            end
         else  begin
            if (int_ack1) begin
                isr1 <= 32'hffffffff;
                isr1[int_id] <= 1'b0;  
            end// Set the corresponding bit for the acknowledged interrupt
            else if (int_ack2) begin
                isr2 <= 32'hffffffff;
                isr2[int_id] <= 1'b0;  
            end 
            if (int_ack3) begin
                isr3 <= 32'hffffffff;
                isr3[int_id] <= 1'b0;  
            end 
            if (int_ack4) begin
                isr4 <= 32'hffffffff;
                isr4[int_id] <= 1'b0;  
            end
            isr = isr1 & isr2 & isr3 & isr4;
        end
    end
   
endmodule

module vector_generator (
input clk,
input reset,
    input [5:0] int_id,       // Interrupt ID from the priority resolver
    output reg [31:0] vector   // Vector address based on interrupt ID
);

    // Assign vector address based on interrupt ID
    always @(posedge clk) begin
    if(reset)
    vector = 32'dz;
    else begin
        case (int_id)
                6'b00000: vector = 32'hffffff00;
                6'b00001: vector = 32'hffffff01;
                6'b00010: vector = 32'hffffff02;
                6'b00011: vector = 32'hffffff03;
                6'b00100: vector = 32'hffffff04;
                6'b00101: vector = 32'hffffff06;
                6'b00110: vector = 32'hffffff06;
                6'b00111: vector = 32'hffffff07;
                6'b01000: vector = 32'hffffff08;
                6'b01001: vector = 32'hffffff09;
                6'b01010: vector = 32'hffffff0a;
                6'b01011: vector = 32'hffffff0b;
                6'b01100: vector = 32'hffffff0c;
                6'b01101: vector = 32'hffffff0d;
                6'b01110: vector = 32'hffffff0e;
                6'b01111: vector = 32'hffffff0f;
                6'b10000: vector = 32'hffffff10;
                6'b10001: vector = 32'hffffff11;
                6'b10010: vector = 32'hffffff12;
                6'b10011: vector = 32'hffffff13;
                6'b10100: vector = 32'hffffff14;
                6'b10101: vector = 32'hffffff15;
                6'b10110: vector = 32'hffffff16;
                6'b10111: vector = 32'hffffff17;
                6'b11000: vector = 32'hffffff18;
                6'b11001: vector = 32'hffffff19;
                6'b11010: vector = 32'hffffff1a;
                6'b11011: vector = 32'hffffff1b;
                6'b11100: vector = 32'hffffff1c;
                6'b11101: vector = 32'hffffff1d;
                6'b11110: vector = 32'hffffff1e;
                6'b11111: vector = 32'hffffff1f;
                default : vector = 32'bz;
        endcase
    end
    end

endmodule



module control_logic (
    input clk,                   // Clock signal
    input [5:0] int_id,  
    input reset,        // Interrupt ID from the priority resolver
    
    output reg int_req1,int_req2,int_req3,int_req4,        // Interrupt request output
    input wire int_ack1,int_ack2,int_ack3,int_ack4      
    
);

    // Control logic for generating interrupt request and transmitting vector address
    always @(*) begin
    if(reset) begin int_req1 <= 0;
                    int_req2 <= 0;
                    int_req3 <= 0;
                    int_req4 <= 0;
                    end
                                        
    else begin
        // Check if there is an interrupt request (int_id != 3'b000) and generate interrupt output accordingly
       if(int_id == 6'bz) begin
            int_req1 <= 1'b0;
            int_req2 <= 1'b0;
            int_req3 <= 1'b0;
            int_req4 <= 1'b0;
            end else
         if (int_id <32 && !int_ack1) begin
            int_req1 <= 1'b1;  // Generate interrupt request
        end else if(int_ack1) begin
            int_req1 <= 1'b0;  // No interrupt request
        end
        
        if (int_id <32 && !int_ack2) begin
            int_req2 <= 1'b1;  // Generate interrupt request
        end else if(int_ack2) begin
            int_req2 <= 1'b0;  // No interrupt request
        end 
        
         if (int_id <32 && !int_ack3) begin
            int_req3 <= 1'b1;  // Generate interrupt request
        end else if(int_ack3) begin
            int_req3 <= 1'b0;  // No interrupt request
        end 
        
         if (int_id <32 && !int_ack4) begin
            int_req4 <= 1'b1;  // Generate interrupt request
        end else if(int_ack4) begin
            int_req4 <= 1'b0;  // No interrupt request
        end 
        
       end 
    
end
endmodule


//mux to select which registrs data to be read
module mux(
    input clk,
    input reset,
    input int_ack1,int_ack2,int_ack3,int_ack4,
    input read,
    input wire [1:0]select,
    input wire [31:0]imr,
    input wire [31:0]irr,
    input wire [31:0]isr,
    input wire [31:0]vector,
    output reg [31:0]outdata1,outdata2,outdata3,outdata4  
    );
always @(posedge clk)
    begin
    if(reset)begin
        outdata1 <= 32'bz;
        outdata2 <= 32'bz;
        outdata3 <= 32'bz;
        outdata4 <= 32'bz;
        end
     else if(int_ack1)
        outdata1 <= vector;
        else if(int_ack2)
        outdata2 <= vector;
        else if(int_ack3)
        outdata3 <= vector;
        else if(int_ack4)
        outdata4 <= vector;
     else if(read)
        begin
            case(select)
            2'b00 : outdata1 <= imr;
            2'b01 : outdata1 <= irr;
            2'b10 : outdata1 <= isr;
            2'b11 : outdata1 <= vector;
            endcase        
         end
      end
   
endmodule

module intrcntrl (
    input clk,               // Clock signal
    input reset,          // Reset signal
    input read,
    input [31:0] irq,         // Interrupt requests from 8 sources (IR0 - IR7)
    input [63:0]prio_cnfg,   //to decide priority levels of each interrupt request
    input int_ack1,int_ack2,int_ack3,int_ack4,           // Interrupt acknowledgment from microprocessor
    output int_req1,int_req2,int_req3,int_req4,          // Interrupt request output to microprocessor
    output [31:0] data_bus1,data_bus2,data_bus3,data_bus4,  // Data bus to transmit vector address to microprocessor
    input wire [1:0]s,       //select lines to select the register whose value is to be read by the processor
    input wire [31:0]imq  //wires to write on mask register
);
    
    wire [31:0] irr;          // Interrupt Request Register
    wire [31:0] isr1,isr2,isr3,isr4,isr;          // In-Service Register
    wire [5:0] int_id;       // Interrupt ID with the highest priority
    wire [31:0] vector;       // Vector address based on interrupt ID
 
    // Instantiate the IRR module
    irr irr_inst (
        .clk(clk),
        .reset(reset),
        .irq(irq),
        .irr(irr),
        .isr1(isr1),
        .isr2(isr2),
        .isr3(isr3),
        .isr4(isr4)
    );

    // Instantiate the priority resolver module
    priority_resolver priority_resolver_inst (
        .irr(irr),
        .imq(imq),
        .int_id(int_id),
        .prio_cnfg(prio_cnfg),
        .clk(clk),
        .reset(reset)
        );

    // Instantiate the ISR module
    isr isr_inst (
        .clk(clk),
        .reset(reset),
        .int_id(int_id),
        .isr1(isr1),
        .isr2(isr2),
        .isr3(isr3),
        .isr4(isr4),
        .isr(isr),
        .int_ack1(int_ack1),
        .int_ack2(int_ack2),
        .int_ack3(int_ack3),
        .int_ack4(int_ack4)
    );

    // Instantiate the vector generator module
    vector_generator vector_generator_inst (
        .clk(clk),
        .reset(reset),
        .int_id(int_id),
        .vector(vector)
    );

    // Instantiate the control logic module
    control_logic control_logic_inst (
        .clk(clk),
        .reset(reset),
        .int_id(int_id),
        .int_req1(int_req1),
        .int_req2(int_req2),
        .int_req3(int_req3),
        .int_req4(int_req4),
        .int_ack1(int_ack1),
        .int_ack2(int_ack2),
        .int_ack3(int_ack3),
        .int_ack4(int_ack4)
        
    );
    
    //instentiating the mux
    mux mux_inst(
         .clk(clk),
         .int_ack1(int_ack1),
         .int_ack2(int_ack2),
         .int_ack3(int_ack3),
         .int_ack4(int_ack4),
         .read(read),
         .reset(reset),
         .imr(imq),
         .isr(isr),
         .irr(irr),
         .vector(vector),
         .select(s),
         .outdata1(data_bus1),
         .outdata2(data_bus2),
         .outdata3(data_bus3),
         .outdata4(data_bus4)
    );
 
endmodule
