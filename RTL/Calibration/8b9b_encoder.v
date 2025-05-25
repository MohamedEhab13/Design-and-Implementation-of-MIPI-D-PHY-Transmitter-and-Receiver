//===================================================================================
// File         : encoder_8b9b.v
// Author       : Mohamed Ehab
// Date         : April 29, 2025
// Description  : 
//    RTL implementation of an 8b/9b encoder.
//
//    - Takes an 8-bit input word organized as [B1 B2 B3 X1 X2 Q1 Q2 Q3].
//    - Computes four intermediate parity bits Y1–Y4 based on Q and X bits.
//    - Constructs a 9-bit output code word as [B1 X1 Y1 Y2 B2 B3 Y3 Y4 X2].
//    - Encoding occurs on positive clock edge when 'enable' is high.
//    - Output is reset synchronously with active-low reset signal.
//
//===================================================================================


// 8b9b Encoder Module
module encoder_8b9b (
    input wire clk,
    input wire rst_n,
    input wire enable,
    input wire [7:0] data_in,  // 8-bit input word [B1 B2 B3 X1 X2 Q1 Q2 Q3]
    output reg [8:0] code_out  // 9-bit output code word [B1 X1 Y1 Y2 B2 B3 Y3 Y4 X2]
);

    // Extract individual bits from input data word
    wire B1, B2, B3, X1, X2, Q1, Q2, Q3;
    
    assign B1 = data_in[7];
    assign B2 = data_in[6];
    assign B3 = data_in[5];
    assign X1 = data_in[4];
    assign X2 = data_in[3];
    assign Q1 = data_in[2];
    assign Q2 = data_in[1];
    assign Q3 = data_in[0];
    
    // Calculate Y values based on the equations from the specification
    wire Y1, Y2, Y3, Y4;
   
    assign Y1 = (~Q1 & ~Q2 & ~X1) | (Q1 & Q3) | (Q2 & Q3);
    assign Y2 = (~Q1 & ~Q2 & ~X1) | (Q1 & ~Q3) | (Q2 & ~Q3);
    assign Y3 = (Q1 & ~Q2) | (Q1 & Q2 & ~X2) | (~Q2 & Q3);
    assign Y4 = (~Q1 & Q2) | (Q1 & Q2 & ~X2) | (~Q1 & ~Q3);
    
    // Output code word formation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            code_out <= 9'b0;
        end else if (enable) begin
            code_out <= {B1, X1, Y1, Y2, B2, B3, Y3, Y4, X2};
        end
    end
    
endmodule

