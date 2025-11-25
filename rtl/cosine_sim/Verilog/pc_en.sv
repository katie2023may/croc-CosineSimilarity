/*

This is the Program Counter (CSAR) module

For this implementation, we only define 13 instructions ---> log_2(13) ~ 3.7 --> Needs 4 bits

*/

module pc_en 
#(parameter W = 4) (
    input logic clk,
    input logic rst_n,        // Asyn, active low reset
    input logic en,           // Start signal from CroC --- Mem-mapped Reg
    input logic [W-1:0] d,    // Current PC
    output logic [W-1:0] q    // Next PC
    );

    always_ff (posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) q <= '0;
        else if (en == 1'b1) q <= d;
    end

endmodule