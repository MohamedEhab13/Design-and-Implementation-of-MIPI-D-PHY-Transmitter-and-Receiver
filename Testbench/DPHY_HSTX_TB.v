`timescale 1ps/1ps

module DPHY_HSTX_tb;

  // Clock period definitions
  real DDR_CLK_PERIOD  = 666.67;   // 1.5 GHz
  real BYTE_CLK_PERIOD = 2666.67;  // 375 MHz

  // DUT inputs
  reg        TxByteClkHS = 0;
  reg        TxDDRClkHS  = 0;
  reg        TxRst       = 1;
  reg        TxValid     = 0;
  reg        SOT         = 0;
  reg  [7:0] TxByte_Data = 8'd0;

  // DUT outputs
  wire       HS_Dp;
  wire       HS_Dn;
  wire [2:0] TxState;
  wire       TxReady;

  // Instantiate DUT
  DPHY_HSTX dut (
    .TxByteClkHS (TxByteClkHS),
    .TxDDRClkHS  (TxDDRClkHS),
    .TxRst       (TxRst),
    .TxValid     (TxValid),
    .SOT         (SOT),
    .TxByte_Data (TxByte_Data),
    .HS_Dp       (HS_Dp),
    .HS_Dn       (HS_Dn),
    .TxState     (TxState),
    .TxReady     (TxReady)
  );

  // Clock generation
  always #(DDR_CLK_PERIOD/2) TxDDRClkHS = ~TxDDRClkHS;
  always #(BYTE_CLK_PERIOD/2) TxByteClkHS = ~TxByteClkHS;

  // Test sequence
  initial begin
    $display("Starting Verilog Testbench for DPHY_HSTX");

    // Hold reset for 5 ByteClkHS cycles
    repeat (5) @(posedge TxByteClkHS);
    TxRst = 0;

    // Wait additional 5 ByteClkHS cycles
    repeat (5) @(posedge TxByteClkHS);

    // Start transmission
    TxValid = 1;
    SOT     = 1;
    TxByte_Data = 8'hA5;  // 1st byte
    
    // Wait 15 DDR clock cycles
    repeat (15) @(posedge TxDDRClkHS);

    // Send data 4 times, waiting 8 clocks in between
    repeat (4) @(posedge TxDDRClkHS);

    TxByte_Data = 8'h3C;  // 2nd byte
    repeat (4) @(posedge TxDDRClkHS);

    TxByte_Data = 8'h7E;  // 3rd byte
    repeat (4) @(posedge TxDDRClkHS);

    TxByte_Data = 8'h99;  // 4th byte
    repeat (4) @(posedge TxDDRClkHS);

    // End transmission
    TxValid = 0;
    SOT     = 0;

    // Wait 20 DDR clock cycles
    repeat (20) @(posedge TxDDRClkHS);

    $display("Simulation completed.");
    $stop;
  end

  initial begin
    // Required to dump signals to EPWave
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end

endmodule
