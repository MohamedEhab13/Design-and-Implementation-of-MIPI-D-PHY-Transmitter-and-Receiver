//===================================================================================
// File         : DPHY_LPRX.v
// Author       : Mohamed Ehab
// Date         : May 5, 2025
// Description  : 
//    Low-Power Receiver FSM for MIPI D-PHY Protocol
//
//    - Monitors LP line states (LP_Dp/LP_Dn) to detect request to enter
//      High-Speed (HS) mode.
//    - Handles transition through RX_HS_RQST → RX_HS_PRPR → RX_HS_TERM → RX_HS_EXIT.
//    - Enables HSRX_EN when HS entry is complete and valid.
//
// Parameters:
//    - D_TERM_EN_TIME : Counter wait time before HS termination (LP-00 detection).
//    - HS_SETTLE_TIME : Wait time to ensure HS signals have settled.
//
// Inputs:
//    - LPRX_CLK   : Clock signal for LP FSM.
//    - RxRst      : Active-high reset.
//    - LPEnable   : Enables LP FSM logic.
//    - LP_Dp      : LP line D+.
//    - LP_Dn      : LP line D-.
//
// Outputs:
//    - HSRX_EN    : High when HS mode is ready.
//
//===================================================================================


//=============================== Module Declaration ================================\\
module DPHY_LPRX 
  #(
    parameter D_TERM_EN_TIME = 6,
    parameter HS_SETTLE_TIME = 14
  )  
  (
    input  wire        LPRX_CLK,
    input  wire        RxRst,
    input  wire        LPEnable,
    input  wire        LP_Dp,
    input  wire        LP_Dn,
    output reg         HSRX_EN
);
 //=============================== Local Variables =====================================\\
 // Counter variables
 wire        counter_done;
 wire [4:0]  count;
 reg         counter_enable;
 reg  [4:0]  counter_max;
  
 // State encoding
 localparam  RX_STOP     = 3'b000,
             RX_HS_RQST  = 3'b001,
             RX_HS_PRPR  = 3'b010,
             RX_HS_TERM  = 3'b011,
             RX_HS_EXIT  = 3'b100;

 // Define State registers
 reg [2:0] current_state, next_state;

  
 //=================================== Instantiation =====================================\\
  // Instantiation of internal counter
  counter tx_counter   (.clock(LPRX_CLK),
                        .reset(RxRst),
                        .en(counter_enable),
                        .max_count(counter_max),
                        .done(counter_done),
                        .count(count));
  
  
 //========================== Sequential Logic for State Machine =========================\\  
 always @(posedge LPRX_CLK) begin
     if (RxRst)
         current_state <= RX_STOP;
     else
         current_state <= next_state;
 end

  
 //======================= Combinational Logic for State Machine ==========================\\
 always @(*) begin
     next_state = current_state;
     counter_enable = 1'b0;
     counter_max = 5'h0;
     case (current_state)
         RX_STOP: begin
           if (LP_Dp == 1 && LP_Dn == 1) // LP-11
               next_state = RX_STOP;
           else if(LP_Dp == 0 && LP_Dn == 1) // LP-01
               next_state = RX_HS_RQST;
         end
       
         RX_HS_RQST: begin
            if (LP_Dp == 0 && LP_Dn == 0) // LP-00
               next_state = RX_HS_PRPR;
         end

         RX_HS_PRPR: begin
             counter_enable = 1'b1;
             counter_max = D_TERM_EN_TIME;
             if (counter_done)
                 next_state = RX_HS_TERM;
         end
       
         RX_HS_TERM: begin
             counter_enable = 1'b1;
             counter_max = HS_SETTLE_TIME;
             if (counter_done)
                 next_state = RX_HS_EXIT;
         end

         RX_HS_EXIT: begin
             if (LP_Dp == 1 && LP_Dn == 1) // LP-11
               next_state = RX_STOP;
         end
     endcase
 end


 //==================================== Output Logic ===========================================\\
 always @(posedge LPRX_CLK) begin
     if (RxRst) begin  
         HSRX_EN <= 0;
     end else if (LPEnable) begin
         case (current_state)
             RX_STOP: begin
                 HSRX_EN <= 0;
             end
 
             RX_HS_RQST: begin
                 HSRX_EN <= 0;
             end

             RX_HS_PRPR: begin
                 HSRX_EN <= 0;
             end

             RX_HS_EXIT: begin
                 HSRX_EN <= 1;     
             end
         endcase
     end
 end

endmodule
