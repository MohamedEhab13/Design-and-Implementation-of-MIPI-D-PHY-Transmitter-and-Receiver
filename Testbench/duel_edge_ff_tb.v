`timescale 1ns/1ps

module duel_edge_ff_tb;

  // DUT Inputs
  reg TxDDRClkHS;
  reg TxRst;
  reg SOT;
  reg serial_B1;
  reg serial_B2;

  // DUT Output
  wire MuxOut;

  // Instantiate the DUT
  duel_edge_ff dut (
    .TxDDRClkHS(TxDDRClkHS),
    .TxRst(TxRst),
    .SOT(SOT),
    .serial_B1(serial_B1),
    .serial_B2(serial_B2),
    .MuxOut(MuxOut)
  );

  // Generate 1 GHz DDR clock (toggle every 0.5 ns)
  initial TxDDRClkHS = 0;
  always #0.5 TxDDRClkHS = ~TxDDRClkHS;

  // Stimulus process
  initial begin
    // Initialize
    TxRst      = 1;
    SOT        = 0;
    serial_B1  = 0;
    serial_B2  = 0;

    // Hold reset for 10 full clock cycles = 20 toggles = 10 ns
    #(10); // 10 ns
    TxRst = 0;

    // Assert SOT and apply data for 10 cycles = 20 toggles = 10 ns
    SOT = 1;
    repeat (20) begin
      serial_B1 = $urandom % 2;
      serial_B2 = $urandom % 2;
      #0.5;
    end

    // Deassert SOT for 5 cycles = 10 toggles = 5 ns
    SOT = 0;
    repeat (10) begin
      serial_B1 = $urandom % 2;
      serial_B2 = $urandom % 2;
      #0.5;
    end

    // Reassert SOT for another 10 cycles = 20 toggles = 10 ns
    SOT = 1;
    repeat (20) begin
      serial_B1 = $urandom % 2;
      serial_B2 = $urandom % 2;
      #0.5;
    end

    // End simulation
    $finish;
  end

  initial begin
       // Required to dump signals to EPWave
       $dumpfile("dump.vcd");
       $dumpvars(0);
  end

endmodule
