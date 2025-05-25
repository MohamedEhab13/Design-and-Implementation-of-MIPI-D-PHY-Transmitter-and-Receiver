`timescale 1ns/1ps

module tb_HS_DuelEdge_ff;

    // Testbench signals
    reg serial_in;
    reg RxDDRClkHS;
    reg RxRst;
    reg deff_en;
    wire parallel_B1;
    wire parallel_B2;

    // Instantiate the DUT
    HS_DuelEdge_ff dut (
        .serial_in(serial_in),
        .RxDDRClkHS(RxDDRClkHS),
        .RxRst(RxRst),
        .deff_en(deff_en),
        .parallel_B1(parallel_B1),
        .parallel_B2(parallel_B2)
    );

    // Clock generation: 50MHz => 20ns period
    initial begin
        RxDDRClkHS = 0;
        forever #10 RxDDRClkHS = ~RxDDRClkHS;
    end

    // Stimulus block
    initial begin
        // Initialize
        serial_in = 0;
        RxRst = 1;
        deff_en = 0;

        // Apply reset for 4 clock cycles
        #80;
        RxRst = 0;

        // Wait a few cycles before enabling
        #40;

        // Enable sampling
        deff_en = 1;

        // Apply serial data pattern
        repeat (30) begin
            #10 serial_in = $random;
        end

        // Disable enable
        deff_en = 0;

        // Finish simulation
        #50;
        $finish;
    end

    // Monitor
    initial begin
        $display("Time\tClk\tRst\tEn\tSerIn\tB1\tB2");
        $monitor("%0t\t%b\t%b\t%b\t%b\t%b\t%b", 
                 $time, RxDDRClkHS, RxRst, deff_en, serial_in, parallel_B1, parallel_B2);
    end
  
    initial begin
      // Required to dump signals to EPWave
      $dumpfile("dump.vcd");
      $dumpvars(0);
    end 

endmodule
