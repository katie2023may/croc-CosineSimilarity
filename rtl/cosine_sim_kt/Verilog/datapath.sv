/*

- This is the Datapath module

- It connects all of the architetural/state elements of the Cosim microprogram

- The control signals are extracted DIRECTLY from the instruction encoding.
Subject to change: implement a separate 'Controller' module to generate control signals
Control signals:
(1) FPU_OP
(2) wr_en: reg file write enable (1 = WRITE --- 0 = READ)
(3) result_src: choose the data to write to the Reg File (populate wr_data)
(4) jump: choose (pc+1) or (pc=0)
(5) wr_2_RAM: implementation = TBD --> only set once result is ready to write back to CroC RAM
*/

`timescale 1 ns / 1 ps

module datapath(
    input logic clk,
    input logic rst_n,
    input logic en,                 // Start bit from CroC
    input logic [31:0] RAM_data,    // TODO: figure out how to transfer data from CroC RAM
    input logic [31:0] instr,       // Instr.
    output logic [7:0] pc,          // Next PC logic
    output logic [31:0] fpu_res,    // FPU result
    output logic [31:0] wr_data     // Data to write to Reg File
);

    /***** Next PC Logic *****/
    logic [3:0] pc_next;

    // PC --> Next PC 
    pc_en #(4) pc (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .d(pc_next),
        .q(pc)
    )

    // Next PC logic
    pc_mux #(4) pcMux (
        .pc(pc),
        .jump(instr[0]),                    // TODO: fix indexing
        .pc_next(pc_next)
    );    

    /***** Control Store Logic *****/
    control_store #(4) imem (
        .pc(pc),
        .instr(instr)
    );

    /***** Reg File Logic *****/
    logic [31:0] src_1_data, src_2_data,    // Operands fed to the ALU

    reg_file rf(
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(instr[1]),                   // TODO: fix indexing
        .wr_data(wr_data),                  // Take data from EITHER (FPU) OR (CroC RAM)
        .src_1_addr(instr[2:0]),            // TODO: fix indexing
        .src_2_addr(instr[4:2]),            // TODO: fix indexing
        .dest_reg(instr[6:4]),              // TODO: fix indexing
        .src_1_data(src_1_data),
        .src_2_data(src_2_data)
    );

    /***** Floating Point Arithmetic Unit *****/
    fpu FPU (
        .a(src_1_data),
        .b(src_2_data),
        .fpu_control(instr[4:1]),       // TODO: fix indexing
        .fpu_res(fpu_res)
    );

    // Write Back Mux
    wb_mux wbMux (
        .fpu_res(fpu_res),
        .RAM_data(RAM_data),
        .result_src(instr[1]),          // TODO: fix indexing
        .wr_data(wr_data)
    );

endmodule