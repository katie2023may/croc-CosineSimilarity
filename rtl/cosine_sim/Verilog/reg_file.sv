/*

This is the Reg file for the microgram to store intermediate values

Total needed register:

*/


module reg_file (
    input logic clk,
    input logic rst_n,                          // Async, active-low reset
    input logic wr_en,                          // Write enable signal
    input logic [31:0] wr_data,                 // Data to write to the dest. reg
    input logic [2:0] src_1_addr, src_2_addr,   // Addr. of src_1 and src_2
    input logic [2:0] dest_reg,                 // Addr. of dest. reg
    output logic [31:0] src_1_data, src_2_data  // Data read from src_1_addr and src_2_addr
);
    localparam REG_NUM = 12;                     // # of needed reg --- APPROACH 1
    // localparam REG_NUM = 20;                     // # of needed reg --- APPROACH 2  

    // Need 6 registers to store intermediate values --- Mem-mapped Regs
    logic [31:0] mem [REG_NUM - 1:0];             // 6 32-bit wide registers

    always_ff (posedge clk) begin
        if (wr_en == 1'b1) mem[dest_reg] <= wr_data;
    end

    assign src_1_data = (rst_n == 1'b0)? 32'd0 : mem[src_1_addr];
    assign src_2_data = (rst_n == 1'b0)? 32'd0 : mem[src_2_addr];

    /***** SIMULATION ONLY *****/
    // Clear all register locations
    integer i;

    initial begin
        for (i = 0; i < REG_NUM; i = i + 1) begin
            mem[i] = 32'd0;
        end

        // Init other reg
        mem[10] = 32'd0;        // Constant 0
        mem[11] = 32'd1;        // Constant 1
        mem[12] = 32'd4;        // Vector length - 1 = max index
    end

endmodule