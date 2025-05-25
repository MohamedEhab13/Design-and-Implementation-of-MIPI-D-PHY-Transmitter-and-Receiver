//===================================================================================
// File         : deserializer.v
// Author       : Mohamed Ehab
// Date         : May 2, 2025
// Description  : 
//    8-bit deserializer module for MIPI D-PHY receiver data path.
//
//    - Collects serial input data from dual-edge samplers (Serial_B1 and Serial_B2).
//    - Samples bits alternately on both rising and falling edges of RxDDRClkHS.
//    - Forms an 8-bit word using an internal shift register.
//    - Outputs the full byte on the rising edge of RxByteClkHS once 8 bits are collected.
//    - Controlled by deserializer_en and RxRst (active-high reset).
//
//===================================================================================


module deserializer (
    input wire serial_B1,
    input wire serial_B2,
    input wire RxDDRClkHS,
    input wire RxByteClkHS,
    input wire deserializer_en,
    input wire RxRst,
    output reg [7:0] parallel_out
);

// Internal shift register to collect serial bits
reg [7:0] shift_register;
reg [7:0] temp_reg;
reg [3:0] bit_counter;  // Counter to track how many bits collected (0-7)

// High-speed clock domain - collect serial bits
always @(posedge RxDDRClkHS) begin
    if (RxRst) begin
        shift_register <= 8'hff;
        temp_reg <= 8'hff;
        bit_counter <= 3'b0;
    end else if (deserializer_en) begin
        // Shift in serial_B1 on positive edge
        shift_register <= {shift_register[6:0], serial_B1};
        bit_counter <= bit_counter + 1;
        if(bit_counter == 4'b1000) begin  // counter = 8 
           temp_reg <= shift_register;
           bit_counter <= 1'b1;
        end
    end
end

// Additional collection on negative edge for serial_B2
always @(negedge RxDDRClkHS) begin
    if (RxRst) begin
        shift_register <= 8'hff;
        temp_reg <= 8'hff;
        bit_counter <= 3'b0;
    end else if (deserializer_en) begin
        // Shift in serial_B2 on negative edge
        shift_register <= {shift_register[6:0], serial_B2};
        bit_counter <= bit_counter + 1;
        if(bit_counter == 4'b1000) begin  // counter = 8 
           temp_reg <= shift_register;
           bit_counter <= 1'b1;
        end
    end
end

// Byte clock domain - output parallel data when 8 bits collected
always @(posedge RxByteClkHS) begin
    if (RxRst) begin
        parallel_out <= 8'hff;
    end else if (deserializer_en) begin
        // When bit_counter rolls over from 7 to 0, we have a complete byte
        parallel_out <= temp_reg;
    end
end

endmodule