# ubirch meta-project (superbuild)

This is a special repository, created to make building the toolchain simpler but compiling all configurations
in one got and making the targets available for other projects.

The following commands will create the default toolchain for board `ubirch#1 r0.2`, MCU `K82F`:

```
git clone git@gitlab.com:ubirch/ubirch-meta.git
cd ubirch-meta
./build.sh -a
```

If at a later stage you would like to re-run the build because some of the libraries/repositories have changed,
run `./build.sh -u -a` which includes a `git pull` step.

> The build script will clone the source directories directly into this directory. Ignore them!

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

