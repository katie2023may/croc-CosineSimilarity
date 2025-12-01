
//## Vector Input Function from OBI

package cosinehw_pkg;

  parameter int RegWidth = 32;
  parameter int AddressBits = 3;

  typedef struct packed {
    logic [RegWidth-1:0] avec;
    logic [RegWidth-1:0] bvec;
    logic [RegWidth-1:0] start;
    logic [RegWidth-1:0] cos;
    logic [RegWidth-1:0] done;
  } cosinehw_reg_t;

  typedef union packed {
    cosinehw_reg_t strct;
    logic [5*RegWidth-1:0] arr;
  } cosinehw_reg_union_t;

  localparam REG_AVEC_OFFSET  = 3'b000;
  localparam REG_BVEC_OFFSET  = 3'b001;
  localparam REG_START_OFFSET = 3'b010;
  localparam REG_COS_OFFSET   = 3'b011;
  localparam REG_DONE_OFFSET  = 3'b100;

  localparam cosinehw_reg_union_t register_default = '0;

endpackage;

