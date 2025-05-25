//===================================================================================
// File         : DPHY_LPTX.v
// Author       : Mohamed Ehab
// Date         : April 18, 2025
// Dependencies : counter.v
// Description  : 
//    RTL implementation of the D-PHY Low Power Transmitter (LP-TX) module
//    compliant with MIPI D-PHY v1.2 specifications.
//    
//    This module manages the LP to HS transition and vice versa, using a
//    finite state machine to generate LP sequences: LP-11, LP-01, LP-00
//    based on TxRequestHS signal and predefined timing parameters.
//    
//    States:
//      - TX_STOP      : Idle state driving LP-11
//      - TX_HS_RQST   : LP-01 driven for TLPX interval
//      - TX_HS_PRPR   : LP-00 driven for THS_PREPARE interval
//      - TX_HS_EXIT   : LP-11 (or LP-00) driven for THS_EXIT interval
//
//    Outputs LP_Dp and LP_Dn reflect LP signaling, and HSTX_EN/HSCLK_EN control
//    the transition to/from high-speed data and clock lanes.
//
//=====================================================================================

//=============================== Module Declaration ================================\\
module DPHY_LPTX 
  #(
   parameter LPX_TIME        = 8,
   parameter HSPREPARE_TIME  = 16,
   parameter HSEXIT_TIME     = 24
  )  
  (
    input  wire        LPTX_CLK,
    input  wire        TxRst,
    input  wire        LPTX_EN,
    input  wire        TxRequestHS,
    output reg         LP_Dp,
    output reg         LP_Dn,
    output reg         HSCLK_EN,
    output reg         HSTX_EN
);
 //=============================== Local Variables =====================================\\
 // Counter variables
 wire        counter_done;
 wire [4:0]  count;
 reg         counter_enable;
 reg  [4:0]  counter_max;
  
 // State encoding
 localparam  TX_STOP     = 3'b000,
             TX_HS_RQST  = 3'b001,
             TX_HS_PRPR  = 3'b010,
             TX_HS_EXIT  = 3'b011;

 // Define State registers
 reg [2:0] current_state, next_state;

  
 //=================================== Instantiation =====================================\\
  // Instantiation of internal counter
  counter tx_counter   (.clock(LPTX_CLK),
                        .reset(TxRst),
                        .en(counter_enable),
                        .max_count(counter_max),
                        .done(counter_done),
                        .count(count));
  
  
 //========================== Sequential Logic for State Machine =========================\\  
 always @(posedge LPTX_CLK) begin
     if (TxRst)
         current_state <= TX_STOP;
     else
         current_state <= next_state;
 end

  
 //======================= Combinational Logic for State Machine ==========================\\
 always @(*) begin
     next_state = current_state;
     counter_enable = 1'b0;
     counter_max = 5'h0;
     case (current_state)
         TX_STOP: begin
             if (TxRequestHS && LPTX_EN)
                 next_state = TX_HS_RQST;
         end

         TX_HS_RQST: begin
             counter_enable = 1'b1;
             counter_max = LPX_TIME;
             if (counter_done)
                 next_state = TX_HS_PRPR;
         end

         TX_HS_PRPR: begin
             counter_enable = 1'b1;
             counter_max = HSPREPARE_TIME;
             if (counter_done)
                 next_state = TX_HS_EXIT;
         end

         TX_HS_EXIT: begin
             if (~TxRequestHS)
                 counter_enable = 1'b1;
                 counter_max = HSEXIT_TIME;
                 if(counter_done)
                    next_state = TX_STOP;
         end
     endcase
 end


 //==================================== Output Logic ===========================================\\
 always @(posedge LPTX_CLK) begin
     if (TxRst) begin
         {LP_Dp, LP_Dn} <= 2'b11; // LP-11
         HSTX_EN <= 0;
         HSCLK_EN <= 0;
     end else begin
         case (current_state)
             TX_STOP: begin
                 {LP_Dp, LP_Dn} <= LPTX_EN ? 2'b11 : 2'bzz; // LP-11 or High-Z
                 HSTX_EN  <= 0;
                 HSCLK_EN <= 0;
             end
 
             TX_HS_RQST: begin
                 {LP_Dp, LP_Dn} <= 2'b01; // LP-01
                 HSTX_EN  <= 0;
                 HSCLK_EN <= 0;
             end

             TX_HS_PRPR: begin
                 {LP_Dp, LP_Dn} <= 2'b00; // LP-00
                 HSTX_EN  <= 0;      
                 HSCLK_EN <= 1;     // Enable HS Clock lane
             end

             TX_HS_EXIT: begin
                 {LP_Dp, LP_Dn} <= TxRequestHS ? 2'bzz : 2'b11; // LP-11 for EOT
                 HSTX_EN  <= 1;     // Enable HS Data lane
                 HSCLK_EN <= 0;     
             end
         endcase
     end
 end

endmodule
