#! /bin/bash

nasm -f elf32 $1.asm
gcc -m32 /home/aetf/Develop/ASM/inc/*.o "$1".o -o "$1"
