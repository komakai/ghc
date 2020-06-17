#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "Usage: `basename $0` dyliblocation"
    exit 1
fi

objdump --section-headers $1 | awk '$5 == "BSS"' | awk 'NR == 1 {printf "#define BSS_START 0x%s\n", $4}' > ghc/nativeint/bss_limits.h
objdump --section-headers $1 | awk '$5 == "BSS"' | awk 'END {printf "#define BSS_END (0x%s + 0x%s)\n", $4, $3}' >> ghc/nativeint/bss_limits.h
