/*

This is the Control Store to store instructions for the uprogram

*/

module control_store #(parameter W = 4) 
(
    input logic [W-1:0] pc,       // PC to traverse the instr. mem.
    output logic [31:0] instr     // Output the corresponding instruction
);

    logic [31:0] ROM [3:0];     // 13 32-bit wide instructions

    initial begin
        mem[0] = 0x00000000;
        mem[1] = 0x00000000;

        // Contine to mem[13]
        mem[13] = 0x00000000;
    end

    // Output the instr. that matches the pc index in ROM
    assign instr = ROM[pc];

endmodule