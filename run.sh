#!/bin/bash

case ${1,,} in
    assemble)
        cd assembler
        python gpu_assembler.py program.asm
        cd ../
        ;;

    verilate)
        cd verilator
        make
        cd ../
        ;;

    clean)
        cd verilator
        make clean
        cd ../
        ;;

    *)
        cd assembler
        python gpu_assembler.py program.asm
        cd ../
        cd verilator
        make
        cd ../
        ;;

esac