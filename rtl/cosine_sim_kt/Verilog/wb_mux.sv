/*

This is the Write Back Mux to choose where to write the data to:
(0) Write to CroC Ram
(1) Write to Reg File
Sel bit: result_src
Destination: wr_data

*/

`timescale 1 ns / 1 ps

module wb_mux (
    input logic [31:0] fpu_res,
    input logic [31:0] RAM_data,
    input logic result_src,
    output logic [31:0] wr_data,               // Data to be written back to Reg File
);

    assign wr_data = (result_src == 1'b1)? RAM_data : alu_res;

endmodule