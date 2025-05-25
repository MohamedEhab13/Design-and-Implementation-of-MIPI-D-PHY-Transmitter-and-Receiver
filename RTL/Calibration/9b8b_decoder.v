//===================================================================================
// File         : decoder_9b8b.v
// Author       : Mohamed Ehab
// Date         : April 29, 2025
// Description  : 
//    RTL implementation of a 9b/8b decoder.
//
//    - Accepts a 9-bit encoded input word [B1 X1 Y1 Y2 B2 B3 Y3 Y4 X2].
//    - Reconstructs the original 8-bit word [B1 B2 B3 X1 X2 Q1 Q2 Q3].
//    - Derives Q1–Q3 from the Y bits using logical equations.
//    - Decoding occurs on the rising edge of clk when 'enable' is high.
//    - Output is reset synchronously using active-low reset.
//
//===================================================================================


// 9b8b Decoder Module
module decoder_9b8b (
    input wire clk,
    input wire rst_n,
    input wire enable,
    input wire [8:0] code_in,  // 9-bit input code word [B1 X1 Y1 Y2 B2 B3 Y3 Y4 X2]
    output reg [7:0] data_out  // 8-bit output decoded word [B1 B2 B3 X1 X2 Q1 Q2 Q3]
);

    // Extract individual bits from input code word
    wire B1, X1, Y1, Y2, B2, B3, Y3, Y4, X2;
    
    assign B1 = code_in[8];
    assign X1 = code_in[7];
    assign Y1 = code_in[6];
    assign Y2 = code_in[5];
    assign B2 = code_in[4];
    assign B3 = code_in[3];
    assign Y3 = code_in[2];
    assign Y4 = code_in[1];
    assign X2 = code_in[0];
    
    // Calculate Q values based on the equations from the specification
    wire Q1, Q2, Q3;
    
    assign Q1 = (Y1 ^ Y2) & ~(~Y3 & Y4);
    assign Q2 = (Y1 ^ Y2) & ~(Y3 & ~Y4);
    assign Q3 = (Y1 & ~Y2) | (~(Y1 ^ Y2) & Y3);
    
    // Output decoded word formation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= 8'b0;
        end else if (enable) begin
            data_out <= {B1, B2, B3, X1, X2, Q1, Q2, Q3};
        end
    end
    
endmodule