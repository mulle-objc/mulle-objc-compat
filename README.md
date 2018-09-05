# 🍏 Compatibility layer with Apple Objective-C runtime functions

This library maps
[Apple runtime](https://developer.apple.com/documentation/objectivec/objective_c_runtime?language=objc)
functions to their mulle-objc counterparts.
This makes porting of existing programs that use runtime functions easier.

## Limitations

* This library is mostly NOT thread-safe.
* Some functionality is missing that mulle-objc does not support. E.g. like weak variables.
* Message sending via `objc_msgSend` and friends can only service selectors that take one integer or pointer/object parameter


## Dealing with `objc_msgSend`

It is fairly conventional to write various `objc_msgSend0`,
`objc_msgSend1`, `objc_msgSend2` functions that deal with varying parameters
and return values. These functions are not part of the library.
Use the
[mulle-objc MetaABI](https://www.mulle-kybernetik.com/weblog/2015/mulle_objc_meta_call_convention.html)
convention to pass parameters and inspect return values.


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
