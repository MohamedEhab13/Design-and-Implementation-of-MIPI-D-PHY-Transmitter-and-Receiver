//===================================================================================
// File         : sync_detector.v
// Author       : Mohamed Ehab
// Date         : May 1, 2025
// Description  : 
//    High-Speed Synchronization Detector Module for MIPI D-PHY Receiver.
//
//    - Monitors incoming high-speed 8-bit data (DataHS) on each RxByteClkHS edge.
//    - Detects 8 consecutive '0' bits as a synchronization preamble.
//    - Searches for the sync character 8'h1D within a 16-bit detection window.
//    - Reports the bit alignment position via RxSyncPosition.
//    - Generates RxSyncHS pulse when sync pattern is found.
//    - Uses alternating loading of LSB and MSB bytes into a 16-bit shift register.
//
//===================================================================================


module sync_detector (
    input  wire        RxByteClkHS,
    input  wire        Rst,
    input  wire [7:0]  DataHS,
    input  wire        Enable, 
    output reg         Zero_Detected,
    output reg  [3:0]  RxSyncPosition,       
    output reg         RxSyncHS
);

    reg [15:0] detect_reg;
    reg        load_LSB;      // Toggle flag to alternate loading LSB/MSB
  
    always @(posedge RxByteClkHS or posedge Rst) begin
        if (Rst) begin
            detect_reg     <= 16'hffff;
            load_LSB       <= 1'b0;
            Zero_Detected  <= 1'b0;
            RxSyncHS       <= 1'b0;
            RxSyncPosition <= 1'b0;
        end else if (Enable) begin
          
            // Default low unless triggered below
            RxSyncHS <= 1'b0;  
            Zero_Detected <= 1'b0;  
          
            // Load into LSB first, then MSB
            if (load_LSB == 1'b0) begin
                detect_reg[7:0] <= DataHS;
                load_LSB       <= 1'b1;
            end else begin
                detect_reg[15:8] <= DataHS;
                load_LSB        <= 1'b0;
            end 
          
                // Check for 8 successive zeros in the 16-bit register
                if (!Zero_Detected) begin     
                  if (detect_reg[7:0] == 8'h0) begin 
                    $display("detect_reg[7:0] = %b",detect_reg[7:0]);
                      Zero_Detected <= 1'b1;
                  end
                    
                  else if(detect_reg[8:1] == 8'h0)
                      Zero_Detected <= 1'b1;
                  
                  else if(detect_reg[9:2] == 8'h0)
                      Zero_Detected <= 1'b1;
                  
                  else if(detect_reg[10:3] == 8'h0)
                      Zero_Detected <= 1'b1;
                  
                  else if(detect_reg[11:4] == 8'h0)
                      Zero_Detected <= 1'b1;
                  
                  else if(detect_reg[12:5] == 8'h0)
                      Zero_Detected <= 1'b1;
                  
                  else if(detect_reg[13:6] == 8'h0)
                      Zero_Detected <= 1'b1;
                  
                  else if(detect_reg[14:7] == 8'h0)
                      Zero_Detected <= 1'b1;
                  
                  else if(detect_reg[15:8] == 8'h0)
                      Zero_Detected <= 1'b1;
                  
                end else begin
                  
                // After zero detection, look for 8'h1D
                if (detect_reg[7:0] == 8'h1D) begin
                    RxSyncHS       <= 1'b1;
                    Zero_Detected  <= 1'b0;
                    RxSyncPosition <= 4'd0; 
                end
                else if (detect_reg[8:1] == 8'h1D) begin
                    RxSyncHS       <= 1'b1;
                    Zero_Detected  <= 1'b0;
                    RxSyncPosition <= 4'd1;
                end
                else if (detect_reg[9:2] == 8'h1D) begin
                    RxSyncHS       <= 1'b1;
                    Zero_Detected  <= 1'b0;
                    RxSyncPosition <= 4'd2;
                end
                else if (detect_reg[10:3] == 8'h1D) begin
                    RxSyncHS       <= 1'b1;
                    Zero_Detected  <= 1'b0;
                    RxSyncPosition <= 4'd3;
                end
                else if (detect_reg[11:4] == 8'h1D) begin
                    RxSyncHS       <= 1'b1;
                    Zero_Detected  <= 1'b0;
                    RxSyncPosition <= 4'd4;
                end
                else if (detect_reg[12:5] == 8'h1D) begin
                    RxSyncHS       <= 1'b1;
                    Zero_Detected  <= 1'b0;
                    RxSyncPosition <= 4'd5;
                end
                else if (detect_reg[13:6] == 8'h1D) begin
                    RxSyncHS       <= 1'b1;
                    Zero_Detected  <= 1'b0;
                    RxSyncPosition <= 4'd6;
                end
                else if (detect_reg[14:7] == 8'h1D) begin
                    RxSyncHS       <= 1'b1;
                    Zero_Detected  <= 1'b0;
                    RxSyncPosition <= 4'd7;
                end
                else if (detect_reg[15:8] == 8'h1D) begin
                    RxSyncHS       <= 1'b1;
                    Zero_Detected  <= 1'b0;
                    RxSyncPosition <= 4'd8;
                end
           end
      end 
  end 

endmodule
