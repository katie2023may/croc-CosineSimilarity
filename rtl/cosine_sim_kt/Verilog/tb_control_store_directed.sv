`timescale 1ns/1ps

module tb_control_store_directed();

    logic clk;
    logic reset;
    logic [15:0] cosine_similarity;
    logic [31:0] A_vec, B_vec;
    logic start, done;

    // DUT
    control_store dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .done(done),
        .A_vec(A_vec),
        .B_vec(B_vec),
        .cosine_similarity(cosine_similarity)
    );

    // Clock: 100 ns period
    initial clk = 0;
    always #50 clk = ~clk;

    // === Test vectors ===
    logic [31:0] A_tests [6:0];
    logic [31:0] B_tests [6:0];
    string labels [7:0];

    initial begin
        // A vectors
        A_tests[0] = 32'h01020304; // Same vector
        A_tests[1] = 32'h7F807F80; // Alternating pos/neg
        A_tests[2] = 32'h01000000; // Orthogonal-like
        A_tests[3] = 32'h01FF7F80; // Spread edges
        A_tests[4] = 32'h7F00FF80; // Mixed signs
        A_tests[5] = 32'h7F7F7F7F; // Max positive alignment
        A_tests[6] = 32'hFFFFFFFF; // Opposite direction

        // B vectors
        B_tests[0] = 32'h01020304; // Same vector
        B_tests[1] = 32'h807F807F; // Alternating pos/neg
        B_tests[2] = 32'h00010000; // Orthogonal-like
        B_tests[3] = 32'h807FFF01; // Spread edges
        B_tests[4] = 32'h80FF007F; // Mixed signs
        B_tests[5] = 32'h7F7F7F7F; // Max positive alignment
        B_tests[6] = 32'h01010101; // Opposite direction

        // Labels
        labels[0] = "Same vector";
        labels[1] = "Alternating pos/neg";
        labels[2] = "Orthogonal-like";
        labels[3] = "Spread edges";
        labels[4] = "Mixed signs";
        labels[5] = "Max positive alignment";
        labels[6] = "Opposite direction";
    end

    // === Main test process ===
    initial begin
        $display("=== Starting Cosine Similarity Directed Tests ===");

        for (int i = 0; i < 7; i++) begin
            reset = 0;
            #200;                  // keep reset high for two clock cycles
            reset = 1;

            A_vec = A_tests[i];
            B_vec = B_tests[i];

            $display("\n--- Test %0d : %s ---", i, labels[i]);
            $display("A_vec = 0x%h  B_vec = 0x%h", A_vec, B_vec);

            start = 1;
            $display("Start: %0d: ", start);
            @(posedge clk);
            $display("Busy: %0d: ", dut.busy);
            @(posedge clk);
            start = 0;

            $display("Start: %0d: ", start);
            // Run long enough to fetch all ROM entries
            $display("Busy: %0d: ", dut.busy);

            wait (done == 1'b1);

            $display("DUT cosine_similarity = %0d (0x%h)", cosine_similarity, cosine_similarity);

            // Small delay before next test
            @(posedge clk);
        end

        $display("\n=== All Tests Complete ===");
        $finish;
    end

endmodule
