`timescale 1ps/1ps  // ps scale for sub-nanosecond precision

module tb_top_rx_deserializer;

    // Inputs
    reg RxDDRClkHS;
    reg RxByteClkHS;
    reg RxRst;
    reg deff_en;
    reg deserializer_en;
    reg serial_in;

    // Output
    wire [7:0] parallel_out;

    // Instantiate the top module
    top_rx_deserializer dut (
        .RxDDRClkHS(RxDDRClkHS),
        .RxByteClkHS(RxByteClkHS),
        .RxRst(RxRst),
        .deff_en(deff_en),
        .deserializer_en(deserializer_en),
        .serial_in(serial_in),
        .parallel_out(parallel_out)
    );

    // DDR Clock: 1.5 GHz => 667 ps period
    initial begin
        RxDDRClkHS = 0;
        forever #(667/2) RxDDRClkHS = ~RxDDRClkHS;
    end

    // Byte Clock: 375 MHz => 2667 ps period
    initial begin
        RxByteClkHS = 0;
        forever #(2667/2) RxByteClkHS = ~RxByteClkHS;
    end

    // Task to send 8-bit serial data (MSB first) over DDR clock
    task send_serial_data(input [7:0] data);
        integer i;
        begin
            for (i = 7; i >= 0; i = i - 2) begin
                @(posedge RxDDRClkHS);
                serial_in = data[i];     // B1

                @(negedge RxDDRClkHS);
                serial_in = data[i-1];   // B2
            end
        end
    endtask

    // Test sequence
    initial begin
        // Initial state
        RxRst = 1;
        deff_en = 0;
        deserializer_en = 0;
        serial_in = 0;

        // Apply reset for a few cycles
      repeat (6) @(posedge RxDDRClkHS);
        RxRst = 0;

        // Enable system
      repeat (7) @(posedge RxDDRClkHS);
        deff_en = 1;
        
      
        // Start sending data immediately
        fork
          send_serial_data(8'b1010_1011); // send 8'hab
            begin
                repeat(2)@(posedge RxDDRClkHS);    // Wait 1 DDR clock (0.5 ns)
                deserializer_en = 1;  // Now assert deserializer enable
            end
        join

      send_serial_data(8'b0001_0001);
      send_serial_data(8'b1111_1111);
      
        // Wait for byte clock to capture
        repeat (8) @(posedge RxByteClkHS);

        // Check output
        if (parallel_out == 8'h1D)
            $display("PASS: Received parallel_out = %h", parallel_out);
        else
            $display("FAIL: Received parallel_out = %h (Expected 1D)", parallel_out);

        $finish;
    end

    // Monitor
    initial begin
        $display("Time\tSerIn\tOut\tB1_clk\tByte_clk\tRst");
        $monitor("%0t\t%b\t%h\t%b\t%b\t%b",
                 $time, serial_in, parallel_out, RxDDRClkHS, RxByteClkHS, RxRst);
    end

    initial begin
      // Required to dump signals to EPWave
      $dumpfile("dump.vcd");
      $dumpvars(0);
    end 
   
  
endmodule
