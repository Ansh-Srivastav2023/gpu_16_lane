TOP := gpu_tb
SRC := /media/anx/New_Volume/Importants/Verilog/gpu_16_lane/src/*.sv
MEM := /media/anx/New_Volume/Importants/Verilog/gpu_16_lane/hex/*.mem

FLAGS = --Wno-WIDTH --Wno-LATCH --Wno-IMPLICIT

all: slang_test build

slang_test:
	slang $(SRC)

build:
	@echo "Running V E R I L A T O R...."
	@cp $(MEM) ./
	@verilator --sv --binary $(SRC) --top $(TOP) $(FLAGS) --trace --quiet
	@./obj_dir/V$(TOP) +trace --quiet

clean:
	rm -rf obj_dir logs *.log
	clear


# flags
#  --Wno-WIDTH