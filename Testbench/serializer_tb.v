`timescale 1ns / 1ps

module serializer_method2_tb;

    // DUT inputs
    reg         TxByteClkHS;
    reg         TxDDRClkHS;
    reg         TxRst;
    reg         Serializer_Enable;
    reg [7:0]   TxByteHS_Data;

    // DUT outputs
    wire        Serial_Bit1;
    wire        Serial_Bit2;

    // Instantiate the DUT
    serializer DUT (
        .TxByteClkHS(TxByteClkHS),
        .TxDDRClkHS(TxDDRClkHS),
        .TxRst(TxRst),
        .Serializer_Enable(Serializer_Enable),
        .TxByteHS_Data(TxByteHS_Data),
        .Serial_Bit1(Serial_Bit1),
        .Serial_Bit2(Serial_Bit2)
    );

    // Clock periods (in ns)
    localparam real DDR_CLK_PERIOD  = 1.0;  // 1 GHz
    localparam real BYTE_CLK_PERIOD = 4.0;  // 250 MHz

    // Clock generation
    initial begin
        TxDDRClkHS = 0;
        forever #(DDR_CLK_PERIOD/2) TxDDRClkHS = ~TxDDRClkHS;
    end

    initial begin
        TxByteClkHS = 0;
        forever #(BYTE_CLK_PERIOD/2) TxByteClkHS = ~TxByteClkHS;
    end

    // Stimulus
    initial begin
        // Initialize signals
        TxRst              = 1;
        Serializer_Enable  = 0;
        TxByteHS_Data      = 8'h00;

        // Wait 4 Byte clocks 
        #(4 * BYTE_CLK_PERIOD);

        // Deassert reset
        TxRst = 0;

        // Wait 4 more Byte clocks
        #(4 * BYTE_CLK_PERIOD);

        // Assert enable and apply data
        Serializer_Enable = 1;
        TxByteHS_Data = 8'b0011_0011;  

        // Wait 1 Byte clock (4 DDR clocks)
        #(BYTE_CLK_PERIOD);

        // Apply new data
        TxByteHS_Data = 8'b1100_0011;

        // Wait 6 DDR clock
        #(6 * DDR_CLK_PERIOD);

        // Deassert enable, apply new data (ignored)
        Serializer_Enable = 0;
        TxByteHS_Data = 8'b0101_0111;

        // Wait some cycles to observe output
        #(10 * DDR_CLK_PERIOD);

        // Finish simulation
        $finish;
    end

    initial begin
       // Required to dump signals to EPWave
       $dumpfile("dump.vcd");
       $dumpvars(0);
    end

endmodule
