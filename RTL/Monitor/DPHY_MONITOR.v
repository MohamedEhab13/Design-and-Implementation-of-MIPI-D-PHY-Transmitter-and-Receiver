//===================================================================================
// File         : DPHY_MONITOR.v
// Author       : Mohamed Ehab
// Date         : May 7, 2025
// Description  : 
//    Top-level D-PHY Receiver Module for MIPI Interface.
//
//    - Integrates High-Speed (HS) and Low-Power (LP) receiver modules.
//    - Uses LP FSM to control HS receiver enable (HSRX_EN).
//    - Routes D+ and D- line signals to appropriate receiver module
//      based on current operation mode.
//
// Inputs:
//    - RxDDRClkHS     : DDR clock for sampling high-speed data.
//    - RxByteClkHS    : Byte clock derived from DDR clock.
//    - LPRX_CLK       : Clock for LP receiver FSM.
//    - RxRst          : Active-high synchronous reset.
//    - Rx_Dp, Rx_Dn   : Serial differential input lines.
//    - LPEnable       : Enables LP FSM operation.
//
// Outputs:
//    - RxState        : FSM state of HS receiver.
//    - RxDataHS       : Output HS parallel data (8-bit).
//    - RxSyncPosition : Indicates byte position of sync pattern.
//    - RxActiveHS     : Indicates HS data transmission is ongoing.
//    - RxSyncHS       : Indicates sync pattern detection.
//    - RxValidHS      : Valid data indication from HS receiver.
//
//===================================================================================



//=============================== Module Declaration ================================\\
module DPHY_MONITOR 
  (
    input  wire        RxDDRClkHS,
    input  wire        RxByteClkHS,
    input  wire        LPRX_CLK,
    input  wire        RxRst,
    input  wire        Rx_Dp,
    input  wire        Rx_Dn,   
    input  wire        LPEnable,
    output wire [2:0]  RxState,
    output wire [7:0]  RxDataHS,
    output wire [3:0]  RxSyncPosition,
    output wire        RxActiveHS,
    output wire        RxSyncHS,
    output wire        RxValidHS
);
  
  
  //=============================== Internal signals ==============================//
  wire        HSRX_en;
  wire        HS_Dp;
  wire        LP_Dp, LP_Dn;
  
  
  
  //============================= DPHY_HSTX Instance ===============================//
  DPHY_HSRX HSRX_inst(
      .RxByteClkHS    (RxByteClkHS),
      .RxDDRClkHS     (RxDDRClkHS),
      .RxRst          (RxRst),
      .HSRX_EN        (HSRX_en),    
      .HS_Dp          (HS_Dp),
      .RxState        (RxState), 
      .RxDataHS       (RxDataHS),
      .RxSyncPosition (RxSyncPosition),
      .RxActiveHS     (RxActiveHS),     
      .RxSyncHS       (RxSyncHS),
      .RxValidHS      (RxValidHS)
  );
  
  
  //============================= DPHY_LPTX Instance ===============================//
  DPHY_LPRX LPTX_inst (
      .LPRX_CLK      (LPRX_CLK),
      .RxRst         (RxRst),
      .LPEnable      (LPEnable),
      .LP_Dp         (LP_Dp),
      .LP_Dn         (LP_Dn),
      .HSRX_EN       (HSRX_en)
  );
  
  //=============================== Multiplexer ===================================//
  assign HS_Dp = HSRX_en ? Rx_Dp : 1'bz;
  assign LP_Dp = HSRX_en ? 1'bz : Rx_Dp;
  assign LP_Dn = HSRX_en ? 1'bz : Rx_Dn;
      
  
  
endmodule

