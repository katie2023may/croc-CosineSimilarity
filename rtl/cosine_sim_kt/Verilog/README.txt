


## Dot Product Accelerator (a_vec[n] * b_vec[n] = dp)
##
## Where:  a/b_vec[i] = 8 bit signed integer 
##                        6 5 4 3 2 1 0 
##                    =  s 2 2 2 2 2 2   (range: +/- 127)
##         dp = 16 bit signed integer
##
##         input:  a_vec[3:0] = a1_vec[3:0] 
##                 a_vec[7:4] = a2_vec[3:0]  (option2) 
##                 b_vec[3:0] = b1_vec[3:0]
##                 b_vec[7:4] = b2_vec[3:0]  (option2)

## option 1:  4 component Dot Product Accelerator
## option 2:  8 component Dot Product Accelerator

## Dot Product Accelerator Function

## option 1: dp_ab = (a_vec[3]*b_vec[3]) + (a_vec[2]*b_vec[2]) + (a_vec[1]*b_vec[1]) + (a_vec[0]*b_vec[0])
## option 2: ... from 7 - 0


## Cosine Accelerator Function

## option 1: ca = dp_ab / sqrt(dp_aa) * sqrt(dp_bb) 
## this requires both a division and sqrt functions will determine if libraries support



Accelerator Steps
## 1 load a_vec
## 2 load b_vec
## 3  accum = a_vec[0] * b_vec[0] 
## 4  accum += a_vec[1] * b_vec[1]
## 5  accum += a_vec[2] * b_vec[2]
## 6  accum += a_vec[3] * b_vec[3]
## 7 regOutA[2] = accum;  // AB Dot Product
## 8  accum = a_vec[0] * a_vec[0]
## 9  accum += a_vec[1] * a_vec[1]
## 10 accum += a_vec[2] * a_vec[2]
## 11 accum += a_vec[3] * a_vec[3]
## 12 regOutA[0] = accum; // A Dot Product
## 13 accum = b_vec[0] * b_vec[0]
## 14 accum += b_vec[1] * b_vec[1]
## 15 accum += b_vec[2] * b_vec[2]
## 16 accum += b_vec[3] * b_vec[3]
## 17 regOutB[0] = accum; // B Dot Product
## 18 sqrt(regOutA[0]) //Start sqrt
## 19 if sqrt_done then regOutA[1] = sqrtOut
## 20 sqrt(regOutB[0]) //Start sqrt
## 21 if sqrt_done then regOutB[1] = sqrtOut
## 22 regOutB[2] = regOutA[1] * regOutB[1] //denominator
## 23 accum = regOutA[2] / regOutB[2]
## 24 cosineSim = accum

Control Store Definition
##  0  nxt_uPC[0]
##  1  nxt_uPC[1]
##  2  nxt_uPC[2]
##  3  nxt_uPC[3]
##  4  nxt_uPC[4]
##  5  nxt_uPC[5]
##  6  a_vec_wr_en
##  7  b_vec_wr_en
##  8  vec_sel[0]
##  9  vec_sel[1]
##  10 opa_sel[0]
##  11 opa_sel[1]
##  12 opb_sel[0]
##  13 opb_sel[1]
##  14 div_sel
##  15 sqrt_sel
##  16 regOutA_sel[0]
##  17 regOutA_sel[1]
##  18 regOutB_sel[0]
##  19 regOutB_sel[1]
##  20 accum_clr
##  21 regOutA_wr_addr[0]
##  22 regOutA_wr_addr[1]
##  23 regOutA_wr_en
##  24 regOutA_rd_addr[0]
##  25 regOutA_rd_addr[1]
##  26 regOutB_wr_addr[0]
##  27 regOutB_wr_addr[1]
##  28 regOutB_wr_en
##  29 regOutB_rd_addr[0]
##  30 regOutB_rd_addr[1]
##  31 sqrt_start

Microword Program
        B  reg A  reg a reg  s  b a     ba nxt
        rd  B  rd  A  c out  qd s s  v   v upc
            wr     wr l B A  ri e e  e   e
           e      e   r sel  tv l l  c   n
# 1 # 0 00 000 00 000 0 0000 00 0000 00 01 000001
# 2 # 0 00 000 00 000 1 0000 00 0000 00 10 000010
# 3 # 0 00 000 00 000 0 0000 00 0000 00 00 000011
# 4 # 0 00 000 00 000 0 0000 00 0000 01 00 000100
# 5 # 0 00 000 00 000 0 0000 00 0000 10 00 000101
# 6 # 0 00 000 00 000 0 0000 00 0000 11 00 000110
# 7 # 0 00 000 00 110 1 0001 00 0000 00 00 000111   ## 7 regOutA[2] = accum;  // AB Dot Product

# 8 # 0 00 000 00 000 0 0000 00 0100 00 00 001000
# 9 # 0 00 000 00 000 0 0000 00 0100 01 00 001001
# 10# 0 00 000 00 000 0 0000 00 0100 10 00 001010
# 11# 0 00 000 00 000 0 0000 00 0100 11 00 001011
# 12# 0 00 000 00 100 1 0001 00 0000 00 00 001100  ## 12 regOutA[0] = accum; // A Dot Product

# 13# 0 00 000 00 000 0 0000 00 0001 00 00 001101
# 14# 0 00 000 00 000 0 0000 00 0001 01 00 001110
# 15# 0 00 000 00 000 0 0000 00 0001 10 00 001111
# 16# 0 00 000 00 000 0 0000 00 0001 11 00 010000
# 17# 0 00 100 00 000 1 0100 00 0000 00 00 010001  ## 17 regOutB[0] = accum; // B Dot Product 

# 18# 1 00 000 00 000 0 0010 00 0000 00 00 010001  ## 18 sqrt(regOutA[0]) //Start sqrt
# 19# 0 00 000 00 101 0 0010 00 0000 00 00 010010  ## 19 if sqrt_done then regOutA[1] = sqrtOut

# 20# 1 00 000 00 000 0 1000 10 0000 00 00 010010  ## 20 sqrt(regOutB[0]) //Start sqrt
# 21# 0 00 101 00 000 0 1000 10 0000 00 00 010011  ## 21 if sqrt_done then regOutB[1] = sqrtOut

# 22# 0 01 110 01 000 1 0000 10 1010 00 00 010100  ## 22 regOutB[2] = regOutA[1] * regOutB[1] //denominator
# 23# 0 10 110 10 000 0 0000 01 1010 00 00 010100  ## 23 accum = regOutA[2] / regOutB[2]

                                                   ## 24 cosineSim = accum






## Vector Input Function from OBI

package cordichw_pkg;

  parameter int RegWidth = 32;
  parameter int AddressBits = 2;

  typedef struct packed {
    logic [RegWidth-1:0] a_vec;
    logic [RegWidth-1:0] b_vec;
    logic [RegWidth-1:0] start;
    logic [RegWidth-1:0] dp_ab;
  } cordichw_reg_t;

  typedef union packed {
    cordichw_reg_t strct;
    logic [4*RegWidth-1:0] arr;
  } cordichw_reg_union_t;

  localparam REG_AVEC_OFFSET = 2'b00;
  localparam REG_BVEC_OFFSET  = 2'b01;
  localparam REG_START_OFFSET  = 2'b10;
  localparam REG_DPAB_OFFSET  = 2'b11;

  localparam cordichw_reg_union_t register_default = '0;

endpackage;

