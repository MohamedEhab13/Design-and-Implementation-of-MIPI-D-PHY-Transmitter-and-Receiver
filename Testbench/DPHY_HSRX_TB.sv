`timescale 1ps/1ps

module tb_DPHY_HSRX;

  // Clock & Reset
  logic RxDDRClkHS;
  logic RxByteClkHS;
  logic RxRst;
  logic HSRX_EN;
  logic HS_Dp;

  // Outputs from DUT
  wire [2:0] RxState;
  wire [7:0] RxDataHS;
  wire [3:0] RxSyncPosition;
  wire       RxActiveHS;
  wire       RxSyncHS;
  wire       RxValidHS;

  // Instantiate DUT
  DPHY_HSRX dut (
    .RxByteClkHS      (RxByteClkHS),
    .RxDDRClkHS       (RxDDRClkHS),
    .RxRst            (RxRst),
    .HSRX_EN          (HSRX_EN),
    .HS_Dp            (HS_Dp),
    .RxState          (RxState),
    .RxDataHS         (RxDataHS),
    .RxSyncPosition   (RxSyncPosition),
    .RxActiveHS       (RxActiveHS),
    .RxSyncHS         (RxSyncHS),
    .RxValidHS        (RxValidHS)
  );

  // Clock Generation
  initial begin
    RxDDRClkHS = 0;
    forever #250 RxDDRClkHS = ~RxDDRClkHS;  // 2 GHz clock (500 ps period)
  end

  initial begin
    RxByteClkHS = 0;
    forever #1000 RxByteClkHS = ~RxByteClkHS;  // 500 MHz (8 ns period)
  end

  // Task to send 8-bit serial data (MSB first) over DDR clock
    task send_serial_data(input [7:0] data);
        integer i;
        begin
            for (i = 7; i >= 0; i = i - 2) begin
                @(posedge RxDDRClkHS);
                HS_Dp = data[i];     // B1

                @(negedge RxDDRClkHS);
                HS_Dp = data[i-1];   // B2
            end
        end
    endtask
  
  // Test Sequence
  initial begin
    
    // Default states
    RxRst     = 1;
    HSRX_EN   = 0;
    HS_Dp     = 1;

    // Apply reset for 10 DDR cycles
    repeat (10) @(posedge RxDDRClkHS);
    RxRst = 0;

    // Wait for 10 DDR cycles post-reset
    repeat (10) @(posedge RxDDRClkHS);

    // Enable receiver
    HSRX_EN = 1;

    // Send 8 zero bytes (64 bits) as DDR serial stream (LSB-first)
    send_serial_data(8'b0);
    send_serial_data(8'h1D);
    send_serial_data(8'h1D);
    send_serial_data(8'haa);
    send_serial_data(8'hbb);
    send_serial_data(8'hcc);
    send_serial_data(8'hdd);
    send_serial_data(8'hee);
    

    // Wait for a few more cycles to let FSM stabilize
    repeat (20) @(posedge RxDDRClkHS);

    $display("RxDataHS = %h, RxValidHS = %b, RxActiveHS = %b, RxSyncHS = %b", 
              RxDataHS, RxValidHS, RxActiveHS, RxSyncHS);

    $stop;
  end
    
    // Dump waveform
    initial begin
      // Required to dump signals to EPWave
      $dumpfile("dump.vcd");
      $dumpvars(0);
    end
  
endmodule
