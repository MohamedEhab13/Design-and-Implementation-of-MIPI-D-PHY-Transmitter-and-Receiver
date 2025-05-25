//===================================================================================
// File         : PRBS_9.v
// Author       : Mohamed Ehab
// Date         : April 28, 2025
// Description  : 
//    RTL implementation of PRBS-9 (Pseudo Random Bit Sequence) Generator.
//
//    - Uses a 9-bit Linear Feedback Shift Register (LFSR).
//    - Feedback taps at bit positions 5 and 9 (XOR of lfsr[8] and lfsr[4]).
//    - Initial seed set to 9'b011111111 to avoid all-zeros state.
//    - Outputs an 8-bit PRBS pattern.
//
//===================================================================================

//=========================== Module Declaration ===========================\\
module PRBS_9 (
 input  wire       Clk, 
 input  wire       TxRst,
 input  wire       Enable,
 output wire [7:0] PRBS_Pattern
 );
  
//========================= Internal Signals ================================\\
reg [8:0] lfsr;
wire feedback;

//========================= Feedback Calculation ============================\\
assign feedback = lfsr[8] ^ lfsr[4];  // XOR taps at bit 9 and bit 5

//========================= PRBS Shift Register ==============================\\
  always @(posedge Clk or posedge TxRst) begin
    if (TxRst)
        lfsr <= 9'b011111111;  // Non-zero initial seed
    else if (Enable)
      lfsr <= {lfsr[7:0], feedback};  // Shift right and insert feedback
end 

//========================= Output Assignment ================================\\
  genvar i;
generate
  for (i = 0; i < 8; i = i + 1) begin
    assign PRBS_Pattern[i] = lfsr[7 - i];
  end
endgenerate


endmodule

  
  