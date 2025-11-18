    // FSM Implementation of cosine similarity algorithm

    `timescale 1ns / 1ps

    module cosime_sim #(
        parameter W = 5                         // Width of the input vectors
    ) (
        input logic clk,                        // Clock signal
        input logic rst_n,                      // Asynchronous, active low reset
        input loigc start,                      // Start signal to trigger computation
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
    logic [31:0] add_o;
    logic [31:0] dot_prod_o;
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
    adder u_add_dot (.a(dot_prod),.b(dot_prod_o),.out(add_o));

// Adder for magnitude A accumulation
    adder u_add_mag_a (.a(mag_a),.b(mag_a_o),.out(add_o));

// Adder for magnitude B accumulation
    adder u_add_mag_b (.a(mag_b),.b(mag_b_o),.out(add_o));

// Square root for magnitude A
    sqrt u_sqrt_a (.in(mag_a),.out(mag_a_sqrt_o));

// Square root for magnitude B
    sqrt u_sqrt_b (.in(mag_b),.out(mag_b_sqrt_o));

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
            valid <= 1'b0;
        end 
        
        else begin
            state <= next_state;
            valid <= 1'b0;              // Default to 1'b0;

            // TODO: Write the seq. logic for each state for each computation step (dot, mag, sqrt, div)
            case (state)
                IDLE : index <= 3'd0;   // Reset index

                DOT : begin
                    // TODO: Update the I/O of dot_prod modueland increment index
                end

                MAG_A : begin
                    // TODO: Update the I/O of vecA_Mag module and increment index
                end

                MAB_B : begin
                    // TODO: Update the I/O of vecB_Mag module and incr. index
                end

                SQRT : begin
                    // TODO: Update the I/O of the sqrt module and incr. index
                end

                DIV : begin
                    // TODO: Update the I/O of the div module and incr. index
                    // similarity <= div_result;                // Output update
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
            IDLE : next_state = (start == 1'b1)? DOT : IDLE;
            DOT : next_state = (index == W-1)? MAG_A : DOT;
            MAG_A : next_state = (index == W-1)? MAG_B : MAG_B;
            MAG_B : next_state = (index == W-1)? SQRT : MAG_B;
            SQRT : next_state = DIV;
            DIV : next_state = DONE;
            DONE : next_state = IDLE;
            default : nxt_state = IDLE;
        endcase
    end

endmodule
