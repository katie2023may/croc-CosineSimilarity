/*

This is the Control Store to store instructions for the uprogram

*/
module control_store (
    input  logic        clk,
    input  logic        reset,
    input logic		start,
    output logic	done,
    input logic	[31:0]	A_vec,
    input logic [31:0]  B_vec,
    output logic [15:0] cosine_similarity

);

    // 24-entry ROM, 32 bits per entry
    logic [31:0] rom [0:25];

    // Program counter
    logic [4:0] pc;  // 5 bits → can hold 0..23

    //logic [31:0] A_vec, B_vec;

    logic [31:0] micro_word;

    // ROM initialization
    initial begin
/*
                     B regA regareg s ba   ba nxt
                     rd B rd A cout qdss v  v upc
                        wr   wrlB A riee e  e
                       e    e  rsel tvll c  n            */
        rom[0]  = 32'b00000000000100000000000001000001; // ROM[0]
        rom[1]  = 32'b00000000000100000000000010000010; // ROM[1]
        rom[2]  = 32'b00000000000000000000000000000011; // ROM[2]
        rom[3]  = 32'b00000000000000000000000100000100; // ROM[3]
        rom[4]  = 32'b00000000000000000000001000000101; // ROM[4]
        rom[5]  = 32'b00000000000000000000001100000110; // ROM[5]
        rom[6]  = 32'b00000000110100010000000000000111; // ROM[6]
        rom[7]  = 32'b00000000000000000001000000001000; // ROM[7]
        rom[8]  = 32'b00000000000000000001000100001001; // ROM[8]
        rom[9]  = 32'b00000000000000000001001000001010; // ROM[9]
        rom[10] = 32'b00000000000000000001001100001011; // ROM[10]
        rom[11] = 32'b00000000100100010000000000001100; // ROM[11]
        rom[12] = 32'b00000000000000000000010000001101; // ROM[12]
        rom[13] = 32'b00000000000000000000010100001110; // ROM[13]
        rom[14] = 32'b00000000000000000000011000001111; // ROM[14]
        rom[15] = 32'b00000000000000000000011100010000; // ROM[15]
        rom[16] = 32'b00010000000101000000000000010001; // ROM[16]
        rom[17] = 32'b10000000101000100000000000010001; // ROM[17]
        //rom[18] = 32'b00000000101000100000000000010010; // ROM[18]
        rom[18] = 32'b10010100000010001000000000010010; // ROM[19]
        //rom[20] = 32'b00010100000010001000000000010011; // ROM[20]
        rom[19] = 32'b00111001000100001010100000010100; // ROM[21]
        rom[20] = 32'b00111001000100001010100000010100; // ROM[21]

        rom[21] = 32'b01001010000000000110100000010100; // ROM[22]
        rom[22] = 32'b01011010000000000110100000010100; // ROM[22]
        rom[23] = 32'b01011010000000000110100000010100; // ROM[22]
        rom[24] = 32'b01011010000000000110100000010100; // ROM[22]
 
