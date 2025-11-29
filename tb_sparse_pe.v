`timescale 1ns / 1ps

module tb_sparse_pe;

    // Signals
    reg clk, rst_n;
    reg [15:0] packed_activations;
    reg [3:0]  mask;
    reg [7:0]  weight_top, weight_bot;
    wire [31:0] result;

    // --- UPDATED ARRAY SIZES ---
    reg [15:0] mem_act [0:9999];       // Size 10,000
    reg [7:0]  mem_weights [0:19999];  // Size 20,000 (2 per test)
    reg [3:0]  mem_mask [0:9999];      // Size 10,000
    reg [15:0] mem_expected [0:9999];  // Size 10,000

    // Instantiate Design
    sparse_pe uut (
        .clk(clk), 
        .rst_n(rst_n), 
        .packed_activations(packed_activations), 
        .mask(mask), 
        .weight_top(weight_top), 
        .weight_bot(weight_bot), 
        .result(result)
    );

    // Clock Gen (100 MHz)
    always #5 clk = ~clk;

    integer i;
    reg [15:0] expected_val;

    initial begin
        // Init
        clk = 0; rst_n = 0;
        
        // VCD Dump for Waveforms
        $dumpfile("waves.vcd");
        $dumpvars(0, tb_sparse_pe);
        
        // Load Hex Files
        $readmemh("activations.hex", mem_act);
        $readmemh("weights.hex", mem_weights);
        $readmemh("mask.hex", mem_mask);
        $readmemh("expected.hex", mem_expected);

        // Reset
        #20 rst_n = 1;
        
        // --- UPDATED LOOP LIMIT ---
        for (i = 0; i < 10000; i = i + 1) begin
            // Drive Inputs
            packed_activations = mem_act[i];
            mask = mem_mask[i];
            
            // Weights logic (Stride of 2)
            weight_top = mem_weights[2*i];
            weight_bot = mem_weights[(2*i)+1];

            // Wait for processing
            @(posedge clk); #1; 

            // Check Output
            expected_val = mem_expected[i];
            @(posedge clk); #1;
            
            if (result !== expected_val) begin
                $display("Test %0d: FAIL (Out: %0d, Exp: %0d)", i, result, expected_val);
                $stop;
            end
            
            // Optional: Print status every 1000 tests so you know it's alive
            if (i % 1000 == 0) begin
                 $display("Test %0d passed...", i);
            end
        end

        $display("-------------------------------");
        $display("ALL 10,000 TESTS PASSED!.");
        $display("-------------------------------");
        $finish;
    end

endmodule