
`timescale 1ns/1ps

module PRBS_9_tb;

//=========================== Clock Parameters ===============================\\
real CLK_PERIOD = 100.0; // 10 MHz => 100 ns

//=========================== DUT Signals ====================================\\
reg        Clk;
reg        TxRst;
reg        Enable;
wire [7:0] PRBS_Pattern;

//=========================== Instantiate DUT ================================\\
PRBS_9 dut (
    .Clk(Clk),
    .TxRst(TxRst),
    .Enable(Enable),
    .PRBS_Pattern(PRBS_Pattern)
);

//=========================== Clock Generation ===============================\\
initial begin
    Clk = 0;
    forever #(CLK_PERIOD/2) Clk = ~Clk;
end

//=========================== Stimulus Process ===============================\\
int i ;  
initial begin
    // Initialize
    TxRst  = 1'b1;
    Enable = 1'b0;
    
    // Hold reset for 5 clock cycles
    repeat(5) @(posedge Clk);
    TxRst = 1'b0;
    
    // Wait for 5 more clock cycles after reset de-assertion
    repeat(5) @(posedge Clk);
    
    // Enable PRBS generator
    Enable = 1'b1;
    
    // Run for 520 cycles while printing the PRBS pattern
    repeat(550) begin
        @(posedge Clk);
      $display("Cycle[%0d] ns, PRBS_Pattern = %b", i, PRBS_Pattern);
      i = i + 1;
    end
    
    // Deassert enable
    Enable = 1'b0;
    
    // Wait for a few more cycles to observe behavior
    repeat(5) @(posedge Clk);
    
    $stop;
end

 initial begin
    // Required to dump signals to EPWave
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end 
  
endmodule
