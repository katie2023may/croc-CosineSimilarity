`timescale 1ns/1ps

module tb_control_store_random();

    logic clk;
    logic reset;
    logic start, done;
    logic [31:0] A_vec, B_vec;
    logic [15:0] cosine_similarity;

    int NUM_TESTS = 2000;
    int pass = 0;
    real pass_rate;
    int expected;

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

    // Clock
    initial clk = 0;
    always #50 clk = ~clk;

    // Random 4-byte vector (1–31)
    function automatic [31:0] random_vec();
        logic [7:0] c0, c1, c2, c3;
        begin
            c0 = $urandom_range(1, 31);
            c1 = $urandom_range(1, 31);
            c2 = $urandom_range(1, 31);
            c3 = $urandom_range(1, 31);
            random_vec = {c3, c2, c1, c0};
        end
    endfunction

    // ================================================================
    // MAIN TEST LOOP
    // ================================================================
    initial begin
        reset = 0; #200; reset = 1;

        $display("=== Starting Constrained-Random Cosine Similarity Tests ===");

        for (int t = 0; t < NUM_TESTS; t++) begin
            reset = 0; #200; reset = 1;

            // 10% same vector
            if ($urandom_range(0, 9) == 0) begin
                A_vec = random_vec();
                B_vec = A_vec;
            end else begin
                A_vec = random_vec();
                B_vec = random_vec();
            end

            start = 1;
            repeat (2) @(posedge clk);
            start = 0;

            wait(done == 1);

            expected = ref_cosine(A_vec, B_vec);

            if (cosine_similarity == expected) begin
                pass++;
            end else begin
                $display("FAIL: DUT=%0d  REF=%0d  A=%h  B=%h", cosine_similarity, expected, A_vec, B_vec);
                $display("Dot = %0d", 
                    ((A_vec[7:0] * B_vec[7:0]) + 
                     (A_vec[15:8] * B_vec[15:8]) + 
                     (A_vec[23:16] * B_vec[23:16]) + 
                     (A_vec[31:24] * B_vec[31:24])));
            end

            @(posedge clk);
        end

        pass_rate = (pass * 100.0) / NUM_TESTS;

        $display("\n===== SUMMARY =====");
        $display("Tests      : %0d", NUM_TESTS);
        $display("Passed     : %0d", pass);
        $display("Pass Rate  : %0.2f %%", pass_rate);
        $display("====================\n");

        $finish;
    end

    // ================================================================
    // REFERENCE MODEL — corrected version (0..7 indexing)
    // ================================================================
    function automatic int ref_cosine(
        input [31:0] A, 
        input [31:0] B
    );
        int dot = 0;
        int magA = 0;
        int magB = 0;
        int a, b;
        int sqrtA, sqrtB;
        int ref_threshold;
        int level = 1;

        // Fractions * 1000
        int frac [0:7] = '{125, 250, 375, 500, 625, 750, 875, 1000};

        // Dot + magnitudes
        for (int i = 0; i < 4; i++) begin
            a = (A >> (i*8)) & 8'hFF;
            b = (B >> (i*8)) & 8'hFF;
            dot  += a * b;
            magA += a * a;
            magB += b * b;
        end

        // Integer square roots
        sqrtA = $rtoi($sqrt(magA));
        sqrtB = $rtoi($sqrt(magB));

        // Thresholds 1..8
        for (int i = 0; i < 8; i++) begin
            ref_threshold = frac[i] * sqrtA * sqrtB;  // already scaled by 1000
            if ((dot * 1000) >= ref_threshold)
                level = i + 1;   // output is 1..8
        end

        return level;
    endfunction

endmodule
