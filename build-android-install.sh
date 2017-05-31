#!/bin/sh
rm -rf android-install
mkdir -p android-install/ghc/inplace/lib/package.conf.d
mkdir -p android-install/ghc/inplace/lib/bin
mkdir -p android-install/ghc/inplace/bin
mkdir -p android-install/ghc/ghc/linkall
mkdir -p android-install/ghc/libraries
mkdir -p android-install/ghc/test

cp inplace/lib/package.conf.d/* android-install/ghc/inplace/lib/package.conf.d
cp inplace/lib/bin/*-alllink android-install/ghc/inplace/lib/bin
cp inplace/lib/platformConstants.stage2 android-install/ghc/inplace/lib
cp inplace/bin/*-alllink android-install/ghc/inplace/bin
cp ghc/linkall/*.so android-install/ghc/ghc/linkall
cp test/* android-install/ghc/test
cp android-install.sh android-install

sed -i -e 1,1d android-install/ghc/inplace/bin/ghc-pkg-alllink
sed -i -e 1,1d android-install/ghc/inplace/bin/ghc-stage2-alllink

rm android-install/ghc/inplace/lib/package.conf.d/ghc*.conf
cp inplace/lib/package.conf.d/ghc-prim* android-install/ghc/inplace/lib/package.conf.d
cp fixups/builtin_rts.conf android-install/ghc/inplace/lib/package.conf.d
for conf_file in android-install/ghc/inplace/lib/package.conf.d/*.conf
do
  sed -i -e 's/import-dirs: .*\/libraries/import-dirs: libraries/;s/library-dirs: .*\/libraries/library-dirs: libraries/;s/data-dir: .*\/libraries/data-dir: libraries/;s/include-dirs: .*\/libraries/include-dirs: libraries/;s/haddock-interfaces: .*\/libraries/haddock-interfaces: libraries/' $conf_file
done

find libraries -name "*.dyn_hi" -exec install -D {} android-install/ghc/{} \;
