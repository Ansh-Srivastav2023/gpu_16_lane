# Simulator
SIM ?= verilator

# TOPLEVEL_LANG = verilog
MODULE = test

TOPLEVEL = gpu_top

PROJ_ROOT := $(abspath ..)

VERILOG_SOURCES = $(wildcard $(PROJ_ROOT)/src/*.v)

EXTRA_ARGS += --trace --trace-structs 
EXTRA_ARGS += --timing -quiet

WAVES = 1

include $(shell cocotb-config --makefiles)/Makefile.sim
