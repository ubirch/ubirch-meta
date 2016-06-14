# ubirch board firmware

The [ubirch board firmware](http://ubirch.com) is a hardware abstraction layer for different board based on
the [NXP](http://www.nxp.com) [Kinetis SDK v2](http://www.nxp.com/products/software-and-tools/run-time-software/kinetis-software-and-tools/development-platforms-with-mbed/software-development-kit-for-kinetis-mcus:KINETIS-SDK).
Our main goal is to support the development of IoT applications for the [ubirch platform](http://api.ubirch.com) while
still providing enough abstraction to make coding easy.

## Contents

1. [Installation](#installation)
    1. [Cross Compilation Environment](#crosscompile)
        1. [Linux](#install-linux) Ubuntu/Debian
        2. [macOS](#install-macos)
        3. [Windows](#install-windows)
    2. [Installing the Toolchain](#toolchain)
2. [Getting Started](#gettingstarted)
    1. [Install Template Project](#fetchtemplate)
    2. [Compiling](#compiletemplate)
    3. [Flashing](#flashtemplate)
3. [Additional Information](#additional)
    1. BOARDS
    2. Development (CMake, Firmware, Crypto)
    3. [Example Code](https://github.com/ubirch/ubirch-board-examples)
4. [License](#license)

<a name="installation"></a>
## Installation

The toolchain consists of a number of code packages that are cross-compiled on your development
platform for the target devices. In order to make it as simple as possible to get the toolchain
up and running we provide a meta project (sometimes called a super-build) that will fetch all
necessary repositories and compile the toolchain for any known MCU and board type.

 <a name="crosscompile"></a>
### Install cross compilation environment

A number of tools are necessary if you didn't setup a cross compilation environment before:

<a name="install-linux"></a>
#### Linux (Ubuntu/Debian)

```
apt-get install git
apt-get install cmake
apt-get install gcc-arm-none-eabi
# optional CGDB for debugging
apt-get install cgdb
# optional Doxygen for generating the documentation locally
apt-get install doxygen
```

<a name="install-macos"></a>
#### macOS

Install [homebrew](http://brew.sh/) first, it will help greatly! You will also need the
[Xcode](https://developer.apple.com/xcode/) command line tools, however, homebrew usually
complains and helps you install and setup it.

```
brew install git
brew install cmake
brew tap armmbed/formulae
brew install arm-none-eabi-gcc
# optional CGDB for debugging
brew install cgdb
# optional Doxygen for generating the documentation locally
brew install doxygen
```

<a name="install-windows"></a>
#### Windows

Get [Git for Windows](https://git-scm.com/download/win) and install either [MingW](http://www.mingw.org/) or another GNU toolchain. With cmake it may
even work with the Windows developer tools. However, you will need the
[Launchpad GCC ARM Embedded](https://launchpad.net/gcc-arm-embedded/+download) installer
as well as the [CMake](https://cmake.org/download/) windows installer.

<a name="toolchain"></a>
### Installing the toolchain

After you've prepared the cross-compilation environment we can start downloading and
compiling the actual [ubirch toolchain](https://github.com/ubirch/ubirch-meta) which contains the libraries, linking helpers and some
flashing support.

Currently the build script is only available for Linux and macOS. Feel free to adapt the
`build.sh` to a Windows batch script.

```
git clone https://github.com/ubirch/ubirch-meta.git
cd ubirch-meta
./build.sh -a
```

The compilation will take a little while because the toolchain fetches the git repositories
and compile the libraries required for each of the supported targets.

>  ⚠ __DO NOT DELETE THE SOURCES!__ <br/>
> They are required for finding header files and additional support files. In contrast to
> a normal library on your host system, the cross compilation can't install libraries
> and headers the normal way. We decided to just leave them where they are and point
> the search paths to the original sources.

If you would like to know more about the structure of the toolchain, take a look at the
[ubirch-meta README](md_README.html).

That's it, now you're ready to start with your first project.

<a name="gettingstarted"></a>
## Getting started

Now you're ready to start your first project. The choice of your development environment
possibly includes an IDE. [Leo](http://twitter.com/thinkberg)'s choice is currently
[CLion](https://www.jetbrains.com/clion/) but you can use any C/C++ IDE of your choice as
long as it is supported by CMake. One option is [Eclipse CDT](https://eclipse.org/cdt/).

<a name="fetchtemplate"></a>
### Install the Template Project

First download our [template project](https://github.com/ubirch/ubirch-project-template)
([zip](https://github.com/ubirch/ubirch-project-template/archive/master.zip)) and extract
it at the location of your choice.

<a name="compiletemplate"></a>
#### Compiling

CMake promotes out-of-source builds, which means your compiled files will go in a
different location than your sources! Thus we create a `ubirch-project-template-build` directory
right next to the source directory:

> We assume the `ubirch-meta directory` also be a sibling of the template project.

```
mkdir ubirch-project-template-build
cd ubirch-project-template-build
cmake .. -DCMAKE_TOOLCHAIN_FILE=../ubirch-arm-toolchain/cmake/ubirch-arm-gcc-toolchain.cmake
make
```

If that worked, you compiled the project template successfully for the `ubirch1r02` board.
In case your target is a different board, just run the cmake command again as follows:

```
# generate the makefiles for the FRDM-K82F board
cmake .. -DBOARD=FRDM-K82F -DCMAKE_TOOLCHAIN_FILE=../ubirch-arm-toolchain/cmake/ubirch-arm-gcc-toolchain.cmake
```

Currently available boards are: `ubirch1r02`, `FRDM-K82F`, `FRDM-KL82Z`

>  ⚠ __Attention__ <br/>
> Unless you want to change the target board, you should not need to run `cmake` again.
> Just run `make` as it takes care of changed settings.

<a name="flashtemplate"></a>
### Flashing

Flashing the resulting code is also supported by `make`:

```
make ubirch-template-flash
```

Depending on your selected board the toolchain will try to use the default flashing method:

- `ubirch1r02` - Flashing via USB using the [blhost](http://www.nxp.com/products/microcontrollers-and-processors/arm-processors/kinetis-cortex-m-mcus/kinetis-symbols-footprints-and-models/kinetis-bootloader:KBOOT)
- `FRDM-K82F`/`FRDM-KL82Z` - Flashing via CMSIS-DAP (mounted directoy)

<a name="debugtemplate"></a>
### Debugging

Debugging requires an external *Debug Probe*. We use a [SEGGER JLink](https://www.segger.com/jlink-debug-probes.html)
and its GDB server together with [GDB](https://www.gnu.org/software/gdb/). Debugging requires to
attach the debug probe to the corresponding JTAG (SWD) pins on board and starting the GDB server:

For more convenient debugging, install [CGDB](https://cgdb.github.io/) (available via `brew install` and `apt-get`).
> In this example we start the GDB server attached to our `ubirch1r02` or the `FRDM-K82F` board.

```
JLinkGDBServer -if SWD -speed 4000 -device MK82FN256xxx15
```

The toolchain provides a make target which outputs the debugger commandline which you can then
just cut and paste into the terminal to start debugging:

```
make ubirch-template-gdb
```

Happy debugging!

<a name="additional"></a>
## Additional Information



The toolchain libraries and board specific information is available in the individual sub projects:

- __BOARDS__
  - [ubirch#1 r0.2](md_ubirch-board-firmware_board_ubirch1r02_README.html) (K82F, Cortex-M4)
  - [FRDM-K82F](md_ubirch-board-firmware_board_frdm_k82f_README.html) (K82F, Cortex-M4)
  - [FRDM-KL82Z](md_ubirch-board-firmware_board_frdm_kl82z_README.html) (KL82Z, Cortex-M0+)
- __Development__
  - [CMake ARM Toolchain](md_ubirch-arm-toolchain_README.html)
  - [Firmware](files.html)
  - [Crypto Support](md_ubirch-board-crypto_README.html)
- [__Example Code__](https://github.com/ubirch/ubirch-board-examples)

<a name="license"></a>
## License

__Copyright &copy; 2016 [ubirch](http://ubirch.com) GmbH, Author: Matthias L. Jugel__

```
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

