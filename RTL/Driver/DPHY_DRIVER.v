//====================================================================================
// File         : DPHY_DRIVER.v
// Author       : Mohamed Ehab
// Date         : April 27, 2025
// Dependencies : DPHY_HSTX.v, DPHY_LPTX.v
// Description  : 
//    D-PHY Driver module that manages Low Power (LP) and High Speed (HS) transmission 
//    by instantiating DPHY_HSTX and DPHY_LPTX submodules.
//    
//    - DPHY_HSTX handles High Speed data transmission.
//    - DPHY_LPTX handles Low Power state transitions (LP-11, LP-01, LP-00).
//    
//    A 2x1 multiplexer selects between HS and LP signals based on the SOT (Start Of Transmission) signal.
//
//====================================================================================


//=============================== Module Declaration ================================\\
module DPHY_DRIVER #(
   parameter LPX_TIME        = 8,
   parameter HSPREPARE_TIME  = 16,
   parameter HSEXIT_TIME     = 24
  ) 
 
  (
    input  wire        TxDDRClkHS_I,
    input  wire        TxByteClkHS,
    input  wire        TxLP_Clk,
    input  wire        TxRst,
    input  wire        TxValidHS,
    input  wire        TxRequestHS,
    input  wire [7:0]  TxDataHS,
    input  wire        TxLP_Enable,
    output wire        TxDp,
    output wire        TxDn,
    output wire        TxClk_Enable,
    output wire [2:0]  DphyTxState,
    output wire        TxReadyHS
);
  
  
  //=============================== Internal signals ==============================//
  wire        SOT;
  wire        HS_Dp, HS_Dn;
  wire        LP_Dp, LP_Dn;
  
  
  
  //============================= DPHY_HSTX Instance ===============================//
  DPHY_HSTX HSTX_inst(
      .TxByteClkHS   (TxByteClkHS),
      .TxDDRClkHS    (TxDDRClkHS_I),
      .TxRst         (TxRst),
      .TxValid       (TxValidHS),
      .SOT           (SOT),  
      .TxByte_Data   (TxDataHS),
      .HS_Dp         (HS_Dp),
      .HS_Dn         (HS_Dn),
      .TxState       (DphyTxState),
      .TxReady       (TxReadyHS)
  );
  
  
  //============================= DPHY_LPTX Instance ===============================//
  DPHY_LPTX #(
    .LPX_TIME        (LPX_TIME),
    .HSPREPARE_TIME  (HSPREPARE_TIME),
    .HSEXIT_TIME     (HSEXIT_TIME)
    )
     LPTX_inst (
       .LPTX_CLK     (TxLP_Clk),
       .TxRst        (TxRst),
       .LPTX_EN      (TxLP_Enable),
       .TxRequestHS  (TxRequestHS),
       .LP_Dp        (LP_Dp),
       .LP_Dn        (LP_Dn),
       .HSCLK_EN     (TxClk_Enable),
       .HSTX_EN      (SOT)
  );
  
  //=============================== Multiplexer ===================================//
  assign Tx_Dp = SOT ? HS_Dp : LP_Dp;
  assign Tx_Dn = SOT ? HS_Dn : LP_Dn;
      
  
  
endmodule

