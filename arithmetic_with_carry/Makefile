# Makefile
RISCV_PREFIX = riscv64-unknown-elf-
FLAGS = -march=rv64gcv -nostdlib

all: run

compile: test.S
	$(RISCV_PREFIX)gcc $(FLAGS) -T link.ld test.S -o test.elf

run: compile
	@echo "Executing the program..."
	@spike -d --varch=vlen:256,elen:32 --isa=rv64gcv test.elf
	

clean:
	rm -f test.elf spike.log spike.out spike.disass

.PHONY: all run clean

