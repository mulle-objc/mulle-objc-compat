# mulle-objc-compat

#### 🍏 Compatibility layer with Apple Objective-C runtime functions

This library maps
[Apple runtime](//developer.apple.com/documentation/objectivec/objective_c_runtime?language=objc)
functions to their [mulle-objc](//mulle-objc.github.io) counterparts.
This makes porting of existing programs that use Apple runtime functions easier.
If you can get by with the limited set of functions, these functions are
preferable to use over their mulle-objc counterparts for the sake of portability
and familiarity.



| Release Version                                       | Release Notes  | AI Documentation
|-------------------------------------------------------|----------------|---------------
| ![Mulle kybernetiK tag](https://img.shields.io/github/tag/mulle-objc/mulle-objc-compat.svg) [![Build Status](https://github.com/mulle-objc/mulle-objc-compat/workflows/CI/badge.svg)](//github.com/mulle-objc/mulle-objc-compat/actions) | [RELEASENOTES](RELEASENOTES.md) | [DeepWiki for mulle-objc-compat](https://deepwiki.com/mulle-objc/mulle-objc-compat)





## Mental model

This library

* does not include any other runtime than mulle-objc-runtime.
* does not define any functionality that is not part of the Apple runtime
* does not implement everything that's in the Apple runtime


## Limitations

* This library hasn't been scrutinized for thread-safety.
* Some functionality is missing that mulle-objc does not support. E.g. "weak variables".
* Message sending via `objc_msgSend` uses the [mulle-objc MetaABI](//www.mulle-kybernetik.com/weblog/2015/mulle_objc_meta_call_convention.html) and therefore is only compatible in the case, where there is only one pointer sized parameter and a pointer sized return value.
* The library must be compiled with mulle-clang (since the multiverse changes)



### You are here

![Overview](overview.dot.svg)



## Requirements

|   Requirement         | Release Version  | Description
|-----------------------|------------------|---------------
| [MulleObjC](https://github.com/mulle-objc/MulleObjC) | ![Mulle kybernetiK tag](https://img.shields.io/github/tag/mulle-objc/MulleObjC.svg) [![Build Status](https://github.com/mulle-objc/MulleObjC/workflows/CI/badge.svg?branch=release)](https://github.com/mulle-objc/MulleObjC/actions/workflows/mulle-sde-ci.yml) | 💎 A collection of Objective-C root classes for mulle-objc


## Quickstart


``` sh
mulle-sde init -d my-project -m mulle-objc/objc-developer executable
cd my-project
mulle-sde vibecoding on
mulle-sde run
mulle-sde dependency toc mulle-objc/mulle-objc-compat
```

You are done, skip the following "Add" step.


## Add

Use [mulle-sde](//github.com/mulle-sde) to add mulle-objc-compat to your project.
As long as your sources are using `#import "import-private.h"` and your headers use `#import "import.h"`, there will nothing more to do:

``` sh
mulle-sde add github:mulle-objc/mulle-objc-compat
```

To only add the sources of mulle-objc-compat with all the sources of its
dependencies replace "github:" with [clib:](https://github.com/clibs/clib):

## Legacy adds

One common denominator is that you will likely have to add
`#import <mulle-objc-compat/mulle-objc-compat.h>` to your source files.


### Add sources to your project with clib

``` sh
clib install --out src/mulle-objc mulle-objc/mulle-objc-compat
```

Add `-isystem src/mulle-objc` to your `CFLAGS` and compile all the
sources that were downloaded with your project. (In **cmake** add
`include_directories( BEFORE SYSTEM src/mulle-objc)` to your `CMakeLists.txt`
file).







### Add as subproject with cmake and git

``` bash
git submodule add -f --name "mulle-core" \
                            "https://github.com/mulle-core/mulle-core.git" \
                            "stash/mulle-core"
git submodule add -f --name "libbacktrace" \
                            "https://github.com/mulle-core/libbacktrace.git" \
                            "stash/libbacktrace"
git submodule add -f --name "mulle-allocator" \
                            "https://github.com/mulle-c/mulle-allocator.git" \
                            "stash/mulle-allocator"
git submodule add -f --name "mulle-thread" \
                            "https://github.com/mulle-concurrent/mulle-thread.git" \
                            "stash/mulle-thread"
git submodule add -f --name "mulle-core-all-load" \
                            "https://github.com/mulle-core/mulle-core-all-load.git" \
                            "stash/mulle-core-all-load"
git submodule add -f --name "mulle-objc-runtime" \
                            "https://github.com/mulle-objc/mulle-objc-runtime.git" \
                            "stash/mulle-objc-runtime"
git submodule add -f --name "mulle-objc-debug" \
                            "https://github.com/mulle-objc/mulle-objc-debug.git" \
                            "stash/mulle-objc-debug"
git submodule add -f --name "mulle-objc-compat" \
                            "https://github.com/mulle-objc/mulle-objc-compat" \
                            "stash/mulle-objc-compat"
git submodule update --init --recursive
```

``` cmake
add_subdirectory( stash/mulle-objc-compat)
add_subdirectory( stash/mulle-objc-debug)
add_subdirectory( stash/mulle-objc-runtime)
add_subdirectory( stash/mulle-core-all-load)
add_subdirectory( stash/mulle-thread)
add_subdirectory( stash/mulle-allocator)
add_subdirectory( stash/libbacktrace)
add_subdirectory( stash/mulle-core)

target_link_libraries( ${PROJECT_NAME} PUBLIC mulle-objc-compat)
target_link_libraries( ${PROJECT_NAME} PUBLIC mulle-objc-debug)
target_link_libraries( ${PROJECT_NAME} PUBLIC mulle-objc-runtime)
target_link_libraries( ${PROJECT_NAME} PUBLIC mulle-core-all-load)
target_link_libraries( ${PROJECT_NAME} PUBLIC mulle-thread)
target_link_libraries( ${PROJECT_NAME} PUBLIC mulle-allocator)
target_link_libraries( ${PROJECT_NAME} PUBLIC libbacktrace)
target_link_libraries( ${PROJECT_NAME} PUBLIC mulle-core)
```


## Install

Use [mulle-sde](//github.com/mulle-sde) to build and install mulle-objc-compat and all dependencies:

``` sh
mulle-sde install --prefix /usr/local \
   https://github.com/mulle-objc/mulle-objc-compat/archive/latest.tar.gz
```

### Legacy Installation


#### Requirements

Install all requirements

| Requirements                                 | Description
|----------------------------------------------|-----------------------
| [MulleObjC](https://github.com/mulle-objc/MulleObjC)             | 💎 A collection of Objective-C root classes for mulle-objc

#### Download & Install


Download the latest [tar](https://github.com/mulle-objc/mulle-objc-compat/archive/refs/tags/latest.tar.gz) or [zip](https://github.com/mulle-objc/mulle-objc-compat/archive/refs/tags/latest.zip) archive and unpack it.

Install **mulle-objc-compat** into `/usr/local` with [cmake](https://cmake.org):

``` sh
PREFIX_DIR="/usr/local"
cmake -B build                               \
      -DMULLE_SDK_PATH="${PREFIX_DIR}"       \
      -DCMAKE_INSTALL_PREFIX="${PREFIX_DIR}" \
      -DCMAKE_PREFIX_PATH="${PREFIX_DIR}"    \
      -DCMAKE_BUILD_TYPE=Release &&
cmake --build build --config Release &&
cmake --install build --config Release
```


## Author

[Nat!](https://mulle-kybernetik.com/weblog) for Mulle kybernetiK  



