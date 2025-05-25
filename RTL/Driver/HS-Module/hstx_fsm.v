//===================================================================================
// File         : hstx_fsm.v
// Author       : Mohamed Ehab
// Date         : April 24, 2025
// Dependencies : counter.v
// Description  : 
//    RTL implementation of the High-Speed Transmitter Finite State Machine (HS-TX FSM)
//    for the MIPI D-PHY transmitter interface. The FSM manages the state transitions 
//    for initiating and terminating high-speed transmission phases according to 
//    MIPI D-PHY timing parameters.
//
//    States:
//      - TX_HS_STOP   : Idle state, transmitter inactive
//      - TX_HS_GO     : Assert HS request, wait for HS settle time (HSZERO_TIME)
//      - TX_HS_SYNC   : Transmit HS sync pattern (e.g., 0x1D) for alignment
//      - TX_HS_DATA   : Transmit user data (TxByte_Data)
//      - TX_HS_TRAIL  : Transmit last bit trail (replicated 8x) for HSTRAIL_TIME
//
//    The module controls serialized byte output and tracks transmission state 
//    and status for protocol compliance and debug visibility.
//
//===================================================================================


//================================== Module Declaration ==================================\\
module hstx_fsm 
  #(
   parameter HSZERO_TIME     = 8'h0A,
   parameter HSTRAIL_TIME    = 8'h0F 
  )  
  (
    input  wire        TxDDRClkHS,
    input  wire        TxRst,
    input  wire        SOT,
    input  wire        TxValid,
    input  wire [7:0]  TxByte_Data,
    output reg         serial_en,
    output reg  [7:0]  HSFSM_Bytes,
    output reg  [2:0]  TxState
);
  
  //================================= Local Variables =====================================\\
  // Counter signals
  wire        counter_done;
  wire [4:0]  count;
  reg         counter_enable;
  reg  [4:0]  counter_max;
  
  // State encoding 
  localparam TX_HS_STOP   = 3'b000;
  localparam TX_HS_GO     = 3'b001; 
  localparam TX_HS_SYNC   = 3'b010;
  localparam TX_HS_DATA   = 3'b011;
  localparam TX_HS_TRAIL  = 3'b100;
  localparam Unknown      = 3'b101;

  // Define State registers
  reg [2:0] current_state, next_state;
  
  // Store last data bit to be sent during trail state
  reg last_bit;
  
  
  //=================================== Instantiation =====================================\\
  // Instantiation of Internal Counter
  counter tx_counter   (.clock(TxDDRClkHS),
                        .reset(TxRst),
                        .en(counter_enable),
                        .max_count(counter_max),
                        .done(counter_done),
                        .count(count));
  
  
  //========================== Sequential Logic for State Machine =========================\\  
  always @(posedge TxDDRClkHS) begin
      if (TxRst)
          current_state <= TX_HS_STOP;
      else
          current_state <= next_state;
  end
  
  
   //======================= Combinational Logic for State Machine ==========================\\
  always @(*) begin
      next_state = current_state;
      counter_enable = 1'b0;
      counter_max = 5'h0;
      case (current_state)
          TX_HS_STOP : begin 
            if(SOT)
              next_state = TX_HS_GO;
          end
        
          TX_HS_GO : begin 
            counter_enable = 1'b1;
            counter_max = HSZERO_TIME;
            if (counter_done)
                next_state = TX_HS_SYNC;
          end 
        
          TX_HS_SYNC : begin 
            counter_enable = 1'b1;
            counter_max = 4;
            if (counter_done)
                next_state = TX_HS_DATA;
          end 
        
          TX_HS_DATA : begin 
            if (!SOT || !TxValid)
                next_state = TX_HS_TRAIL;
          end 
          
          TX_HS_TRAIL : begin 
            counter_enable = 1'b1;
            counter_max = HSTRAIL_TIME;
            if (counter_done)
                next_state = TX_HS_STOP;
          end
          
          default : begin 
            next_state = current_state;
            counter_enable = 1'b0;
            counter_max = 5'h0;
          end 
      endcase 
  end
  
       
       
  //==================================== Output Logic ===========================================\\
  always @(posedge TxDDRClkHS) begin
      if (TxRst) begin
          HSFSM_Bytes <= 8'bz;
          TxState   <= TX_HS_STOP;
          serial_en <= 1'b0;
          last_bit  <= 1'b0;
      end else begin
          case (current_state)
              TX_HS_STOP: begin
                HSFSM_Bytes <= 8'bz;
                TxState     <= TX_HS_STOP;
                last_bit    <= 1'b0;
                serial_en   <= 1'b0;
              end
           
              TX_HS_GO: begin
                HSFSM_Bytes <= 8'h00; 
                TxState     <= TX_HS_GO;
                last_bit    <= 1'b0;
                serial_en   <= 1'b1;
              end
            
              TX_HS_SYNC: begin  
                HSFSM_Bytes <= 8'h1d;
                serial_en   <= 1'b1;
                last_bit    <= 1'b0;
                TxState     <= TX_HS_SYNC;
              end
              
              TX_HS_DATA: begin  
                HSFSM_Bytes <= TxByte_Data;
                last_bit <= (!SOT || !TxValid)? TxByte_Data[7] : 1'b0;
                serial_en <= 1'b1;
                TxState   <= TX_HS_DATA;
              end
            
              TX_HS_TRAIL: begin 
                HSFSM_Bytes <= {8{last_bit}};
                serial_en <= 1'b0;
                TxState <= TX_HS_STOP;
              end
            
              default : begin 
                HSFSM_Bytes <= 8'h00;
                TxState     <= Unknown;
                last_bit    <= 1'b0;
                serial_en   <= 1'b0;
              end
          endcase 
      end
  end
endmodule 