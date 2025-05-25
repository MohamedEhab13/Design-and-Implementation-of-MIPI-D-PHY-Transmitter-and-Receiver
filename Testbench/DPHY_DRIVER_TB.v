`timescale 1ps/1ps

module DPHY_DRIVER_TB;

//=========================== Clock Parameters ===============================\\
// Clock period definitions
real DDR_CLK_PERIOD  = 666.67;   // 1.5 GHz
real BYTE_CLK_PERIOD = 2666.67;  // 375 MHz
real LP_CLK_PERIOD = 5000;  // 10 MHz
  
  
//============================ DUT Inputs ====================================\\
reg TxDDRClkHS_I    = 0;
reg TxByteClkHS     = 0;
reg TxLP_Clk        = 0;
reg TxRst           = 0;
reg TxValidHS       = 0;
reg TxRequestHS     = 0;
reg [7:0] TxDataHS  = 0;
reg TxLP_Enable     = 0;

//=========================== DUT Outputs ====================================\\
wire TxDp;
wire TxDn;
wire TxClk_Enable;
wire [2:0] DphyTxState;
wire TxReadyHS;

//=========================== Instantiate DUT ================================\\
DPHY_DRIVER dut (
    .TxDDRClkHS_I (TxDDRClkHS_I),
    .TxByteClkHS  (TxByteClkHS),
    .TxLP_Clk     (TxLP_Clk),
    .TxRst        (TxRst),
    .TxValidHS    (TxValidHS),
    .TxRequestHS  (TxRequestHS),
    .TxDataHS     (TxDataHS),
    .TxLP_Enable  (TxLP_Enable),
    .TxDp         (TxDp),
    .TxDn         (TxDn),
    .TxClk_Enable (TxClk_Enable),
    .DphyTxState  (DphyTxState),
    .TxReadyHS    (TxReadyHS)
);

//============================ Clock Generation ==============================\\
 always #(DDR_CLK_PERIOD/2) TxDDRClkHS_I = ~TxDDRClkHS_I;
 always #(BYTE_CLK_PERIOD/2) TxByteClkHS = ~TxByteClkHS;
 always #(LP_CLK_PERIOD/2) TxLP_Clk = ~TxLP_Clk;


//=========================== Stimulus Process ===============================\\
initial begin
    // Initialize
    TxRst       = 1;
    TxValidHS   = 0;
    TxRequestHS = 0;
    TxDataHS    = 8'h00;
    TxLP_Enable = 0;

    // Reset for a few cycles
    #(10 * DDR_CLK_PERIOD);

    TxRst = 0;

    // Wait after reset
    #(10 * DDR_CLK_PERIOD);

    // Start driving signals
    TxValidHS   = 1;
    TxRequestHS = 1;
    TxLP_Enable = 1;
    TxDataHS    = 8'hA5; // Initial data

    // Hold data for 40 DDR clock cycles
  #(213 * DDR_CLK_PERIOD);

    // Change data and hold for 4 DDR cycles
    TxDataHS = 8'h5A;
    #(4 * DDR_CLK_PERIOD);

    TxDataHS = 8'h3C;
    #(4 * DDR_CLK_PERIOD);

    TxDataHS = 8'hC3;
    #(4 * DDR_CLK_PERIOD);

    TxDataHS = 8'h7E;
    #(4 * DDR_CLK_PERIOD);

    // Deassert LP_Enable, Valid, Request
    TxValidHS   = 0;
    TxRequestHS = 0;
    TxLP_Enable = 0;

    // Wait for 20 DDR cycles before finishing
    #(20 * DDR_CLK_PERIOD);

    $stop;
end
  
initial begin
    // Required to dump signals to EPWave
    $dumpfile("dump.vcd");
    $dumpvars(0);
end

endmodule