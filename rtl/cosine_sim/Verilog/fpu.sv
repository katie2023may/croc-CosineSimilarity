/*

This is the Floating Point Arithmetic Unit (acting as an ALU)

*/

`timescale 1 ns / 1 ps

module fpu (
    input logic [31:0] a, b,            // Input operands from Reg File
    input logic [3:0] fpu_control,      // Extract from instr.
    output logic [31:0] alu_res         // Computed Result
);

    // TODO: IMPLEMENTATION and MODULE-LEVEL TESTING

    always_comb begin
        case (fpu_control)
            // Set enable signal to select a specific FPU
        endcase
    end

endmodule