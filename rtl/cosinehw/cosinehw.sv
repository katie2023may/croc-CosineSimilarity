`include "common_cells/registers.svh"

// -----------------------------------------------------------------------------
// CORDIC Coprocessor Interface
// Models memory-mapped access between CPU and CORDIC hardware
// Inspired by mmreg.sv structure
// -----------------------------------------------------------------------------
module cosinehw #(
    parameter obi_pkg::obi_cfg_t ObiCfg = obi_pkg::ObiDefaultConfig,
    parameter type obi_req_t = logic,
    parameter type obi_rsp_t = logic
)(
   input  logic        clk_i,
   input  logic        rst_ni,

   input  obi_req_t    obi_req_i,
   output obi_rsp_t    obi_rsp_o
);

   import cosinehw_pkg::*;

   // --------------------------------------------------------------------------
   // Internal signals
   // --------------------------------------------------------------------------
   logic [ObiCfg.DataWidth-1:0] rsp_data;
   logic                        valid_d, valid_q;
   logic                        err;
   logic                        w_err_d, w_err_q;
   logic [AddressBits-1:0]      word_addr_d, word_addr_q;
   logic [ObiCfg.IdWidth-1:0]   id_d, id_q;
   logic                        we_d, we_q;
   logic                        req_d, req_q;

   localparam ObiCfg_DataWidth = {ObiCfg.DataWidth{1'b0}};

   // --------------------------------------------------------------------------
   // OBI Response
   // --------------------------------------------------------------------------
   always_comb begin
      obi_rsp_o.r.rdata      = rsp_data;
      obi_rsp_o.r.rid        = id_q;
      obi_rsp_o.r.err        = err;
      obi_rsp_o.r.r_optional = '0;
      obi_rsp_o.gnt          = obi_req_i.req;
      obi_rsp_o.rvalid       = valid_q;
   end

   // --------------------------------------------------------------------------
   // Request handling
   // --------------------------------------------------------------------------
   assign id_d        = obi_req_i.a.aid;
   assign valid_d     = obi_req_i.req;
   assign word_addr_d = obi_req_i.a.addr[AddressBits+2:2];
   assign we_d        = obi_req_i.a.we;
   assign req_d       = obi_req_i.req;

   `FF(id_q, id_d, '0, clk_i, rst_ni)
   `FF(valid_q, valid_d, '0, clk_i, rst_ni)
   `FF(word_addr_q, word_addr_d, '0, clk_i, rst_ni)
   `FF(we_q, we_d, '0, clk_i, rst_ni)
   `FF(w_err_q, w_err_d, '0, clk_i, rst_ni)
   `FF(req_q, req_d, '0, clk_i, rst_ni)

   // Memory mapped registers
   cosinehw_reg_union_t reg_d, reg_q;

   // --------------------------------------------------------------------------
   // OBI Read/Write handling
   // --------------------------------------------------------------------------
   always_comb 
    begin
      err      = w_err_q;
      w_err_d  = 1'b0;
      rsp_data = ObiCfg_DataWidth; // should be 32 bits / ObiCfg.DataWidth size
      reg_d    = reg_q; // default no change
      
      reg_d.strct.done[0] = done_cos;      // bit 0 = done flag
      reg_d.strct.cos     = cosine_similarity;  // *** INCORRECT PLS CHANGE ***
      //$display("This is done cos: %0d ", done_cos);
      // -----------------------------------------------------
      // Software writes
      // -----------------------------------------------------
     // $display("INSIDE SOFTWARE WRITES!! %b", w_err_q);
      //$display("INSIDE SOFTWARE WRITES!! ");
      if (obi_req_i.req & obi_req_i.a.we & obi_req_i.a.be[0]) begin
         w_err_d = 1'b0;
	// $display("Writing to Case: %b, ", word_addr_d);
         case (word_addr_d)
		 REG_AVEC_OFFSET: begin
			 reg_d.strct.avec = obi_req_i.a.wdata[RegWidth-1:0];
		//	 $display("AVEC WRITE DATA %h ", reg_d.strct.avec);
		 end
		 REG_BVEC_OFFSET:begin
			 reg_d.strct.bvec = obi_req_i.a.wdata[RegWidth-1:0];
                        // $display("BVEC WRITE DATA %h ", reg_d.strct.bvec);
		 end	 
		 REG_START_OFFSET: begin
			 reg_d.strct.start = obi_req_i.a.wdata[RegWidth-1:0];
			 //$display("START WRITE DATA %h ", reg_d.strct.start);
		end 
		REG_COS_OFFSET:begin
		       	reg_d.strct.cos = obi_req_i.a.wdata[RegWidth-1:0];
			//$display("COS WRITE DATA %h ", reg_d.strct.cos);
		end
		REG_DONE_OFFSET:begin
                        reg_d.strct.done = obi_req_i.a.wdata[RegWidth-1:0];
                        //$display("DONE WRITE DATA %h ", reg_q.strct.done);

		end
           default: 
             begin
              w_err_d = 1'b1;
             end
         endcase
      end

      // -----------------------------------------------------
      // Software reads
      // -----------------------------------------------------
      if (req_q & ~we_q) begin
         err = 1'b0;
         case (word_addr_q)
		REG_AVEC_OFFSET:begin
			 rsp_data[RegWidth-1:0] = reg_q.strct.avec;
			// $display("AVEC READ DATA %h ", reg_q.strct.avec);
		end
                REG_BVEC_OFFSET: begin
		        rsp_data[RegWidth-1:0] = reg_q.strct.bvec;
	                 //$display("BVEC READ DATA %h ", reg_q.strct.bvec);
		end
		REG_START_OFFSET: begin 
	       		rsp_data[RegWidth-1:0] = reg_q.strct.start;
			//$display("START READ DATA %h ", reg_q.strct.start);
		end
		REG_COS_OFFSET:begin
		      	rsp_data[RegWidth-1:0] = reg_q.strct.cos;
			//$display("COS READ DATA %h ", reg_q.strct.cos);
		end
                REG_DONE_OFFSET:begin
                        rsp_data[RegWidth-1:0] = reg_q.strct.done;
                        //$display("DONE READ DATA %h ", reg_q.strct.done);

                end

           default:          err = 1'b1;
         endcase
      end
   end

   // --------------------------------------------------------------------------
   // Control logic
   // --------------------------------------------------------------------------
   logic [31:0] A_vec, B_vec;
   logic done_cos;
   logic start_pulse;
   assign A_vec  = reg_q.strct.avec;
   assign B_vec  = reg_q.strct.bvec;
   logic  [15:0] cosine_similarity;
   // Detect start pulse (software sets bit0 high)
   assign start_pulse = reg_q.strct.start[0];
  
   control_store i_cosine_sim (
      .clk(clk_i),
      .reset(rst_ni),
      .start(start_pulse),
      .A_vec(A_vec),
      .B_vec(B_vec),
      .cosine_similarity(cosine_similarity),
      .done(done_cos)
   );

   // --------------------------------------------------------------------------
   // Register update
   // --------------------------------------------------------------------------
   `FF(reg_q.arr, reg_d.arr, cosinehw_pkg::register_default, clk_i, rst_ni)

endmodule


