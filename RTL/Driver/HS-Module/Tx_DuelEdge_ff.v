//===================================================================================
// File         : duel_edge_ff.v
// Author       : Mohamed Ehab
// Date         : April 20, 2025
// Dependencies : None
// Description  : 
//    RTL implementation of a dual-edge flip-flop sampling module used in 
//    MIPI D-PHY High-Speed transmission.
//
//    This module samples two serial data inputs (serial_B1 and serial_B2) on both 
//    rising and falling edges of a DDR clock (TxDDRClkHS). The sampled outputs are 
//    then multiplexed to generate a single serialized output (MuxOut).
//
//    - On the rising edge of TxDDRClkHS, serial_B1 is sampled.
//    - On the falling edge of TxDDRClkHS, serial_B2 is sampled.
//    - The multiplexer selects FF1_Out or FF2_Out based on the current clock edge.
//
//===================================================================================


module TX_DuelEdge_ff (
  input         TxDDRClkHS,
  input         TxRst, 
  input         deff_en,
  input         serial_B1,
  input         serial_B2,
  output        MuxOut
 );
  
  // Flip-Flops Outputs 
  reg FF1_Out, FF2_Out; 
  
  // First Flip-Flop sample at positive-edge DDR clock 
  always@(posedge TxRst, posedge TxDDRClkHS) begin
    if(TxRst || ~deff_en)
      FF1_Out <= 1'b0;
    else if(deff_en) 
      FF1_Out <= serial_B1;
  end
  
  // Second Flip-Flop sample at negative-edge DDR clock 
  always@(posedge TxRst, negedge TxDDRClkHS) begin
    if(TxRst || ~deff_en)
      FF2_Out <= 1'b0;
    else if(deff_en) 
      FF2_Out <= serial_B2;
  end
  
  // Multiplixer to select 1 bit from the two flip-flops 
  assign MuxOut = TxDDRClkHS ? FF1_Out : FF2_Out; 
  
endmodule