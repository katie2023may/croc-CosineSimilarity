// Testbench: Cosine Similarity Algorithm
/*
TB strategy:
(1) Exhaustive testing: do a full 0-->2pi sweep with 2 fixed-length, 5-bit vectors
(2) Corner cases:
- Identical vectors: vecA = vecB
- Opposite vectors: vecA = -vecB
- Orthogonal vectors: vecA * vecB = 0
- Zero vectors (TBD): vecA = 0 and/or vecB = 0
- Single element/not full vectros
- Empty vectors
*/

`timescale 1ns / 1ps

module tb_cosine_sim;

    // DUT
    localparam W = 5;
    logic clk;
    logic rst_n;
    logic start;
    logic [31:0] vec_a [W-1:0];
    logic [31:0] vec_b [W-1:0];
    logic [31:0] similarity;
    logic valid;

    cosine_sim #(.W(W)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .vec_a(vec_a),
        .vec_b(vec_b),
        .similarity(similarity),
        .valid(valid)
    );

    // Testbench variables
   //  int test_count;
   //  int error_count;
    real expected_sim;
    real computed_sim;
   //  real error;
   //  real max_error;
   real a0, a1, a2, a3, a4;
   real b0, b1, b2, b3, b4;
   
    // clk generation
    localparam int CLK_PERIOD = 10;     // TODO: TBD
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

   initial begin
      rst_n = 1'b0;                    // Reset all signals
      start = 1'b0;
      // test_count = 0;
      // error_count = 0;
      // max_error = 0.0;

      $display("\n========================================");
      $display("Cosine Similarity Algorithm Testbench");
      $display("========================================");
      $display("Clock Period: %0d ns", CLK_PERIOD);
      // $display("Fixed-point format: <int,%0d>", FRAC);
      $display("========================================\n");

   /**************************************** ITERATION 1 *************************************/
      #(CLK_PERIOD * 2);
      rst_n = 1'b1;
      #(CLK_PERIOD * 2);

      a0 = 1.0;
      a1 = 1.0;
      a2 = 1.0;
      a3 = 1.0;
      a4 = 1.0;

      b0 = 1.0;
      b1 = 1.0;
      b2 = 1.0;
      b3 = 1.0;
      b4 = 1.0;

      // TODO: manually compute expected simiarity
      expected_sim = 1.0;

      vec_a[0] = $realtobits(a0);
      vec_a[1] = $realtobits(a1);
      vec_a[2] = $realtobits(a2);
      vec_a[3] = $realtobits(a3);
      vec_a[4] = $realtobits(a4);

      vec_b[0] = $realtobits(b0);
      vec_b[1] = $realtobits(b1);
      vec_b[2] = $realtobits(b2);
      vec_b[3] = $realtobits(b3);
      vec_b[4] = $realtobits(b4);

      // trigger computation
      start = 1'b1;
      @ (posedge clk)
      start = 1'b0;

      wait (valid == 1'b1);
      #CLK_PERIOD;
      computed_sim = $bitstoreal(similarity);

      if (computed_sim == expected_sim) begin
         $display("\nVector A = [%f, %f, %f, %f, %f]", a0, a1, a2, a3, a4);
         $display("Vector B = [%f, %f, %f, %f, %f]", b0, b1, b2, b3, b4);
         $display("PASSED: Computed = %f - Expected = %f\n", computed_sim, expected_sim);
      end else begin
         $display("\nVector A = [%f, %f, %f, %f, %f]", a0, a1, a2, a3, a4);
         $display("Vector B = [%f, %f, %f, %f, %f]", b0, b1, b2, b3, b4);
         $display("FAILED: Computed = %f - Expected = %f\n", computed_sim, expected_sim);
      end
      /************************* END OF ITERATION 1 **********************************/

   end

   initial begin
      #(CLK_PERIOD * 10000);
      $display("\n*** ERROR: Simulation timeout ***\n");
      $finish;
   end

   initial begin
      $dumpfile("tb_cosine_sim.vcd");
      $dumpvars(0, tb_cosine_sim);
   end

endmodule