//	A_vec = 32'h04030201;
//	B_vec = 32'h08070605;
    end

    // --------------------------------------------------
    // Define micro-word as packed struct
    // --------------------------------------------------
        logic [5:0]  nxt_uPC;          // bits 0-5
        logic        a_vec_wr_en;      // bit 6
        logic        b_vec_wr_en;      // bit 7
        logic [1:0]  vec_sel;          // bits 8-9
        logic [1:0]  opa_sel;          // bits 10-11
        logic [1:0]  opb_sel;          // bits 12-13
        logic        div_sel;          // bit 14
        logic        sqrt_sel;         // bit 15
        logic [1:0]  regOutA_sel;      // bits 16-17
        logic [1:0]  regOutB_sel;      // bits 18-19
        logic        accum_clr;        // bit 20
        logic [1:0]  regOutA_wr_addr;  // bits 21-22
        logic        regOutA_wr_en;    // bit 23
        logic [1:0]  regOutA_rd_addr;  // bits 24-25
        logic [1:0]  regOutB_wr_addr;  // bits 26-27
        logic        regOutB_wr_en;    // bit 28
        logic [1:0]  regOutB_rd_addr;  // bits 29-30
        logic        sqrt_start;       // bit 31
 
	logic [7:0] A_vec_slice [0:3];  // 4 slices of 8 bits
        logic [7:0] B_vec_slice [0:3];

    logic [15:0] accum_reg;
    logic [15:0] RegOutA [2:0];
    logic [15:0] RegOutB [2:0];
    logic [7:0] a_vec_opA, b_vec_opB;
    logic [7:0] opA, opB;
    logic [15:0] RegOutA_rd_data, RegOutB_rd_data;
    logic [15:0] mul_out;
    logic [7:0] sqrt_indata, sqrt_out;
    logic [15:0] accum_out, accum_indata;
    logic [15:0] RegOutA_indata, RegOutB_indata;  
    logic [15:0] accum_indata_clr;

    logic busy;
    assign accum_indata_clr = {{15{accum_clr}}, accum_clr};

    // Step through microwords
    //assign loop = start;
    always_ff @(posedge clk or negedge reset) begin
       if (!reset) begin
            pc <= 0;
    	    busy <= 0;
	    done <= 0;
	    $display("This is pc %0d and busy %0d and done %0d: ", pc, busy, done);
       end else if ((pc < 5'd24) && (start || busy)) begin
	       busy <= 1;
               pc <= pc + 1;
	      // $display("This is start %0d: ", start);
	       $display("This is pc %0d, and busy %0d: ", pc, busy);
       end else begin
	       busy <= 0;
	       if (pc >= 24) done <= 1;
	      // $display("This is done: %0d: ", done);
	end
    end

    assign micro_word = rom[pc];

    assign nxt_uPC = micro_word[5:0];
    assign a_vec_wr_en = micro_word[6];
    assign b_vec_wr_en = micro_word[7];
    assign vec_sel = micro_word[9:8];
    assign opa_sel = micro_word[11:10];
    assign opb_sel = micro_word[13:12];
    assign div_sel = micro_word[14];
    assign sqrt_sel = micro_word[15];
    assign regOutA_sel = micro_word[17:16];
    assign regOutB_sel = micro_word[19:18];
    assign accum_clr = micro_word[20];
    assign regOutA_wr_addr = micro_word[22:21];
    assign regOutA_wr_en = micro_word[23];
    assign regOutA_rd_addr = micro_word[25:24];
    assign regOutB_wr_addr = micro_word[27:26];
    assign regOutB_wr_en = micro_word[28];
    assign regOutB_rd_addr = micro_word[30:29];
    assign sqrt_start = micro_word[31];

    assign A_vec_slice[0] = A_vec[7:0];
    assign A_vec_slice[1] = A_vec[15:8];
    assign A_vec_slice[2] = A_vec[23:16];
    assign A_vec_slice[3] = A_vec[31:24];

    assign B_vec_slice[0] = B_vec[7:0];
    assign B_vec_slice[1] = B_vec[15:8];
    assign B_vec_slice[2] = B_vec[23:16];
    assign B_vec_slice[3] = B_vec[31:24];


    always_comb begin
    	    a_vec_opA = A_vec_slice[vec_sel];
	   
    	    b_vec_opB = B_vec_slice[vec_sel];	    
	    case (opa_sel) 
		 2'b00: opA = a_vec_opA;
	         2'b01: opA = b_vec_opB;
		 2'b10: opA = RegOutA_rd_data; //fix later
		 2'b11: ;
		 default:opA = a_vec_opA;
            endcase
           
           case (opb_sel)
                 2'b00: opB = b_vec_opB;
                 2'b01: opB = a_vec_opA;
                 2'b10: opB = RegOutB_rd_data; //fix later
                 2'b11: ;
                 default:opA = a_vec_opA;
            endcase
            if (busy) $display("This is OpA %0d, this is opB %0d: ", opA, opB);
	    if (!div_sel) mul_out = opA * opB;
	    if ( div_sel) mul_out = (opA<<7) / opB;
	    if (busy) $display("This is mul_out: %0d ", mul_out);
	    if (pc == 23 ) begin
		    cosine_similarity = mul_out;
	    end
	    case (sqrt_sel)
		1'b0: sqrt_indata = RegOutA_rd_data; //fix later
		1'b1: sqrt_indata = RegOutB_rd_data; //fix later
	    endcase
	    sqrt_out = sqrt(sqrt_indata);
	    accum_indata = (mul_out + accum_out);
            accum_indata = (accum_indata) & (~accum_indata_clr);

	    case (regOutA_sel)
                 2'b00: RegOutA_indata = mul_out;
                 2'b01: RegOutA_indata = accum_out;
                 2'b10: RegOutA_indata = sqrt_out; //fix later
                 2'b11: ;
		 default: ;
	    endcase

            case (regOutB_sel)
                 2'b00: RegOutB_indata = mul_out;
                 2'b01: RegOutB_indata = accum_out;
                 2'b10: RegOutB_indata = sqrt_out; //fix later
                 2'b11: ;
                 default: ;
            endcase

    end

    always_ff @(posedge clk or negedge reset) begin
	if (!reset) begin
		accum_out<= 0;
	end else begin
	//	$display("The start bit: %0d: ", start);
		//accum_out <= accum_reg;
		//accum_reg <=  accum_indata;
		if (accum_clr) accum_out <= 0;
	        accum_out <= accum_indata;		
		if (regOutA_wr_en) RegOutA[regOutA_wr_addr] <= RegOutA_indata;
		if (regOutB_wr_en) RegOutB[regOutB_wr_addr] <= RegOutB_indata;
		RegOutA_rd_data <= RegOutA[regOutA_rd_addr];
                RegOutB_rd_data <= RegOutB[regOutB_rd_addr];

	end
    end

function automatic logic [7:0] sqrt (input logic [15:0] square);

    if      (square > 16384) sqrt = 128;
    else if (square > 8192)  sqrt = 90;

    else if (square >  4096) sqrt =  64;
    else if (square >  3969) sqrt =  63;
    else if (square >  3844) sqrt =  62;
    else if (square >  3721) sqrt =  61;
    else if (square >  3600) sqrt =  60;
    else if (square >  3481) sqrt =  59;
    else if (square >  3364) sqrt =  58;
    else if (square >  3249) sqrt =  57;
    else if (square >  3136) sqrt =  56;
    else if (square >  3025) sqrt =  55;
    else if (square >  2916) sqrt =  54;
    else if (square >  2809) sqrt =  53;
    else if (square >  2704) sqrt =  52;
    else if (square >  2601) sqrt =  51;
    else if (square >  2500) sqrt =  50;
    else if (square >  2401) sqrt =  49;
    else if (square >  2304) sqrt =  48;
    else if (square >  2209) sqrt =  47;
    else if (square >  2116) sqrt =  46;
    else if (square >  2025) sqrt =  45;
    else if (square >  1936) sqrt =  44;
    else if (square >  1849) sqrt =  43;
    else if (square >  1764) sqrt =  42;
    else if (square >  1681) sqrt =  41;
    else if (square >  1600) sqrt =  40;
    else if (square >  1521) sqrt =  39;
    else if (square >  1444) sqrt =  38;
    else if (square >  1369) sqrt =  37;
    else if (square >  1296) sqrt =  36;
    else if (square >  1225) sqrt =  35;
    else if (square >  1156) sqrt =  34;
    else if (square >  1089) sqrt =  33;
    else if (square >  1024) sqrt =  32;

    else if (square > 961)   sqrt = 31;
    else if (square > 900)   sqrt = 30;
    else if (square > 841)   sqrt = 29;
    else if (square > 784)   sqrt = 28;
    else if (square > 729)   sqrt = 27;
    else if (square > 676)   sqrt = 26;
    else if (square > 625)   sqrt = 25;
    else if (square > 576)   sqrt = 24;
    else if (square > 529)   sqrt = 23;
    else if (square > 484)   sqrt = 22;
    else if (square > 441)   sqrt = 21;
    else if (square > 400)   sqrt = 20;
    else if (square > 361)   sqrt = 19;
    else if (square > 324)   sqrt = 18;
    else if (square > 289)   sqrt = 17;
    else if (square > 256)   sqrt = 16;
    else if (square > 225)   sqrt = 15;
    else if (square > 196)   sqrt = 14;
    else if (square > 169)   sqrt = 13;
    else if (square > 144)   sqrt = 12;
    else if (square > 121)   sqrt = 11;
    else if (square > 100)   sqrt = 10;
    else if (square > 81)    sqrt = 9;
    else if (square > 64)    sqrt = 8;
    else if (square > 49)    sqrt = 7;
    else if (square > 36)    sqrt = 6;
    else if (square > 25)    sqrt = 5;
    else if (square > 16)    sqrt = 4;
    else if (square > 9)     sqrt = 3;
    else if (square > 4)     sqrt = 2;
    else if (square > 1)     sqrt = 1;
    else                     sqrt = 0;

endfunction





endmodule

