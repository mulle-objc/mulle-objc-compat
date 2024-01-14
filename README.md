# mulle-objc-compat

#### 🍏 Compatibility layer with Apple Objective-C runtime functions

This library maps
[Apple runtime](//developer.apple.com/documentation/objectivec/objective_c_runtime?language=objc)
functions to their [mulle-objc](//mulle-objc.github.io) counterparts.
This makes porting of existing programs that use Apple runtime functions easier.
If you can get by with the limited set of functions, these functions are
preferable to use over their mulle-objc counterparts for the sake of portability
and familiarity.



| Release Version                                       | Release Notes
|-------------------------------------------------------|--------------
| ![Mulle kybernetiK tag](https://img.shields.io/github/tag/mulle-objc/mulle-objc-compat.svg?branch=release) [![Build Status](https://github.com/mulle-objc/mulle-objc-compat/workflows/CI/badge.svg?branch=release)](//github.com/mulle-objc/mulle-objc-compat/actions) | [RELEASENOTES](RELEASENOTES.md) |





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


## Add

### Add as an individual component

Use [mulle-sde](//github.com/mulle-sde) to add mulle-objc-compat to your project:

``` sh
mulle-sde add github:mulle-objc/mulle-objc-compat
```

To only add the sources of mulle-objc-compat with dependency
sources use [clib](https://github.com/clibs/clib):


``` sh
clib install --out src/mulle-objc mulle-objc/mulle-objc-compat
```

Add `-isystem src/mulle-objc` to your `CFLAGS` and compile all the sources that were downloaded with your project.


## Install

### Install with mulle-sde

Use [mulle-sde](//github.com/mulle-sde) to build and install mulle-objc-compat and all dependencies:

``` sh
mulle-sde install --prefix /usr/local \
   https://github.com/mulle-objc/mulle-objc-compat/archive/latest.tar.gz
```

### Manual Installation

Install the [Requirements](#Requirements) and then
install **mulle-objc-compat** with [cmake](https://cmake.org):

``` sh
cmake -B build \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      -DCMAKE_PREFIX_PATH=/usr/local \
      -DCMAKE_BUILD_TYPE=Release &&
cmake --build build --config Release &&
cmake --install build --config Release
```


## Author

[Nat!](https://mulle-kybernetik.com/weblog) for Mulle kybernetiK  



