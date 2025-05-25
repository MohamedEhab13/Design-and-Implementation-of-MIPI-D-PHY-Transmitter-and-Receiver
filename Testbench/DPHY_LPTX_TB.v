`timescale 1ns / 1ps

module DPHY_LPTX_tb;

 // DUT signals
 reg      clk;
 reg      rst;
 reg      lptx_en;
 reg      tx_request_hs;
 wire     dp, dn;
 wire     hsclk_en;
 wire     hstx_en;
  
 // Instantiate the DUT
 DPHY_LPTX #(
    .LPX_TIME(4),
    .HSPREPARE_TIME(8),
    .HSEXIT_TIME(16))
     DUT 
     (
    .LPTX_CLK(clk),
    .TxRst(rst),
    .LPTX_EN(lptx_en),
    .TxRequestHS(tx_request_hs),
    .Dp(dp),
    .Dn(dn),
    .HSCLK_EN(hsclk_en),
    .HSTX_EN(hstx_en)
    );
 
 // Clock generation: 10 MHz (100 ns period)
 initial clk = 1;
 always #50 clk = ~clk; 
  
 // Initialize inputs 
 initial begin
    rst            = 1;
    lptx_enable    = 0;
    tx_request_hs  = 0; 
 
    // Apply reset for 400 ns
    #400;
    rst = 0; 
  
    // Enable module and assert TxRequestHS to start HS transmission
    #200;
    lptx_en        = 1;
    tx_request_hs  = 1;
  
    // Insert delay before deasserting TxRequestHS (simulate HS burst time)
    #2000;
    tx_request_hs = 0;

    // Wait enough time for the state to return to STOP
    #2000;
  
    $stop ; 
    
 end
  
 initial begin
    // Required to dump signals to EPWave
    $dumpfile("dump.vcd");
    $dumpvars(0);
 end
  
endmodule
