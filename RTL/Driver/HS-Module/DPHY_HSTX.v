//===================================================================================
// File         : DPHY_HSTX.v
// Author       : Mohamed Ehab
// Date         : April 24, 2025
// Dependencies : hstx_fsm.v, serializer.v, duel_edge_ff.v
// Description  : 
//    Top-level module for the D-PHY High-Speed Transmitter (HS-TX).
//    Instantiates the HS FSM, serializer, and dual edge flip-flop logic,
//    enabling byte-to-serial conversion and HS signaling compliant with
//    MIPI D-PHY specifications.
//
//===================================================================================

//=============================== Module Declaration ================================\\
module DPHY_HSTX (
    input  wire        TxByteClkHS,
    input  wire        TxDDRClkHS,
    input  wire        TxRst,
    input  wire        TxValid,
    input  wire        SOT,
    input  wire [7:0]  TxByte_Data,
    output wire        HS_Dp,
    output wire        HS_Dn,
    output wire [2:0]  TxState,
    output wire        TxReady
);

  //============================= Internal signals ==========================//
  wire        serial_en;
  wire [7:0]  hsfsm_bytes;
  wire        serial_bit1, serial_bit2;
  
  
  //============================= FSM Instance ===============================//
  hstx_fsm u_fsm (
      .TxDDRClkHS    (TxDDRClkHS),
      .TxRst         (TxRst),
      .SOT           (SOT),        
      .TxValid       (TxValid),
      .TxByte_Data   (TxByte_Data),
      .serial_en     (serial_en),
      .HSFSM_Bytes   (hsfsm_bytes),
      .TxState       (TxState)
  );

  //========================== Serializer Instance ===========================//
  serializer u_serializer (
      .TxByteClkHS   (TxByteClkHS),
      .TxDDRClkHS    (TxDDRClkHS),
      .TxRst         (TxRst),
      .serializer_en (serial_en),
      .TxByteHS_Data (hsfsm_bytes),
      .Serial_Bit1   (serial_bit1),
      .Serial_Bit2   (serial_bit2)
  );

  //================ Dual Edge Flip-Flop Instance ================//
  TX_DuelEdge_ff u_duel_edge_ff (
      .TxDDRClkHS   (TxDDRClkHS),
      .TxRst        (TxRst),
      .deff_en      (serial_en),
      .serial_B1    (serial_bit1),
      .serial_B2    (serial_bit2),
      .MuxOut       (HS_Dp)
  );

  //================ Differential Output =================//
  assign HS_Dn = ~HS_Dp;

  //================ TX Ready Signal =================//
  assign TxReady = (TxState == 3'b011);  // HS_DATA

endmodule
