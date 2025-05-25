`timescale 1ps/1ps

module hstx_fsm_tb;

  // DUT signals
  reg         TxDDRClkHS;
  reg         TxRst;
  reg         SOT;
  reg         TxValid;
  reg  [7:0]  TxByte_Data;
  wire        serial_en;
  wire [7:0]  HSFSM_Bytes;
  wire [2:0]  TxState;

  // Instantiate DUT
  hstx_fsm dut (
    .TxDDRClkHS(TxDDRClkHS),
    .TxRst(TxRst),
    .SOT(SOT),
    .TxValid(TxValid),
    .TxByte_Data(TxByte_Data),
    .serial_en(serial_en),
    .HSFSM_Bytes(HSFSM_Bytes),
    .TxState(TxState)
  );

  // Clock Generation: 1.5 GHz (Period = ~666.67 ps ≈ 667 ps)
  always #333 TxDDRClkHS = ~TxDDRClkHS;

  // Initial block for stimulus
  initial begin
    // Initialize signals
    TxDDRClkHS   = 0;
    TxRst        = 1;
    SOT          = 0;
    TxValid      = 0;
    TxByte_Data  = 8'h00;

    // Assert reset for a few cycles
    repeat (10) @(posedge TxDDRClkHS);
    TxRst = 0;

    // Wait a few more cycles
    repeat (10) @(posedge TxDDRClkHS);

    // Assert SOT and TxValid
    SOT     = 1;
    TxValid = 1;
    TxByte_Data = 8'hBB;

    // Wait until FSM enters TX_HS_DATA 
    repeat (23) @(posedge TxDDRClkHS);


    // Send data 4 times, waiting 8 clocks in between
    TxByte_Data = 8'hA5;  // 1st byte
    repeat (8) @(posedge TxDDRClkHS);

    TxByte_Data = 8'h3C;  // 2nd byte
    repeat (8) @(posedge TxDDRClkHS);

    TxByte_Data = 8'h7E;  // 3rd byte
    repeat (8) @(posedge TxDDRClkHS);

    TxByte_Data = 8'h99;  // 4th byte
    repeat (8) @(posedge TxDDRClkHS);

    // Deassert SOT and TxValid to enter TRAIL
    SOT     = 0;
    TxValid = 0;

    // Wait a few more cycles before ending
    repeat (20) @(posedge TxDDRClkHS);

    $display("Simulation completed at time %t", $time);
    $stop;
  end

  
  initial begin
    // Required to dump signals to EPWave
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
  
  
endmodule
