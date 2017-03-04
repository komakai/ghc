# Glasgow Haskell Compiler Android/iOS Fork

This is the Glasgow Haskell Compiler Android/iOS Fork - for details of the Glasgow Haskell Compiler see README_GHC.md

## How-to Build For Android

### Environment Setup

Install 64-bit Ubuntu 2GB of RAM  
(If running VMware make sure to `sudo apt-get install open-vm-tools-desktop`)  
Run Software Updater  
Install Chrome  
Install necessary dependencies:  
`sudo apt-get install libc6-i386 libc6-dev-i386 git gcc autoconf libffi-dev:i386 libffi6:i386 libncurses5:i386 libncurses5-dev:i386 libgmp3-dev:i386`

### Create Compiler/Linker Wrapper Scripts

Create a 32-bit wrapper around gcc:  
`sudo nano /usr/bin/gcc32`
```
#!/bin/bash
exec "/usr/bin/gcc" -m32 ${1+"$@"}
```
Create a 32-bit wrapper around ld:  
`sudo nano /usr/bin/ld32`
```
#!/bin/bash
args=( "$@" )
usegcc=yes
if [[ $# -eq 1 ]] && [[ $1 =~ ^@ ]]
then
  readarray a < <( cat ${1#?} | sed 's/\(^"\|"$\)//g' )
  set -- ${a[*]}
fi

if [[ $1 == --version ]] || [[ $1 == -Wl,--version ]]
then
  exec "/usr/bin/ld" --version
  exit 0
fi
if [[ $1 == -v ]] || [[ $1 == -Wl,-v ]]
then
  exec "/usr/bin/ld" -v
  exit 0
fi
if [[ $1 == --help ]] || [[ $1 == -Wl,--help ]]
then
  exec "/usr/bin/ld" --help
  exit 0
fi

while (( "$#" ));
do
  if [[ $1 == -r ]]
  then
    usegcc=no
    break
  fi
  shift
done

if [ "$usegcc" == "yes" ];
then
  exec "/usr/bin/gcc32" "${args[@]}"
else
  exec "/usr/bin/ld" -melf_i386 "$@"
fi
```

Give executable permission to the wrapper scripts:  
`sudo chmod +x /usr/bin/gcc32`  
`sudo chmod +x /usr/bin/ld32`  

### Installing a Bootstrapping GHC

Copy ghc-7.8.2-i386-unknown-linux-deb7.tar.xz to Downloads folder
Untar from command-line (archive manager will fail):  
`tar xf '/home/giles/Downloads/ghc-7.8.2-i386-unknown-linux-deb7.tar.xz'`  
Change into ghc-7.8.2 directory:  
`cd ghc-7.8.2`
Run configure with the 32-bit gcc wrapper:  
`./configure --with-gcc=/usr/bin/gcc32 --with-ld=/usr/bin/ld32`
Install:  
`sudo make install`

Edit /usr/local/bin/ghc
Change the final line from
```
exec "$executablename" -B"$topdir" ${1+"$@"}
```
to
```
exec "$executablename" -B"$topdir" ${1+"$@"} -optc-m32 -opta-m32
```

`sudo apt install happy alex`

### Checking out the Source

Create .gitconfig and add the following rules:  
```
[url "https://github.com/ghc/libffi-tarballs.git"]
	insteadOf = https://github.com/komakai/libffi-tarballs.git
[url "https://github.com/ghc/packages-"]
	insteadOf = https://github.com/komakai/packages/
[url "https://github.com/ghc/nofib.git"]
	insteadOf = https://github.com/komakai/nofib.git
[url "https://github.com/ghc/haddock.git"]
	insteadOf = https://github.com/komakai/haddock.git
[url "https://github.com/ghc/hsc2hs.git"]
	insteadOf = https://github.com/komakai/hsc2hs.git
[url "https://github.com/komakai/packages-unix.git"]
	insteadOf = https://github.com/komakai/packages/unix.git
[url "https://github.com/komakai/packages-process.git"]
	insteadOf = https://github.com/komakai/packages/process.git
```

Clone the git repository together with submodules:  
`git clone --recursive https://github.com/komakai/ghc.git ghc-komakai`

Switch to the ghc-7.10-interactive-edition branch:  
`cd ghc-komakai`
`git fetch origin`
`git checkout -b ghc-7.10-interactive-edition origin/ghc-7.10-interactive-edition`
`git submodule update`

### Setting up Android Build Tools

Download and install Android NDK
Set up ANDROID_NDK and ANDROID_NDK_TOOLCHAIN environment variables in .bashrc adding something similar to these lines:
```
export ANDROID_NDK=/home/giles/android-ndk-r13b
export ANDROID_NDK_TOOLCHAIN=arm-linux-androideabi-4.9/prebuilt/linux-x86_64
```

