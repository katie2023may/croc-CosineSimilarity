    // FSM Implementation of cosine similarity algorithm

    `timescale 1ns / 1ps

    module cosime_sim #(
        parameter W = 5                         // Width of the input vectors
    ) (
        input logic clk,                        // Clock signal
        input logic rst_n,                      // Asynchronous, active low reset
        input logic start,                      // Start signal to trigger computation
        input logic [31:0] vec_a [W-1:0],       // Input Vector A
        input logic [31:0] vec_b [W-1:0],       // Input Vector B
        output logic [31:0] similarity,         // Output cosine similarity result
        output logic valid                      // Output valid signal
    );

    logic [2:0] index;          // Index to access vector elements

    /******************** Instantiating COMPUTING modules *******************************/
    // TODO: Big idea --> Update sub-module inputs sequentially - Compute sub-module outputs combinationally - Update top-level outputs sequentially
    // TODO: Instatitate IP modules
    // TODO: Add additional reg/wire if needed
    
    //Internal reg. for intermediate calc. INPUT/OUTPUT
    logic [31:0] dot_prod_accum;
    logic [31:0] div_o;
    logic [31:0] den_o;
    logic [31:0] mag_a_accum, mag_b_accum;
    logic [31:0] dot_prod_o;
    logic [31:0] mag_a, mag_b;
    logic [31:0] mag_a_sqrt, mag_b_sqrt; 
    logic [31:0] mag_a_o, mag_b_o;
    logic [31:0] mag_a_sqrt_o, mag_b_sqrt_o;

    /******************** Instantiating COMPUTING modules *******************************/

    // Multiplier for dot product (a[i] * b[i])
    multiplier u_mult_dot (.a(vec_a[index]),.b(vec_b[index]),.out(dot_prod_o));  

    // Multiplier for magnitude of A (a[i] * a[i])
    multiplier u_mult_mag_a (.a(vec_a[index]),.b(vec_a[index]),.out(mag_a_o));

    // Multiplier for magnitude of B (b[i] * b[i])
    multiplier u_mult_mag_b (.a(vec_b[index]),.b(vec_b[index]),.out(mag_b_o));

    // Adder for dot product accumulation
    adder u_add_dot (.a(dot_prod),.b(dot_prod_o),.out(dot_prod_accum));

    // Adder for magnitude A accumulation
    adder u_add_mag_a (.a(mag_a),.b(mag_a_o),.out(mag_a_accum));

    // Adder for magnitude B accumulation
    adder u_add_mag_b (.a(mag_b),.b(mag_b_o),.out(mag_b_accum));

    // Square root for magnitude A
    sqrt u_sqrt_a (.in(mag_a_accum),.out(mag_a_sqrt_o));

    // Square root for magnitude B
    sqrt u_sqrt_b (.in(mag_b_accum),.out(mag_b_sqrt_o));

    // Multiplier for denominator (sqrtA * sqrtB)
    multiplier u_mult_den (.a(mag_a_sqrt),.b(mag_b_sqrt),.out(den_o));

    // Divider for final similarity
    divider u_div (.num(dot_prod),.den(den_o),.out(div_o));


    /******************************* FSM ********************************************/
    // FSM state definitions
    typedef enum logic [2:0] {
        IDLE,
        DOT,
        MAG_A,
        MAG_B,
        SQRT,
        DIV,
        DONE
    } state_t;

    state_t state, next_state;          // State reg.

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
	    dot_prod_accum <= 32'd0;
	    mag_a_accum <= 32'd0;
	    mag_b_accum <= 32'd0;
	    dot_prod_o <= 32'd0;
	    mag_a_o <= 32'd0;
	    mag_b_o <= 32'd0;
	    mag_a_sqrt_o <= 32'd0;
	    mag_b_sqrt_o <= 32'd0;
	    div_o <= 32'd0;
	    den_o <= 32'd0;
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
		    index <= index + 1;
                end

                MAG_A : begin
                    // TODO: Update the I/O of vecA_Mag module and increment index
                    mag_a <= mag_a_accum;
		    index <= index + 1;
	        end

                MAB_B : begin
                    // TODO: Update the I/O of vecB_Mag module and incr. index
                    mag_b <= mag_b_accum;
		    index <= index + 1;
	       end

                SQRT : begin
                    // TODO: Update the I/O of the sqrt module and incr. index
                    mag_a_sqrt <= mag_a_sqrt_o;
		    mag_b_sqrt <= mag_b_sqrt_o;
	            index = index + 1; 
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
        end
    end

    // FSM: Comb. logic for next state
    always_comb begin
        case (state)
		IDLE : begin
			next_state = (start == 1'b1)? DOT : IDLE;
		end
		DOT : begin
		        next_state = (index == W-1)? MAG_A : DOT;
			if (next_state == MAG_A) index = 0;
		end
		MAG_A : begin
		       	next_state = (index == W-1)? MAG_B : MAG_A;
			if (next_state == MAG_B) index = 0;
		end
		MAG_B : begin
		       	next_state = (index == W-1)? SQRT : MAG_B;
			if (next_state == ) index = 0;
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
    end

endmodule
