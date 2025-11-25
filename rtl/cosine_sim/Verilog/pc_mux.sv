/*

Next Address Logic  for the uprogram

This is the PC mux module to select:
(0) PC = PC + 1
(1) PC = 0 --> points to mem[0]  --> jumps back to do computation for the next index
sel bit: jump

*/

module pc_mux #(parameter W = 4) (
    input logic [W-1:0] pc,
    input logic jump,
    output logic [W-1:0] pc_next
);

    logic [W-1:0] pc_plus_1;
    assign pc_plus_1 = pc + 8'd1;

    assign pc_next = (jump == 1'b1)? 8'd0 : pc_plus_1;

endmodule