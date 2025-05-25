//===================================================================================
// File         : RX_DuelEdge_ff.v
// Author       : Mohamed Ehab
// Date         : May 1, 2025
// Description  : 
//    Dual-edge data sampling flip-flop module for MIPI D-PHY Receiver.
//
//    - Captures serial input data on both rising and falling edges of RxDDRClkHS.
//    - Generates two sampled outputs: 
//         * Serial_B1 on the rising edge
//         * Serial_B2 on the falling edge
//    - Controlled by deff_en (dual-edge FF enable) and RxRst (active-high reset).
//
//===================================================================================


module RX_DuelEdge_ff (
    input wire serial_in,
    input wire RxDDRClkHS,
    input wire RxRst,
    input wire deff_en,
    output reg Serial_B1,
    output reg Serial_B2
);

// Positive edge triggered flip-flop for Serial_B1
always @(posedge RxDDRClkHS) begin
    if (RxRst) begin
        Serial_B1 <= 1'b0;
    end else if (deff_en) begin
        Serial_B1 <= serial_in;
    end
end

// Negative edge triggered flip-flop for Serial_B2
always @(negedge RxDDRClkHS) begin
    if (RxRst) begin
        Serial_B2 <= 1'b0;
    end else if (deff_en) begin
        Serial_B2 <= serial_in;
    end
end

endmodule