    // FSM Implementation of cosine similarity algorithm
    // Git Push test from VSCODE

    `timescale 1ns / 1ps

    module cosine_sim #(
        parameter W = 5                         // Width of the input vectors
    ) (
        input logic clk,                        // Clock signal
        input logic rst_n,                      // Asynchronous, active low reset
        input logic start,                      // Start signal to trigger computation
        input logic signed [31:0] vec_a [W-1:0],       // Input Vector A
        input logic signed [31:0] vec_b [W-1:0],       // Input Vector B
        output logic signed [31:0] similarity,         // Output cosine similarity result
	output logic [2:0] index,
	output logic [2:0] state,
	output logic [31:0] dot_prod_accum,
	output logic [31:0] dot_prod,
	output logic [31:0] dot_prod_o,
        output logic valid                      // Output valid signal
    );

    //logic [2:0] index;          // Index to access vector elements

    /******************** Instantiating COMPUTING modules *******************************/
    // TODO: Big idea --> Update sub-module inputs sequentially - Compute sub-module outputs combinationally - Update top-level outputs sequentially
    // TODO: Instatitate IP modules
    // TODO: Add additional reg/wire if needed
    
    //Internal reg. for intermediate calc. INPUT/OUTPUT
   // logic [31:0] dot_prod_accum;
   // logic [31:0] dot_prod;
    logic [31:0] div_o;
    logic [31:0] den_o;
    logic [31:0] mag_a_accum, mag_b_accum;
    //logic [31:0] dot_prod_o;
    logic [31:0] mag_a, mag_b;
    logic [31:0] mag_a_sqrt, mag_b_sqrt; 
    logic [31:0] mag_a_o, mag_b_o;
    logic [31:0] mag_a_sqrt_o, mag_b_sqrt_o;

    /******************** Instantiating COMPUTING modules *******************************/

    // Multiplier for dot product (a[i] * b[i])
    FloatingMultiplication #(.XLEN(32)) u_mult_dot (.A(vec_a[index]),.B(vec_b[index]),.result(dot_prod_o), .clk(clk)); 

    // Multiplier for magnitude of A (a[i] * a[i])
    FloatingMultiplication #(.XLEN(32)) u_mult_mag_a (.A(vec_a[index]),.B(vec_a[index]),.result(mag_a_o), .clk(clk));

    // Multiplier for magnitude of B (b[i] * b[i])
    FloatingMultiplication #(.XLEN(32)) u_mult_mag_b (.A(vec_b[index]),.B(vec_b[index]),.result(mag_b_o), .clk(clk));

    // Adder for dot product accumulation
    FloatingAddition #(.XLEN(32)) u_add_dot (.A(dot_prod),.B(dot_prod_o),.result(dot_prod_accum));

    // Adder for magnitude A accumulation
    FloatingAddition #(.XLEN(32)) u_add_mag_a (.A(mag_a),.B(mag_a_o),.result(mag_a_accum));

    // Adder for magnitude B accumulation
    FloatingAddition #(.XLEN(32)) u_add_mag_b (.A(mag_b),.B(mag_b_o),.result(mag_b_accum));

    // Square root for magnitude A
    FloatingSqrt #(.XLEN(32)) u_sqrt_a (.A(mag_a_accum),.result(mag_a_sqrt_o), .clk(), .overflow(), .underflow(), .exception());

    // Square root for magnitude B
    FloatingSqrt #(.XLEN(32)) u_sqrt_b (.A(mag_b_accum),.result(mag_b_sqrt_o), .clk(), .overflow(), .underflow(), .exception());

    // Multiplier for denominator (sqrtA * sqrtB)
    FloatingMultiplication #(.XLEN(32)) u_mult_den (.A(mag_a_sqrt),.B(mag_b_sqrt),.result(den_o), .clk(clk));

    // Divider for final similarity
    FloatingDivision #(.XLEN(32)) u_div (.A(dot_prod),.B(den_o),.result(div_o), .zero_division(), .clk(clk));


    /******************************* FSM ********************************************/
    // FSM state definitions
/*    typedef enum logic [2:0] {
        IDLE,
        DOT,
        MAG_A,
        MAG_B,
        SQRT,
        DIV,
        DONE
    } state_t;
*/

//    state_t state, next_state;          // State reg.

    localparam IDLE = 3'd0;
    localparam DOT = 3'd1;
    localparam MAG_A = 3'd2;
    localparam MAG_B = 3'd3;
    localparam SQRT = 3'd4;
    localparam DIV = 3'd5;
    localparam DONE = 3'd6;

    logic [2:0]  next_state;

    // FSM: Sequential state trans. and output logic
    always_ff @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            dot_prod <= 32'd0;
            mag_a <= 32'd0;
            mag_b <= 32'd0;
            mag_a_sqrt <= 32'd0;
            mag_b_sqrt <= 32'd0;
            index <= 3'd0;
            // Output signals
            similarity <= 32'd0;
//	    dot_prod_accum <= 32'd0;
//	    mag_a_accum <= 32'd0;
//	    mag_b_accum <= 32'd0;
//	    dot_prod_o <= 32'd0;
//	    mag_a_o <= 32'd0;
//	    mag_b_o <= 32'd0;
//	    mag_a_sqrt_o <= 32'd0;
//	    mag_b_sqrt_o <= 32'd0;
//	    div_o <= 32'd0;
//	    den_o <= 32'd0;
            valid <= 1'b0;
        end 
        
        else begin
            state <= next_state;
            valid <= 1'b0;              // Default to 1'b0;

            // TODO: Write the seq. logic for each state for each computation step (dot, mag, sqrt, div)
            case (state)
		IDLE : begin 
		        index <= 3'd0;   // Reset index
			dot_prod <= 32'd0;
			mag_a <= 32'd0;
			mag_b <= 32'd0;
		end
                DOT : begin
                    // TODO: Update the I/O of dot_prod modueland increment index
		    dot_prod <= dot_prod_accum;
		    if (index == W-1) begin
			index <= 3'd0;
		    end else begin
		    	index <= index + 1;
	    	    end
                end

                MAG_A : begin
                    // TODO: Update the I/O of vecA_Mag module and increment index
		    mag_a <= mag_a_accum;
		    if (index == W-1) begin
           		index <= 3'd0;
		    end else begin
		    	index <= index + 3'd1;
	            end
	        end

                MAG_B : begin
                    // TODO: Update the I/O of vecB_Mag module and incr. index
                    mag_b <= mag_b_accum;
		    if (index == W-1) begin
			index <= 3'd0;	    
		    end else begin
			index <= index + 3'd1;
		    end
	        end

                SQRT : begin
                    // TODO: Update the I/O of the sqrt module and incr. index
                    mag_a_sqrt <= mag_a_sqrt_o;
		    mag_b_sqrt <= mag_b_sqrt_o;
	            index <= index + 3'd1; 
	        end

                DIV : begin
                    // TODO: Update the I/O of the div module and incr. index
                    similarity <= div_o;                // Output update
                end

                DONE : valid <= 1'b1;   // Assert valid --> Compuation = DONE

                default : begin
                    // TODO: add more actions if needed
                    valid <= 1'b0;
                end
            endcase

//	    $display("\n \n Current state: %d", state);
//	    $display("Next state: %d", next_state);
//	    $display("start: %b \n \n", start);
        end
    end

    // FSM: Comb. logic for next state
    always_comb begin
//        next_state = IDLE;
	    case (state)
		
    		IDLE : begin
			next_state = (start == 1'b1)? DOT : IDLE;
		end
		DOT : begin
		        next_state = (index == W-1)? MAG_A : DOT;
//			if (next_state == MAG_A) index = 0;
		end
		MAG_A : begin
		       	next_state = (index == W-1)? MAG_B : MAG_A;
//			if (next_state == MAG_B) index = 0;
		end
		MAG_B : begin
		       	next_state = (index == W-1)? SQRT : MAG_B;
//			if (next_state == SQRT) index = 0;
		end
		SQRT : begin 
			next_state = DIV;
		end
		DIV : begin 
			next_state = DONE;
		end
		DONE : begin 
			next_state = IDLE;
		end
            default : next_state = IDLE;
	    
        endcase
//	$display("\n \nCurrent state: %d", state);
//	$display("Next state: %d", next_state);
//	$display("start: %b\n \n", start);
    end

endmodule
