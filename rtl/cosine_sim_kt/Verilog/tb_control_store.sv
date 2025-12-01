`timescale 1ns/1ps

module tb_control_store;

    logic clk;
    logic reset;
    logic [15:0] cosine_similarity;
    logic [31:0] A_vec, B_vec;
    logic start,done;

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

    // Clock generator: 10 ns period
    initial clk = 0;
    always #50 clk = ~clk;

    // Simulation control
    initial begin

	
        // Initialize
        reset = 1;
        #100;                  // keep reset high for two clock cycles
        reset = 0;
      
        $display("=== Starting Control Store Test ===");
        A_vec = 32'h04030201;
        B_vec = 32'h08070605;

        start = 1;
        $display("Start: %0d: ", start);
	@(posedge clk);
        $display("Busy: %0d: ", dut.busy);
	@(posedge clk);
	start = 0;
	
        $display("Start: %0d: ", start);	
	// Run long enough to fetch all ROM entries
	$display("Busy: %0d: ", dut.busy);

	repeat (24) begin
            @(posedge clk); 
            $display("Time %0t | PC = %0d | micro_word = %032b",
                     $time, dut.pc,dut.micro_word);
	    $display("Vec_sel: %0d", dut.vec_sel);
	    $display("A_vec_opA: %0d", dut.a_vec_opA);
            $display("B_vec_opA: %0d", dut.b_vec_opB);
	    $display("opA_sel: %0d", dut.opa_sel);
            $display("opB_sel: %0d", dut.opb_sel);

            $display("OpA: %0d", dut.opA);
            $display("OpB: %0d", dut.opB);
            
	    $display("div_sel: %0d", dut.div_sel);
            $display("mul_out: %0d", dut.mul_out);
	   
	    $display("sqrt_start: %0d", dut.sqrt_start); 
	    $display("sqrt_sel: %0d", dut.sqrt_sel);
	    $display("sqrt_indata: %0d", dut.sqrt_indata);
	    $display("sqrt_out: %0d", dut.sqrt_out);

            $display("accum_indata: %0d", dut.accum_indata);
            $display("accum_clr: %0d", dut.accum_clr);
            $display("accum_indata_clr: %0b", dut.accum_indata_clr);
	    $display("accum_out: %0d", dut.accum_out);

            $display("regOutA_sel: %0d", dut.regOutA_sel);
            $display("regOutB_sel: %0d", dut.regOutB_sel);

            $display("RegOutA_indata: %0d", dut.RegOutA_indata);
            $display("RegOutB_indata: %0d", dut.RegOutB_indata);


            $display("regOutA_wr_en: %0d", dut.regOutA_wr_en);
            $display("regOutA_wr_addr: %0d", dut.regOutA_wr_addr);
            $display("regOutA_rd_addr: %0d", dut.regOutA_rd_addr);



            $display("regOutB_wr_en: %0d", dut.regOutB_wr_en);
            $display("regOutB_wr_addr: %0d", dut.regOutB_wr_addr);
            $display("regOutB_rd_addr: %0d", dut.regOutB_rd_addr);


	    $display("RegOutA[0]: %0d", dut.RegOutA[0]);
            $display("RegOutA[1]: %0d", dut.RegOutA[1]);
            $display("RegOutA[2]: %0d", dut.RegOutA[2]);

            $display("RegOutB[0]: %0d", dut.RegOutB[0]);
            $display("RegOutB[1]: %0d", dut.RegOutB[1]);
            $display("RegOutB[2]: %0d", dut.RegOutB[2]);



            $display("OpA: %0d", dut.opA);
            $display("OpB: %0d", dut.opB);


	    $display("cosine_similarity: %0d", dut.cosine_similarity);


        end
        wait(done== 1);

	$display("=== Test Complete ===");
        $finish;
    end

endmodule

