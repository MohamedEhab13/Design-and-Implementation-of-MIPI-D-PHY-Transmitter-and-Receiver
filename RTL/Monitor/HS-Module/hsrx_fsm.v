//===================================================================================
// File         : hsrx_fsm.v
// Author       : Mohamed Ehab
// Date         : May 3, 2025
// Description  : 
//    Finite State Machine (FSM) for High-Speed Receiver (HSRX) in a MIPI D-PHY 
//    Receiver design.
//
//    - Handles four main states: STOP, TERMINATE, SYNC, DATA.
//    - Waits for line activity (HSRX_EN) and valid synchronization patterns
//      (Zero_Detected followed by SyncDetected).
//    - Controls enabling of dual-edge sampling flip-flops and deserializer.
//    - Provides synchronized output byte (HSFSM_Bytes) and control/status signals:
//         - RxActiveHS : Indicates HS data transmission is active.
//         - RxSyncHS   : Indicates sync pattern detection.
//         - RxValidHS  : Indicates valid data byte is available.
//
// Parameters:
//    - HSZERO_TIME  : Time duration for HS Zero condition (not used in current FSM).
//    - HSTRAIL_TIME : Time duration for HS Trail condition (not used in current FSM).
//
//===================================================================================


//================================== Module Declaration ==================================\\
module hsrx_fsm 
  #(
   parameter HSZERO_TIME     = 8'h0A,
   parameter HSTRAIL_TIME    = 8'h0F 
  )  
  (
    input  wire        RxDDRClkHS,
    input  wire        RxRst,
    input  wire        SyncDetected,
    input  wire        HSRX_EN,
    input  wire        Zero_Detected,
    input  wire [7:0]  RxByte_HS,
    output reg         dueledge_ff_en,
    output reg         deserializer_en,
    output reg  [7:0]  HSFSM_Bytes,
    output reg  [2:0]  RxState,    
    output reg         RxActiveHS,
    output reg         RxSyncHS,
    output reg         RxValidHS
);
  
  //================================= Local Variables =====================================\\
  // Counter signals
  wire        counter_done;
  wire [4:0]  count;
  reg         counter_enable;
  reg  [4:0]  counter_max;
  
  // State encoding 
  localparam RX_HS_STOP   = 3'b000;
  localparam RX_HS_TERM   = 3'b001; 
  localparam RX_HS_SYNC   = 3'b010;
  localparam RX_HS_DATA   = 3'b011;

  // Define State registers
  reg [2:0] current_state, next_state;
    
  
  //========================== Sequential Logic for State Machine =========================\\  
  always @(posedge RxDDRClkHS) begin
      if (RxRst)
          current_state <= RX_HS_STOP;
      else
          current_state <= next_state;
  end
  
  
   //======================= Combinational Logic for State Machine ==========================\\
  always @(*) begin
      next_state = current_state;
      case (current_state)
          RX_HS_STOP : begin 
            if(HSRX_EN)
              next_state = RX_HS_TERM;
          end
        
          RX_HS_TERM : begin 
            if (Zero_Detected)
                next_state = RX_HS_SYNC;
          end 
        
          RX_HS_SYNC : begin 
            if (SyncDetected)
                next_state = RX_HS_DATA;
          end 
        
          RX_HS_DATA : begin 
            if (!HSRX_EN)
                next_state = RX_HS_STOP;
          end 
          
      endcase 
  end
         
       
  //==================================== Output Logic ===========================================\\
  always @(posedge RxDDRClkHS) begin
      if (RxRst) begin
          HSFSM_Bytes     <= 8'bz;
          RxState         <= RX_HS_STOP;
          dueledge_ff_en  <= 1'b0;
          deserializer_en <= 1'b0;
          RxSyncHS        <= 1'b0;
          RxActiveHS      <= 1'b0;
          RxValidHS       <= 1'b0;
      end else begin
          case (current_state)
              RX_HS_STOP: begin
                HSFSM_Bytes     <= 8'bz;
                RxState         <= RX_HS_STOP;
                dueledge_ff_en  <= 1'b0;
                deserializer_en <= 1'b0;
                RxSyncHS        <= 1'b0;
                RxActiveHS      <= 1'b0;
                RxValidHS       <= 1'b0;
              end
           
              RX_HS_TERM: begin
                HSFSM_Bytes     <= 8'bz; 
                RxState         <= RX_HS_TERM;
                dueledge_ff_en  <= 1'b1;
                deserializer_en <= 1'b1;
                RxSyncHS        <= 1'b0;
                RxActiveHS      <= 1'b0;
                RxValidHS       <= 1'b0;
              end
            
              RX_HS_SYNC: begin  
                HSFSM_Bytes     <= 8'bz; 
                RxState         <= RX_HS_SYNC;
                dueledge_ff_en  <= 1'b1;
                deserializer_en <= 1'b1;
                RxSyncHS        <= 1'b0;
                RxActiveHS      <= 1'b0;
                RxValidHS       <= 1'b0;
                if (SyncDetected) begin 
                    RxSyncHS   <= 1'b1;
                    RxActiveHS <= 1'b1;
                end
              end
              
              RX_HS_DATA: begin  
                RxSyncHS        <= 1'b0;
                RxActiveHS      <= 1'b1;
                RxValidHS       <= 1'b1;
                HSFSM_Bytes     <= RxByte_HS; 
                RxState         <= RX_HS_DATA;
                dueledge_ff_en  <= 1'b1;
                deserializer_en <= 1'b1;
              end
            
          endcase 
      end
  end
endmodule 