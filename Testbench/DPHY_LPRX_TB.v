`timescale 1ns/1ps

module tb_DPHY_LPRX;

  // Inputs
  reg LPRX_CLK;
  reg RxRst;
  reg LPEnable;
  reg LP_Dp;
  reg LP_Dn;

  // Output
  wire HSRX_EN;

  // Instantiate the DPHY_LPRX module
  DPHY_LPRX #(.D_TERM_EN_TIME(6)) uut (
    .LPRX_CLK(LPRX_CLK),
    .RxRst(RxRst),
    .LPEnable(LPEnable),
    .LP_Dp(LP_Dp),
    .LP_Dn(LP_Dn),
    .HSRX_EN(HSRX_EN)
  );

  // Generate 10 MHz LPRX_CLK
  initial begin
    LPRX_CLK = 0;
    forever #50 LPRX_CLK = ~LPRX_CLK; // 100 ns period
  end

  // Test sequence
  initial begin
    // Initialize inputs
    RxRst = 1;
    LPEnable = 0;
    LP_Dp = 1;
    LP_Dn = 1;

    // Apply reset for 5 cycles
    repeat (5) @(posedge LPRX_CLK);
    RxRst = 0;

    // Wait for 5 cycles
    repeat (5) @(posedge LPRX_CLK);

    // Enable LP mode
    LPEnable = 1;

    // Drive LP-11 state (Dp=1, Dn=1)
    LP_Dp = 1;
    LP_Dn = 1;
    repeat (10) @(posedge LPRX_CLK);

    // Drive LP-01 state (Dp=0, Dn=1)
    LP_Dp = 0;
    LP_Dn = 1;
    repeat (10) @(posedge LPRX_CLK);

    // Drive LP-00 state (Dp=0, Dn=0)
    LP_Dp = 0;
    LP_Dn = 0;
    repeat (30) @(posedge LPRX_CLK);

    // Drive LP-11 state (Dp=1, Dn=1)
    LP_Dp = 1;
    LP_Dn = 1;
    repeat (10) @(posedge LPRX_CLK);

    // Finish simulation
    $finish;
  end

  // Monitor signals
  initial begin
    $display("Time\tLPRX_CLK\tRXRst\tLPEnable\tLP_Dp\tLP_Dn\tHSRX_EN");
    $monitor("%0t\t%b\t\t%b\t%b\t\t%b\t%b\t%b",
             $time, LPRX_CLK, RxRst, LPEnable, LP_Dp, LP_Dn, HSRX_EN);
  end

  // Dump waveform
  initial begin
      // Required to dump signals to EPWave
      $dumpfile("dump.vcd");
      $dumpvars(0);
  end 

endmodule
