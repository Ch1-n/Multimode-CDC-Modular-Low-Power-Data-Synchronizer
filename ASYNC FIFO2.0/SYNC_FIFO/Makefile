all: com sim dve

com:
	vcs -sverilog -debug_all -timescale=1ns/1ps -f file.list

sim:
	./simv

dve:
	dve -vpd vcdplus.vpd &
