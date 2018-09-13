# 🍏 Compatibility layer with Apple Objective-C runtime functions

This library maps
[Apple runtime](https://developer.apple.com/documentation/objectivec/objective_c_runtime?language=objc)
functions to their mulle-objc counterparts.
This makes porting of existing programs that use runtime functions easier.

## Limitations

* This library is mostly NOT thread-safe.
* Some functionality is missing that mulle-objc does not support. E.g. like weak variables.
* Message sending via `objc_msgSend` and friends can only service selectors that take one integer or pointer/object parameter

## Register unknown selectors before using class_addMethod and class_replaceMethod

The use of `@selector( undefinedByAll)` does not give the runtime enough 
information to produce proper methods. Therefore you must `sel_registerName` 
before usage.

## Dealing with `objc_msgSend`

It is fairly conventional to write various `objc_msgSend0`,
`objc_msgSend1`, `objc_msgSend2` functions that deal with varying parameters
and return values. These functions are not part of the library. `objc_msgSend` 
is defined though.

Use the [mulle-objc MetaABI]
(https://www.mulle-kybernetik.com/weblog/2015/mulle_objc_meta_call_convention.html)
convention to pass parameters and inspect return values.

## Dealing with `objc_msgSend_stret`

Use the [mulle-objc MetaABI]
(https://www.mulle-kybernetik.com/weblog/2015/mulle_objc_meta_call_convention.html) and objc_msgSend directly. 

## Protocols in mulle-objc are almost only syntax

This means:

* the runtime only knows about protocols that are adopted by a class
* a protocol in mulle-objc is mainly a hash value (like a selector)
* the information about methods and properties of a protocol are gone, the introspection candidate is the class
* you can not message protocols


## There is no enveloping NSAutoreleasePool around +load in mulle-objc

If you create ephemeral instances in your `+load` method,
you should wrap the code yourself inside an `NSAutoreleasePool`.


## You can't go as crazy in +initialize

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
