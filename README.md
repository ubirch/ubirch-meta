# ubirch meta-project (superbuild)

This is a special repository, created to make building the toolchain simpler but compiling all configurations
in one got and making the targets available for other projects.

The following commands will create the default toolchain for all known boards `ubirch#1 r0.2` and 'FRDM-K82F', as
well as all known MCUs (only `K82F25615`) for all types of configuration (`Debug`, `Release`, `RelWithDebInfo`, `MinSizeRel`):

```
brew tap armmbed/formulae
brew install arm-none-eabi-gcc
```
```
git clone git@github.com:ubirch/ubirch-meta.git
cd ubirch-meta
./build.sh -a
```

If at a later stage you would like to re-run the build because some of the libraries/repositories have changed,
run `./build.sh -u -a` which includes a `git pull` step.

For running a complete rebuild, cleaning the registry, run `./build.sh -c -u -a`, which will prompt you before
executing the `rm` commands for cleanup, then update the repository and do a complete rebuild.

> The build script will clone the source directories directly into this directory. Ignore them unless you want to work on them!
> Don't forget to commit changes back into the repository.

## Dependencies

- `ubirch-arm-toolchain` - needed for a all build processes
- `ubirch-kinetis-sdk` - a repository containing the licensed SDK (from [NXP](kex.nxp.com))
- `ubirch-kinetis-sdk-package` - the Kinetis SDK package builder
- __`ubirch-board-firmware`__ - the board firmware package builder
- `ubirch-wolfssl` - a fork of the wolfSSL repository with patches for Kinetis SDK 2.0
- `ubirch-wolfssl-package` - the wolfSSL package builder
- __`ubirch-board-crypto`__ - board specific crypto layer

The final `ubirch-board-firmware` and `ubirch-crypto` then be used in other projects,
importing it using:

```
require(PACKAGE ubirch BOARD ${BOARD} VERSION 1.0)
require(PACKAGE crypto BOARD ${BOARD} VERSION 1.0)
```

Dependency Graph (firmware):

```
ubirch-arm-toolchain --+--------------------------------+
                       |                                |
ubirch-kinetis-sdk ----+-- ubirch-kinetis-sdk-package --+-- [ubirch-board-firmware]
```

Dependency Graph (crypto support, requires `ubirch-board-firmware`):

```
[ubirch-board-firmware] ----------------------------+
                                                    |
ubirch-wolfssl ----------- ubirch-wolfssl-package --+-- [ubirch-board-crypto]
```

## Documentation

* After building the meta build the documentation can be found in [docs](docs/html/index.html)
* You will find the [Kinetis SDK Documentation](ubirch-kinetis-sdk/SDK_2.0_MK82FN256xxx15/docs/Kinetis SDK v.2.0 API Reference Manual/index.html) in the [ubirch-kinetis-sdk](ubirch-kinetis-sdk) directory.

## License

If not otherwise noted in the individual files, the code in this repository is

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

