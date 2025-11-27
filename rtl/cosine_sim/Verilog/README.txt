### DOCUMENTATION for Cosine Similarity Algorithm Implementation in System Verilog ###

1) OVERVIEW: SINGLE-CYCLE ARCHITECTURE
- Instruction format:
- State element
- FPU functionality:
- CroC <---> Co-processor communication
    + CroC reads/writes data via OBI
    + Defines 32-bit wide vectors of length 5 ---> writes each index of a pair of vectors sequentially (NOT simultaneously)
    --> This removes the index logic within the SysVerilog implementation of CoSim
    + CoSim reads the values from the two input vectors (index by index), then write back the 32-bit cosne similarity result

2) FULL UPROGRAM INSTRUCTION FLOW 
### APPROACH 1 ###
### Phase 1 ###: Compute Numerator and Denominator
# Phase 1a: Numerator
load a_i            
load b_i
mul a_i, b_i --> mul_result
add numerator, mul_result --> numerator     # Final result for Numerator

# Phase 1b: Part of the Denominator
mul a_i, a_i --> mul_result
add acc_a, mul_result --> acc_a
mul b_i, b_i --> mul_result
add acc_b, mul_result --> acc_b

# Phase 1c: jump back to instruction 0 and increment index
add index [mem[0xA]] --> index              # index = index + 1
beq index 0x5, 0x0                          # if index == 0x5, pc = mem[0x0], else continue

### Phase 2 ###: Compute part of the Denominator
mul acc_a, acc_b ---> denominator
sqrt denominator ---> denominator

### Phase 3 ###: Compute the FINAL RESULT
div numerator, denominator --> result

### THIS IMPLEMENTATION REQUIRES EXTRA CONTROL SIGNAL ###

#####################################################################################
### OTHER APPROACH ###
Load all of the input vector entries (5 for vec_a & 5 for vec_b = 10)
load a_0
load b_0
load a_1
load b_1
load a_2
load b_2
load a_3
load b_3
load a_4
load b_4

TBD

3) REGISTER FILE STRUCTURE
### APPROACH 1 ###
### Address : Value ###
0x0 : a_i
0x1 : b_i
0x2 : mul_result
0x3 : numerator
0x4 : denominator
0x5 : acc_a
0x6 : acc_b
0x7 : result
0x8 : index
0x9 : 0x0
0xA : 0x1
0xB : 0x4

### APPROACH 2 ###
0x0 : a_0
0x1 : a_1
0x2 : a_2
0x3 : a_3
0x4 : a_4
0x5 : b_0
0x6 : b_1
0x7 : b_2
0x8 : b_3
0x9 : b_4
0xA : mul_result
0xB : numerator
0xC : denominator
0xD : acc_a
0xE : acc_b
0xF : result
0x10 : index
0x11 : 0x0
0x12 : 0x1
0x13 : 0x4
0x14 : base_addr
0x15 : a_temp
0x16 : b_temp

4) Memory-mapped Registers

