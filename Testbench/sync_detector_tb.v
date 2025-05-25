`timescale 1ns / 1ps

module sync_detector_tb;

    // Inputs
    reg RxByteClkHS = 0;
    reg Rst = 0;
    reg Enable = 0;
    reg [7:0] DataHS = 8'h00;

    // Outputs
    wire Zero_Detected;
    wire RxSyncHS;

    // Instantiate the Unit Under Test (UUT)
    sync_detector uut (
        .RxByteClkHS(RxByteClkHS),
        .Rst(Rst),
        .Enable(Enable),
        .DataHS(DataHS),
        .Zero_Detected(Zero_Detected),
        .RxSyncHS(RxSyncHS)
    );

    // Generate Clock
    always #5 RxByteClkHS = ~RxByteClkHS;  // 100MHz clock

    initial begin
        $display("Starting test...");
        
        // Reset the system
        Rst = 1;
        #20;
        Rst = 0;

        // Wait some cycles after reset
        #40;

        // Enable the module
        Enable = 1;

        // Apply first byte: 8'h0F
        DataHS = 8'b0000_00001;
        #10;

        // Apply second byte: 8'hF0
        DataHS = 8'b1111_1110;
        #10;

        // Wait and observe Zero_Detected
        #10;

        // Apply next byte: 8'h1F
        DataHS = 8'hF1;
        #10;

        // Apply next byte: 8'hDF
        DataHS = 8'hDF;
        #10;

        // Wait and observe RxSyncHS
        #20;

        $display("Test complete.");
        $stop;
    end

    initial begin
      // Required to dump signals to EPWave
      $dumpfile("dump.vcd");
      $dumpvars(0);
    end 
     
endmodule
