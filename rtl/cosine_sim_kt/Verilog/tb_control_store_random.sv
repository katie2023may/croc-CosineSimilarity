`timescale 1ns/1ps

module tb_control_store_random();

    logic clk;
    logic reset;
    logic start, done;
    logic [31:0] A_vec, B_vec;
    logic [15:0] cosine_similarity;

    // Test vars.
    int NUM_TESTS = 200;
    int pass = 0;
    real pass_rate;
    logic [15:0] expected;

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

    // Clock generator: 100 ns period
    initial clk = 0;
    always #50 clk = ~clk;
    
    // Generate a random 32-bit vector with bytes in [1:31]
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

    // Main test
    initial begin
        reset = 1'b0;
        #200;
        reset = 1'b1;

        $display("=== Starting Constrained-Random Cosine Similarity Tests ===");

        for (int t = 0; t < NUM_TESTS; t++) begin
            reset = 1'b0;
            #200;
            reset = 1'b1;

            // Occasionally generate same vectors
            if ($urandom_range(0, 9) == 0) begin
                A_vec = random_vec();
                B_vec = A_vec;
                $display("\n--- Test %0d (same vector case) ---", t);
            end
            else begin
                A_vec = random_vec();
                B_vec = random_vec();
                $display("\n--- Test %0d ---", t);
            end

            $display("A_vec = %h | B_vec = %h", A_vec, B_vec);

            // Start pulse
            start = 1'b1;
            repeat (2) @(posedge clk);
            start = 1'b0;

            // Wait for DUT to finish (busy == 1'b0)
            wait(done == 1'b1);

            // Compute expected/reference value
            expected = ref_cosine(A_vec, B_vec);

            if (cosine_similarity === expected) begin
                pass++;
                $display("PASS: DUT = %0d   REF = %0d", cosine_similarity, expected);
            end else begin
                $display("DUT = %0d     REF = %0d", cosine_similarity, expected);
            end

            @(posedge clk);
        end

        #100;
        pass_rate = (pass / NUM_TESTS) * 100;
        $display("\n=== SUMMARY ===");
        $display("Total Tests = %0d", NUM_TESTS);
        $display("Passed      = %0d", pass);
        $display("Pass Rate   = %f", pass_rate);
        $display("====================\n");

        $finish;
    end

    /***** Reference Model *****/

    int scaled;
    // Function to quantize the output to 0 --> 8
    function automatic logic [15:0] quantized_cosim (
        int numerator, 
        int denominator
    );
        // Numerator = dot product
        // Denom = magA + magB

        if (denominator == 0) begin 
            return 16'd1;
        end

        scaled = $rtoi((numerator * 1000.0) / real'(denominator) + 0.5 );

        if (scaled >= 1000) return 16'd8;
        else if (scaled >= 875) return 16'd7;
        else if (scaled >= 750) return 16'd6;
        else if (scaled >= 625) return 16'd5;
        else if (scaled >= 500) return 16'd4;
        else if (scaled >= 375) return 16'd3;
        else if (scaled >= 250) return 16'd2;
        else return 16'd1;

    endfunction

    // Function to compute consine sim using plain SysVer
    function automatic logic [15:0] ref_cosine (
        input [31:0] A,
        input [31:0] B
    );

        // Place-holder
        int dot = 0;
        int magA = 0;
        int magB = 0;
        int a = 0;
        int b = 0;
        int denom = 0;

        // Cosine Similarity algorithm
        for (int i = 0; i < 4; i++) begin
            a = (A >> (i * 8)) & 8'hFF;
            b = (B >> (i * 8)) & 8'hFF;

            dot += a * b;
            magA += a * a;
            magB += b * b;        
        end

        denom = $rtoi($sqrt(magA) * $sqrt(magB));

        return quantized_cosim(dot, denom);

    endfunction

endmodule
