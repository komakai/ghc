#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "Usage: `basename $0` installdir"
    exit 1
fi

installdir=$1/ghc

sed -i -e "s@top=\".*\"@top=\"$installdir\"@" ghc/inplace/bin/ghc-pkg-alllink
sed -i -e "s@top=\".*\"@top=\"$installdir\"@" ghc/inplace/bin/ghc-stage2-alllink

adb shell rm -r $installdir
adb push ghc $1
adb shell chmod 757 $installdir/inplace/bin/ghc-pkg-alllink
adb shell chmod 757 $installdir/inplace/bin/ghc-stage2-alllink
adb shell chmod 757 $installdir/inplace/lib/bin/ghc-pkg-alllink
adb shell chmod 757 $installdir/inplace/lib/bin/ghc-stage2-alllink
adb shell chmod 757 $installdir/ghc/linkall/`ls ghc/ghc/linkall`

adb shell $installdir/inplace/bin/ghc-pkg-alllink recache --force -f $installdir/inplace/lib/package.conf.d