Create a wrapper around the NDK linker called arm-linux-androideabi-ld-wrap
```
#!/bin/bash
args=( "$@" )
usegcc=yes
if [[ $# -eq 1 ]] && [[ $1 =~ ^@ ]]
then
  readarray a < <( cat ${1#?} | sed 's/\(^"\|"$\)//g' )
  set -- ${a[*]}
fi

if [[ $1 == --version ]] || [[ $1 == -Wl,--version ]]
then
  exec "$ANDROID_NDK/toolchains/$ANDROID_NDK_TOOLCHAIN/bin/arm-linux-androideabi-ld" --version
  exit 0
fi
if [[ $1 == -v ]] || [[ $1 == -Wl,-v ]]
then
  exec "$ANDROID_NDK/toolchains/$ANDROID_NDK_TOOLCHAIN/bin/arm-linux-androideabi-ld" -v
  exit 0
fi
if [[ $1 == --help ]] || [[ $1 == -Wl,--help ]]
then
  exec "$ANDROID_NDK/toolchains/$ANDROID_NDK_TOOLCHAIN/bin/arm-linux-androideabi-ld" --help
  exit 0
fi

while (( "$#" ));
do
  if [[ $1 == -r ]]
  then
    usegcc=no
    break
  fi
  shift
done

if [ "$usegcc" == "yes" ];
then
  exec "$ANDROID_NDK/toolchains/$ANDROID_NDK_TOOLCHAIN/bin/arm-linux-androideabi-gcc" "${args[@]}"
else
  exec "$ANDROID_NDK/toolchains/$ANDROID_NDK_TOOLCHAIN/bin/arm-linux-androideabi-ld" "$@"
fi
```

Give executable permission to the wrapper script:  
`chmod +x $ANDROID_NDK/toolchains/$ANDROID_NDK_TOOLCHAIN/bin/arm-linux-androideabi-ld-wrap`

### Building

Copy mk/build-interactive-edition.mk to mk/build.mk

Build  
`./boot`  
`./configure --with-gcc=/usr/bin/gcc32 --with-ld=/usr/bin/ld32 -build=i386-unknown-linux -host=i386-unknown-linux STAGE=1`  
`./configure  --with-gcc=$ANDROID_NDK/toolchains/$ANDROID_NDK_TOOLCHAIN/bin/arm-linux-androideabi-gcc --with-ld=$ANDROID_NDK/toolchains/$ANDROID_NDK_TOOLCHAIN/bin/arm-linux-androideabi-ld-wrap --with-nm=$ANDROID_NDK/toolchains/$ANDROID_NDK_TOOLCHAIN/bin/arm-linux-androideabi-nm --with-ar=$ANDROID_NDK/toolchains/$ANDROID_NDK_TOOLCHAIN/bin/arm-linux-androideabi-ar --with-ranlib=$ANDROID_NDK/toolchains/$ANDROID_NDK_TOOLCHAIN/bin/arm-linux-androideabi-ranlib --build=i386-unknown-linux --host=arm-unknown-linux CFLAGS="-w -I$ANDROID_NDK/platforms/android-9/arch-arm/usr/include -march=armv5te -D__ARM_ARCH_5__ -D__ARM_ARCH_5T__ -D__ARM_ARCH_5E__ -D__ARM_ARCH_5TE__ -DANDROID -DINTERACTIVE_EDITION -funwind-tables -fstack-protector -Wno-psabi -mtune=xscale -msoft-float -mthumb -Os -fomit-frame-pointer -fno-strict-aliasing -finline-limit=64" LDFLAGS="--sysroot=$ANDROID_NDK/platforms/android-9/arch-arm -lgcc -no-canonical-prefixes -Wl,-z,noexecstack -lc -lm -llog"  CPP="$ANDROID_NDK/toolchains/$ANDROID_NDK_TOOLCHAIN/bin/arm-linux-androideabi-gcc -E" CPPFLAGS="-I$ANDROID_NDK/platforms/android-9/arch-arm/usr/include -D__ARM_ARCH_5__ -D__ARM_ARCH_5T__ -D__ARM_ARCH_5E__ -D__ARM_ARCH_5TE__ -DANDROID -DINTERACTIVE_EDITION" STAGE=2`  
`make 2>&1 | tee build.log`  

### Installing on an Android Device

Prepare the files for install:  
`./build-android-install.sh`  

Obtain a copy of adb (Android Debug Bridge) - for example by installing the Android SDK command line tools (https://developer.android.com/studio/index.html very bottom of the page)
Make sure adb is in the system path. Attach the device to install on with USB cable (you will need to have developer mode and USB debugging enabled)
`cd android-install`  
`./android-install.sh /data/local/tmp`  

### Running
`adb shell`  
`cd /data/local/tmp/ghc`  
`inplace/bin/ghc-stage2-alllink --interactive`  

Enter the following commands  
`:load test/qsort.hs`  
`main`  

You should see some output !!!
[6,18,23,71]

To exit enter  
`:quit`  

Congratulations - you have Haskell running on Android
