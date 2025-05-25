//===================================================================================
// File         : DPHY_HSRX.v
// Author       : Mohamed Ehab
// Date         : May 6, 2025
// Description  : 
//    Top-level module for MIPI D-PHY High-Speed Receiver (HSRX).
//
//    - Integrates core submodules for high-speed reception:
//         * Dual-edge sampling flip-flop (RX_DuelEdge_ff)
//         * Deserializer for byte alignment
//         * FSM controller for D-PHY state sequencing (hsrx_fsm)
//         * Sync pattern detector (sync_detector)
//    - Operates across dual clock domains: RxDDRClkHS (bit-level) and RxByteClkHS (byte-level)
//    - Outputs valid byte-aligned high-speed data (RxDataHS) with control flags.
//
//===================================================================================


//=============================== Module Declaration ================================\\
module DPHY_HSRX (
    input  wire        RxByteClkHS,
    input  wire        RxDDRClkHS,
    input  wire        RxRst,
    input  wire        HSRX_EN,    
    input  wire        HS_Dp,
    output wire [2:0]  RxState,
    output wire [7:0]  RxDataHS,
    output wire [3:0]  RxSyncPosition,
    output wire        RxActiveHS,
    output wire        RxSyncHS,
    output wire        RxValidHS
);

  //============================= Internal signals ==========================//
  wire       serial_b1, serial_b2;
  wire [7:0] deserializer_out; 
  wire [7:0] RxByteHS;
  wire       SyncDetect, Zero_Detect;
  wire       dueledgeff_enable, deserializer_enable;
 

  
  
  //============================= FSM Instance ===============================//
  hsrx_fsm u_fsm (
      .RxDDRClkHS      (RxDDRClkHS),
      .RxRst           (RxRst),
      .SyncDetected    (SyncDetect),        
      .HSRX_EN         (HSRX_EN),
      .Zero_Detected   (Zero_Detect),
      .RxByte_HS       (deserializer_out),
      .dueledge_ff_en  (dueledgeff_enable),
      .deserializer_en (deserializer_enable),        
      .HSFSM_Bytes     (RxDataHS),
      .RxState         (RxState),
      .RxActiveHS      (RxActiveHS),
      .RxSyncHS        (RxSyncHS),
      .RxValidHS       (RxValidHS)
  );

  //========================== De-Serializer Instance ===========================//
  deserializer u_deserializer (
    .serial_B1       (serial_b1),
    .serial_B2       (serial_b2),
    .RxDDRClkHS      (RxDDRClkHS),
    .RxByteClkHS     (RxByteClkHS),
    .deserializer_en (deserializer_enable),
    .RxRst           (RxRst),
    .parallel_out    (deserializer_out)
  );

  //================ Dual Edge Flip-Flop Instance ================//
  RX_DuelEdge_ff u_duel_edge_ff (
    .serial_in       (HS_Dp),
    .RxDDRClkHS      (RxDDRClkHS),
    .RxRst           (RxRst),
    .deff_en         (dueledgeff_enable),
    .Serial_B1       (serial_b1),
    .Serial_B2       (serial_b2)
  );

  //================ Sync Detector Instance ================//
  sync_detector u_sync_detector (
    .RxByteClkHS      (RxByteClkHS), 
    .Rst              (RxRst),
    .DataHS           (deserializer_out),
    .Enable           (deserializer_enable), 
    .Zero_Detected    (Zero_Detect),
    .RxSyncPosition   (RxSyncPosition),       
    .RxSyncHS         (SyncDetect)
  );
  

endmodule
