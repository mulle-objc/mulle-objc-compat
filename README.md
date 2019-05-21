# mulle-objc-compat

🍏 Compatibility layer with Apple Objective-C runtime functions

This library maps
[Apple runtime](https://developer.apple.com/documentation/objectivec/objective_c_runtime?language=objc)
functions to their [mulle-objc](//mulle-objc.github.io) counterparts.
This makes porting of existing programs that use Apple runtime functions easier.
If you can get by with the limited set of functions, these functions are
preferable to use over their mulle-objc counterparts for the sake of portability
and familiarity.


Build Status | Release Version
-------------|-----------------------------------
[![Build Status](https://travis-ci.org/mulle-objc/mulle-objc-compat.svg?branch=release)](https://travis-ci.org/mulle-objc/mulle-objc-compat) | ![Mulle kybernetiK tag](https://img.shields.io/github/tag/mulle-objc/mulle-objc-compat.svg) [![Build Status](https://travis-ci.org/mulle-objc/mulle-objc-compat.svg?branch=release)](https://travis-ci.org/mulle-objc/mulle-objc-compat)



> #### Mental model
>
> This library
>
> * does not include any other runtime than mulle-objc-runtime.
> * does not define any functionality that is not part of the Apple runtime
> * does not implement everything that's in the Apple runtime
>

## Limitations

* This library hasn't been scrutinized for thread-safety.
* Some functionality is missing that mulle-objc does not support. E.g. "weak variables".
* Message sending via `objc_msgSend` uses the [mulle-objc MetaABI](https://www.mulle-kybernetik.com/weblog/2015/mulle_objc_meta_call_convention.html) and therefore is only compatible in the case, where there is only one pointer sized parameter and a pointer sized return value.
* The library must be compiled with mulle-clang (since the multiverse changes)


### Register unknown selectors before using class_addMethod and class_replaceMethod

The use of `@selector( undefinedByAll)` does not give the runtime enough
information to produce proper methods. Therefore you must `sel_registerName`
before usage.


### Dealing with `objc_msgSend`

It is fairly conventional to write various `objc_msgSend0`,
`objc_msgSend1`, `objc_msgSend2` functions that deal with varying parameters
and return values. These functions are not part of the library. `objc_msgSend`
is defined though.

Use the [mulle-objc MetaABI](https://www.mulle-kybernetik.com/weblog/2015/mulle_objc_meta_call_convention.html)
convention to pass parameters and inspect return values.


### Dealing with `objc_msgSend_stret`

Use the [mulle-objc MetaABI](https://www.mulle-kybernetik.com/weblog/2015/mulle_objc_meta_call_convention.html) and objc_msgSend directly.


### Protocols in mulle-objc are almost only syntax

This means:

* the runtime only knows about protocols that are adopted by a class
* a protocol in mulle-objc is mainly a hash value (like a selector)
* the information about methods and properties of a protocol are gone, the introspection candidate is the class
* you can not message protocols


### There is no enveloping NSAutoreleasePool around +load in mulle-objc

If you create ephemeral instances in your `+load` method,
you should wrap the code yourself inside an `NSAutoreleasePool`.


### Dealing with instanceSize

`self` in mulle-objc is **not** the address that was allocated, but at an
offset. Conversely `class_getInstanceSize` returns the number of bytes
to allocate and **not** the space occupied by ivars.


### You can't go as crazy in +initialize

* do not call `[super initialize]`, which is pointless anyway.
* do not message subclasses


## How to build

This is a [mulle-sde](https://mulle-sde.github.io/) project.

It has it's own virtual environment, that will be automatically setup for you
once you enter it with:

```
mulle-sde mulle-objc-compat
```

Now you can let **mulle-sde** fetch the required dependencies and build the
project for you:

```
mulle-sde craft
```
