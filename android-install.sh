#!/bin/sh
mkdir -p android-install/inplace/lib/package.conf.d
mkdir -p android-install/inplace/lib/bin
mkdir -p android-install/inplace/bin
mkdir -p android-install/ghc/linkall
mkdir -p android-install/libraries

cp inplace/lib/package.conf.d/* android-install/inplace/lib/package.conf.d
cp inplace/lib/bin/*-alllink android-install/inplace/lib/bin
cp inplace/bin/*-alllink android-install/inplace/bin
cp ghc/linkall/*.so android-install/ghc/linkall

find libraries -name "*.dyn_hi" -exec install -D {} android-install/{} \;
