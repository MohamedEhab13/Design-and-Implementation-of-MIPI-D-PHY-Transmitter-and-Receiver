//===================================================================================
// File         : serializer.v
// Author       : Mohamed Ehab
// Date         : April 20, 2025
// Dependencies : None
// Description  : 
//    RTL implementation of an 8-bit to 2-bit serializer used in MIPI D-PHY 
//    High-Speed transmission.
//
//    This module splits an 8-bit parallel input into odd and even bit groups,
//    and serializes them onto two parallel output lines (Serial_Bit1 and 
//    Serial_Bit2) using a DDR (Double Data Rate) clock.
//
//    The 8-bit data is sampled on the rising edge of TxByteClkHS and stored 
//    into separate even and odd registers. On every rising edge of TxDDRClkHS,
//    the bits are serialized 2 bits at a time.
//
//    - Serial_Bit1 transmits odd bits: {D7, D5, D3, D1}
//    - Serial_Bit2 transmits even bits: {D6, D4, D2, D0}
//
//===================================================================================


module serializer (
    input wire        TxByteClkHS,
    input wire        TxDDRClkHS,
    input wire        TxRst,
    input wire        serializer_en,
    input wire [7:0]  TxByteHS_Data,
    output reg        Serial_Bit1,
    output reg        Serial_Bit2
);

  reg [3:0] even_reg, odd_reg;
  reg [1:0] count;
  reg       sync_enable; // Synchronize between Byte clock and DDR clock 
  

  // Load even & odd bits on Byte Clock
  always @(posedge TxByteClkHS or posedge TxRst) begin
      sync_enable <= serializer_en ? 1'b1 : 1'b0 ;
      if (TxRst || ~serializer_en) begin
          even_reg <= 4'b0;
          odd_reg  <= 4'b0;
      end else if (serializer_en) begin
          even_reg <= {TxByteHS_Data[6], TxByteHS_Data[4], TxByteHS_Data[2], TxByteHS_Data[0]};
          odd_reg  <= {TxByteHS_Data[7], TxByteHS_Data[5], TxByteHS_Data[3], TxByteHS_Data[1]};
      end
  end
  


  // Serialization on DDR clock
  always @(posedge TxDDRClkHS or posedge TxRst) begin
      if (TxRst || ~serializer_en) begin
          count <= 2'b00;
          Serial_Bit1 <= 1'b0;
          Serial_Bit2 <= 1'b0;
      end else if (serializer_en && sync_enable) begin
          Serial_Bit1 <= odd_reg[count];   // MSB of the 2-bit pair
          Serial_Bit2 <= even_reg[count];  // LSB of the 2-bit pair
          count <= count + 1;
      end
  end

endmodule
