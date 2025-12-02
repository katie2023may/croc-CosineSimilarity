# Variables
IVERILOG = iverilog
VVP      = vvp
# Flist    = flist.txt
OUT      = a.out

# Default target
sim_directed:
	$(IVERILOG) -g2012 control_store.sv tb_control_store_directed.sv
	$(VVP) $(OUT)

clean:
	rm -f $(OUT)

